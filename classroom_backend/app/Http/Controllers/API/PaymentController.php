<?php
// // app/Http/Controllers/API/PaymentController.php
// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
// use Illuminate\Support\Carbon;
// use Illuminate\Support\Facades\DB;
// use App\Models\Payment;
// use App\Models\ClassroomUser;

// class PaymentController extends Controller
// {
//   // STUDENT — billing summary + history
//   public function me(Request $req) {
//     $mobile = $req->query('mobile');
//     if (!$mobile) return response()->json(['message'=>'mobile required'], 422);

//     $u = ClassroomUser::where('mobile',$mobile)->first();
//     if (!$u) return response()->json(['message'=>'User not found'], 404);

//     $today = Carbon::today();
//     $status = 'expired';
//     if ($u->trial_ends_at && Carbon::parse($u->trial_ends_at)->isFuture()) {
//       $status = 'trial';
//     } elseif ($u->paid_until && Carbon::parse($u->paid_until)->isFuture()) {
//       $status = 'active';
//     }

//     $history = Payment::where('mobile',$mobile)->orderBy('created_at','desc')->get();

//     return response()->json([
//       'status'        => $status,
//       'trial_ends_at' => $u->trial_ends_at,
//       'paid_until'    => $u->paid_until,
//       'history'       => $history,
//     ]);
//   }

//   // ADMIN — list payments with filters
//   public function index(Request $req) {
//     $q = Payment::query()->orderBy('created_at','desc');
//     if ($m = $req->query('mobile')) $q->where('mobile',$m);
//     if ($from = $req->query('from')) $q->whereDate('created_at','>=',$from);
//     if ($to = $req->query('to'))   $q->whereDate('created_at','<=',$to);
//     return response()->json(['payments'=>$q->get()]);
//   }

//   // ADMIN — create manual PAID entry and extend paid_until
//   public function store(Request $req) {
//     $data = $req->validate([
//       'mobile'       => 'required',
//       'amount'       => 'required|integer|min:100', // in paise
//       'currency'     => 'nullable|string',
//       'period_start' => 'nullable|date',
//       'period_end'   => 'nullable|date',
//       'notes'        => 'nullable|array',
//     ]);

//     $p = Payment::create([
//       'mobile'       => $data['mobile'],
//       'amount'       => $data['amount'],
//       'currency'     => $data['currency'] ?? 'INR',
//       'status'       => 'paid',
//       'paid_at'      => now(),
//       'period_start' => $data['period_start'] ?? Carbon::today(),
//       'period_end'   => $data['period_end']   ?? Carbon::today()->addMonth(),
//       'notes'        => $data['notes'] ?? null,
//     ]);

//     // extend access
//     ClassroomUser::where('mobile',$data['mobile'])->update([
//       'paid_until' => $p->period_end,
//     ]);

//     return response()->json(['payment'=>$p], 201);
//   }

//   // ADMIN — grant free trial
//   public function grantTrial(Request $req) {
//     $data = $req->validate([
//       'mobile' => 'required',
//       'days'   => 'required|integer|min:1|max:60',
//     ]);
//     $trialEnds = Carbon::today()->addDays($data['days']);
//     ClassroomUser::where('mobile',$data['mobile'])->update(['trial_ends_at'=>$trialEnds]);
//     return response()->json(['trial_ends_at'=>$trialEnds->toDateString()]);
//   }

//   // STUDENT — create Razorpay order on server
//   public function createOrder(Request $req) {
//     $data = $req->validate([
//       'mobile'   => 'required',
//       'amount'   => 'required|integer|min:100', // paise
//       'currency' => 'nullable|string',
//     ]);
//     $currency = $data['currency'] ?? 'INR';

//     // record a "created" payment row (link later on confirm)
//     $p = Payment::create([
//       'mobile'   => $data['mobile'],
//       'amount'   => $data['amount'],
//       'currency' => $currency,
//       'status'   => 'created',
//     ]);

//     // create Razorpay order
//     $keyId = config('services.razorpay.key_id');
//     $keySecret = config('services.razorpay.key_secret');

//     $ch = curl_init('https://api.razorpay.com/v1/orders');
//     curl_setopt_array($ch, [
//       CURLOPT_RETURNTRANSFER => true,
//       CURLOPT_USERPWD        => "$keyId:$keySecret",
//       CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
//       CURLOPT_POSTFIELDS     => json_encode([
//         'amount'   => $p->amount,
//         'currency' => $currency,
//         'receipt'  => "rcpt_{$p->id}",
//         'notes'    => ['mobile'=>$p->mobile],
//       ]),
//     ]);
//     $resp = curl_exec($ch);
//     if ($resp === false) {
//       return response()->json(['message'=>'Razorpay order failed'], 500);
//     }
//     $json = json_decode($resp, true);
//     $orderId = $json['id'] ?? null;

//     $p->order_id = $orderId;
//     $p->save();

//     return response()->json([
//       'order_id' => $orderId,
//       'amount'   => $p->amount,
//       'currency' => $currency,
//       'key_id'   => $keyId,   // public key for client checkout
//       'payment_row_id' => $p->id,
//     ]);
//   }

//   // STUDENT — confirm & verify signature, mark paid, extend access
//   public function confirm(Request $req) {
//     $data = $req->validate([
//       'mobile'     => 'required',
//       'order_id'   => 'required',
//       'payment_id' => 'required',
//       'signature'  => 'required',
//     ]);

//     $keySecret = config('services.razorpay.key_secret');
//     $payload   = $data['order_id'].'|'.$data['payment_id'];
//     $expected  = hash_hmac('sha256', $payload, $keySecret);

//     if (!hash_equals($expected, $data['signature'])) {
//       return response()->json(['message'=>'Signature mismatch'], 422);
//     }

//     $p = Payment::where('order_id',$data['order_id'])->first();
//     if (!$p) return response()->json(['message'=>'Order not found'], 404);

//     $p->update([
//       'payment_id' => $data['payment_id'],
//       'status'     => 'paid',
//       'paid_at'    => now(),
//     ]);

//     // Extend access by a month from the later of today or current paid_until
//     $u = ClassroomUser::where('mobile',$data['mobile'])->first();
//     if ($u) {
//       $from = $u->paid_until ? Carbon::parse($u->paid_until) : Carbon::today();
//       if ($from->isPast()) $from = Carbon::today();
//       $u->paid_until = $from->copy()->addMonth();
//       $u->save();
//     }

//     return response()->json(['message'=>'Payment verified','paid_until'=>$u->paid_until ?? null]);
//   }
// }

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Offering;
use App\Models\StudentSubscription;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class PaymentsController extends Controller
{
    // Create order for a specific offering
    public function createOrder(Request $request)
    {
        $data = $request->validate([
            'mobile'      => 'required',
            'offering_id' => 'required|integer|exists:offerings,id',
        ]);

        $off = Offering::findOrFail($data['offering_id']);

        // TODO: create order using Razorpay Orders API with your secret.
        // For dev/testing, we return a mock order_id so your web/mobile flow works.
        $orderId = 'order_'.Str::random(12);

        return response()->json([
            'order_id' => $orderId,
            'key'      => env('RAZORPAY_KEY_ID', 'rzp_test_xxxxxxxx'),
            'amount'   => $off->price_paise,
            'currency' => $off->currency,
            'subject'  => $off->subjectname,
            'teacher_mobile' => $off->teacher_mobile,
        ]);
    }

    // Confirm payment & grant subscription
    public function confirm(Request $request)
    {
        $data = $request->validate([
            'mobile'     => 'required',
            'order_id'   => 'required',
            'payment_id' => 'required',
            'signature'  => 'required',
            // optionally you can pass offering_id from FE, or look up via order storage if you persist it
            'offering_id'=> 'nullable|integer|exists:offerings,id',
            'subject'    => 'nullable|string',
            'teacher_mobile' => 'nullable|string',
        ]);

        // TODO: verify Razorpay signature here with your secret.
        // Assuming OK, we grant/extend subscription 30 days:
        $now = Carbon::now();

        // Resolve target subject/teacher (prefer offering, fallback to request fields)
        if ($data['offering_id'] ?? null) {
            $off = Offering::find($data['offering_id']);
            $subject = $off->subjectname;
            $teacher = $off->teacher_mobile;
            $months  = 1; // or off-specific duration
        } else {
            $subject = $data['subject'] ?? '';
            $teacher = $data['teacher_mobile'] ?? '';
            $months  = 1;
        }

        // find existing active sub to extend, else create new
        $sub = StudentSubscription::where('student_mobile', $data['mobile'])
            ->where('subjectname', $subject)
            ->where('teacher_mobile', $teacher)
            ->where('valid_to', '>=', $now)
            ->orderBy('valid_to', 'desc')
            ->first();

        if ($sub) {
            $sub->update([
                'valid_to' => Carbon::parse($sub->valid_to)->addMonths($months),
                'status'   => 'active',
            ]);
        } else {
            StudentSubscription::create([
                'student_mobile' => $data['mobile'],
                'subjectname'    => $subject,
                'teacher_mobile' => $teacher,
                'valid_from'     => $now,
                'valid_to'       => $now->copy()->addMonths($months),
                'status'         => 'active',
            ]);
        }

        return response()->json(['message' => 'Payment confirmed & access granted']);
    }

    // Admin: grant a trial for a specific offering (or subject/teacher)
    public function grantTrial(Request $request)
    {
        $data = $request->validate([
            'mobile'      => 'required',
            'days'        => 'required|integer|min:1|max:60',
            'offering_id' => 'nullable|integer|exists:offerings,id',
            'subject'     => 'nullable|string',
            'teacher_mobile' => 'nullable|string',
        ]);

        $now = Carbon::now();

        if ($data['offering_id'] ?? null) {
            $off = \App\Models\Offering::find($data['offering_id']);
            $subject = $off->subjectname;
            $teacher = $off->teacher_mobile;
        } else {
            $subject = $data['subject'] ?? '';
            $teacher = $data['teacher_mobile'] ?? '';
        }

        StudentSubscription::create([
            'student_mobile' => $data['mobile'],
            'subjectname'    => $subject,
            'teacher_mobile' => $teacher,
            'valid_from'     => $now,
            'valid_to'       => $now->copy()->addDays($data['days']),
            'status'         => 'trial',
        ]);

        return response()->json(['message' => 'Trial granted']);
    }
}
