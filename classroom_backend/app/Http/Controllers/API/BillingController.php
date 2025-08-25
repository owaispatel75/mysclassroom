<?php

// app/Http/Controllers/API/BillingController.php
// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
// use Illuminate\Support\Facades\DB;
// // use App\Http\Controllers\API\Schema;
// use Illuminate\Support\Facades\Schema;
// use Razorpay\Api\Api; // composer require razorpay/razorpay:^2.9
// use Illuminate\Support\Carbon;

// class BillingController extends Controller
// {
//     private function ratePaise(): int
//     {
//         // Option A: DB settings
//         $row = DB::table('app_settings')->where('key', 'per_lecture_rate_paise')->first();
//         if ($row) return (int) $row->value;
//         // Option B: fallback constant
//         return 1000; // ₹10 per lecture
//     }

//     // GET /api/payments/me?mobile=...
//     public function myBilling(Request $request)
//     {
//         try {
//             $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

//             // Fallbacks if tables/rows do not exist yet
//             $rate = 1000;
//             if (Schema::hasTable('app_settings')) {
//                 $val = DB::table('app_settings')->where('key', 'per_lecture_rate_paise')->value('value');
//                 if (is_numeric($val)) $rate = (int)$val;
//             }

//             $bySubject = [];
//             $total = 0;

//             if (Schema::hasTable('lecture_attendance')) {
//                 $rows = DB::table('lecture_attendance')
//                     ->select('subjectname', DB::raw('COUNT(*) as cnt'))
//                     ->where('student_mobile', $mobile)
//                     ->whereNull('invoice_id')
//                     ->groupBy('subjectname')
//                     ->get();

//                 foreach ($rows as $r) {
//                     $bySubject[$r->subjectname] = (int)$r->cnt;
//                     $total += (int)$r->cnt;
//                 }
//             }

//             $amount = $total * $rate;

//             $history = Schema::hasTable('payments')
//                 ? Payment::where('mobile', $mobile)->orderBy('created_at', 'desc')->limit(30)->get()
//                 : collect([]);

//             return response()->json([
//                 'billing_model' => 'per_lecture',
//                 'rate_paise'    => $rate,
//                 'pending'       => [
//                     'total_lectures' => $total,
//                     'by_subject'     => $bySubject,   // Map<String,int>
//                     'amount_paise'   => $amount,
//                     'currency'       => 'INR',
//                 ],
//                 'history'       => $history,          // List
//             ]);
//         } catch (\Throwable $e) {
//             // Always JSON (no HTML error page)
//             return response()->json([
//                 'error'   => 'billing_failed',
//                 'message' => $e->getMessage(),
//             ], 500);
//         }
//     }

//     // POST /api/payments/create-order { mobile }
//     public function createOrder(Request $request)
//     {
//         try {
//             $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

//             $rate = 1000;
//             if (Schema::hasTable('app_settings')) {
//                 $val = DB::table('app_settings')->where('key','per_lecture_rate_paise')->value('value');
//                 if (is_numeric($val)) $rate = (int)$val;
//             }

//             $pendingCount = 0;
//             if (Schema::hasTable('lecture_attendance')) {
//                 $pendingCount = (int) DB::table('lecture_attendance')
//                     ->where('student_mobile', $mobile)
//                     ->whereNull('invoice_id')
//                     ->count();
//             }

//             if ($pendingCount <= 0) {
//                 return response()->json(['message' => 'Nothing to pay'], 422);
//             }

//             $amount = $pendingCount * $rate;
//             $orderId = 'order_'.bin2hex(random_bytes(8));

//             if (Schema::hasTable('payments')) {
//                 Payment::create([
//                     'mobile'   => $mobile,
//                     'amount'   => $amount,
//                     'currency' => 'INR',
//                     'status'   => 'created',
//                     'order_id' => $orderId,
//                     'notes'    => [
//                         'billing_model' => 'per_lecture',
//                         'lectures'      => $pendingCount,
//                         'rate_paise'    => $rate,
//                     ],
//                 ]);
//             }

//             return response()->json([
//                 'order_id' => $orderId,
//                 'key'      => config('services.razorpay.key_id', 'rzp_test_xxxxx'),
//                 'amount'   => $amount,
//                 'currency' => 'INR',
//             ]);
//         } catch (\Throwable $e) {
//             return response()->json([
//                 'error'   => 'create_order_failed',
//                 'message' => $e->getMessage(),
//             ], 500);
//         }
//     }

//     // POST /api/payments/confirm { mobile, order_id, payment_id, signature }
//     public function confirm(Request $request)
//     {
//         try {
//             $data = $request->validate([
//                 'mobile'     => 'required|string',
//                 'order_id'   => 'required|string',
//                 'payment_id' => 'required|string',
//                 'signature'  => 'required|string',
//             ]);

//             if (!Schema::hasTable('payments')) {
//                 return response()->json(['message' => 'ok (no payments table yet)']);
//             }

//             $p = Payment::where('mobile', $data['mobile'])
//                 ->where('order_id', $data['order_id'])
//                 ->firstOrFail();

//             $p->update([
//                 'status'     => 'paid',
//                 'payment_id' => $data['payment_id'],
//                 'paid_at'    => now(),
//             ]);

//             return response()->json(['message' => 'ok']);
//         } catch (\Throwable $e) {
//             return response()->json([
//                 'error'   => 'confirm_failed',
//                 'message' => $e->getMessage(),
//             ], 500);
//         }
//     }

//     // // GET /api/payments/me?mobile=...
//     // public function myBilling(Request $request)
//     // {
//     //     $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

//     //     $rate = (int) (DB::table('app_settings')
//     //         ->where('key', 'per_lecture_rate_paise')
//     //         ->value('value') ?? 1000);

//     //     // unbilled attendance rows
//     //     $rows = DB::table('lecture_attendance')
//     //         ->select('subjectname', DB::raw('COUNT(*) as cnt'))
//     //         ->where('student_mobile', $mobile)
//     //         ->whereNull('invoice_id')
//     //         ->groupBy('subjectname')
//     //         ->get();

//     //     $bySubject = [];
//     //     $total = 0;
//     //     foreach ($rows as $r) {
//     //         $bySubject[$r->subjectname] = (int) $r->cnt;
//     //         $total += (int) $r->cnt;
//     //     }

//     //     $amount = $total * $rate;

//     //     $history = Payment::where('mobile', $mobile)
//     //         ->orderBy('created_at', 'desc')
//     //         ->limit(30)
//     //         ->get();

//     //     return response()->json([
//     //         'billing_model' => 'per_lecture',
//     //         'rate_paise'    => $rate,
//     //         'pending'       => [
//     //             'total_lectures' => $total,
//     //             'by_subject'     => $bySubject,     // <-- MAP
//     //             'amount_paise'   => $amount,
//     //             'currency'       => 'INR',
//     //         ],
//     //         'history'       => $history,            // <-- LIST
//     //     ]);
//     // }

//     // // POST /api/payments/create-order   { mobile }
//     // public function createOrder(Request $request)
//     // {
//     //     $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

//     //     $rate = (int) (DB::table('app_settings')
//     //         ->where('key', 'per_lecture_rate_paise')
//     //         ->value('value') ?? 1000);

//     //     $pendingCount = (int) DB::table('lecture_attendance')
//     //         ->where('student_mobile', $mobile)
//     //         ->whereNull('invoice_id')
//     //         ->count();

//     //     if ($pendingCount <= 0) {
//     //         return response()->json(['message' => 'Nothing to pay'], 422);
//     //     }

//     //     $amount = $pendingCount * $rate;

//     //     // Normally create Razorpay order here; for dev we mock an id:
//     //     $orderId = 'order_'.bin2hex(random_bytes(8));

//     //     Payment::create([
//     //         'mobile'   => $mobile,
//     //         'amount'   => $amount,
//     //         'currency' => 'INR',
//     //         'status'   => 'created',
//     //         'order_id' => $orderId,
//     //         'notes'    => [
//     //             'billing_model' => 'per_lecture',
//     //             'lectures'      => $pendingCount,
//     //             'rate_paise'    => $rate,
//     //         ],
//     //     ]);

//     //     return response()->json([
//     //         'order_id' => $orderId,
//     //         'key'      => config('services.razorpay.key_id', 'rzp_test_xxxxx'),
//     //         'amount'   => $amount,
//     //         'currency' => 'INR',
//     //     ]);
//     // }

//     // // POST /api/payments/confirm { mobile, order_id, payment_id, signature }
//     // public function confirm(Request $request)
//     // {
//     //     $data = $request->validate([
//     //         'mobile'     => 'required|string',
//     //         'order_id'   => 'required|string',
//     //         'payment_id' => 'required|string',
//     //         'signature'  => 'required|string',
//     //     ]);

//     //     // TODO: verify Razorpay signature
//     //     $p = Payment::where('mobile', $data['mobile'])
//     //         ->where('order_id', $data['order_id'])
//     //         ->firstOrFail();

//     //     $p->update([
//     //         'status'     => 'paid',
//     //         'payment_id' => $data['payment_id'],
//     //         'paid_at'    => now(),
//     //     ]);

//     //     return response()->json(['message' => 'ok']);
//     // }

//     // public function myBilling(Request $request)
//     // {
//     //     $mobile = $request->query('mobile');
//     //     if (!$mobile) return response()->json(['message' => 'mobile required'], 422);

//     //     // Unbilled attendance
//     //     $rows = DB::table('lecture_attendance')
//     //         ->where('student_mobile', $mobile)
//     //         ->whereNull('invoice_id')
//     //         ->orderBy('attended_at', 'desc')
//     //         ->get();

//     //     $bySubject = [];
//     //     foreach ($rows as $r) {
//     //         $bySubject[$r->subjectname] = ($bySubject[$r->subjectname] ?? 0) + 1;
//     //     }
//     //     $totalLectures = count($rows);
//     //     $rate = $this->ratePaise();
//     //     $amount = $totalLectures * $rate;

//     //     // Payment history from invoices + payments (minimal)
//     //     $invoices = DB::table('invoices')
//     //         ->where('student_mobile', $mobile)
//     //         ->orderBy('created_at', 'desc')
//     //         ->get();

//     //     $history = [];
//     //     foreach ($invoices as $inv) {
//     //         $history[] = [
//     //             'id'        => $inv->id,
//     //             'mobile'    => $mobile,
//     //             'amount'    => (int) $inv->amount,
//     //             'currency'  => $inv->currency,
//     //             'status'    => $inv->paid_at ? 'paid' : 'created',
//     //             'created_at'=> Carbon::parse($inv->created_at)->toIso8601String(),
//     //             'paid_at'   => $inv->paid_at ? Carbon::parse($inv->paid_at)->toIso8601String() : null,
//     //         ];
//     //     }

//     //     return response()->json([
//     //         'billing_model'  => 'per_lecture',
//     //         'rate_paise'     => $rate,
//     //         'pending'        => [
//     //             'total_lectures' => $totalLectures,
//     //             'by_subject'     => $bySubject,
//     //             'amount_paise'   => $amount,
//     //             'currency'       => 'INR',
//     //         ],
//     //         'history'        => $history,
//     //     ]);
//     // }

//     //old code
//     // public function myBilling(Request $request) {
//     // $mobile = $request->query('mobile');
//     // $rate = (int) (\DB::table('app_settings')->where('key','per_lecture_rate_paise')->value('value') ?? 1000);

//     // // unbilled attendance grouped by subject
//     // $bySubject = DB::table('lecture_attendance')
//     //     ->select('subjectname', DB::raw('COUNT(*) as cnt'))
//     //     ->where('student_mobile', $mobile)
//     //     ->whereNull('invoice_id')
//     //     ->groupBy('subjectname')
//     //     ->pluck('cnt', 'subjectname'); // <- returns map: subject => count

//     // $total = array_sum($bySubject->toArray());

//     // return response()->json([
//     //     'billing_model' => 'per_lecture',
//     //     'rate_paise'    => $rate,
//     //     'pending' => [
//     //         'total_lectures' => $total,
//     //         'by_subject'     => $bySubject,     // <-- Map, not List
//     //         'amount_paise'   => $total * $rate,
//     //         'currency'       => 'INR',
//     //     ],
//     //     'history' => [], // your paid rows if any
//     //     ]);
//     // }

//     //old code
//     // public function createOrder(Request $request)
//     // {
//     //     $data = $request->validate(['mobile' => 'required']);
//     //     $mobile = $data['mobile'];

//     //     // calculate unbilled
//     //     $count = DB::table('lecture_attendance')
//     //         ->where('student_mobile', $mobile)
//     //         ->whereNull('invoice_id')
//     //         ->count();

//     //     $rate = $this->ratePaise();
//     //     $amount = $count * $rate;

//     //     if ($amount <= 0) {
//     //         return response()->json(['message' => 'Nothing to bill'], 422);
//     //     }

//     //     // Razorpay order
//     //     $key    = env('RAZORPAY_KEY_ID');
//     //     $secret = env('RAZORPAY_KEY_SECRET');
//     //     $api = new Api($key, $secret);

//     //     $order = $api->order->create([
//     //         'amount'          => $amount,
//     //         'currency'        => 'INR',
//     //         'payment_capture' => 1,
//     //         'notes'           => ['mobile' => $mobile, 'type' => 'per_lecture'],
//     //     ]);

//     //     // create local invoice (unpaid)
//     //     $invoiceId = DB::table('invoices')->insertGetId([
//     //         'student_mobile'     => $mobile,
//     //         'lectures_count'     => $count,
//     //         'amount'             => $amount,
//     //         'currency'           => 'INR',
//     //         'razorpay_order_id'  => $order['id'],
//     //         'created_at'         => now(),
//     //         'updated_at'         => now(),
//     //     ]);

//     //     return response()->json([
//     //         'key'        => $key,
//     //         'order_id'   => $order['id'],
//     //         'amount'     => $amount,
//     //         'currency'   => 'INR',
//     //         'invoice_id' => $invoiceId,
//     //     ]);
//     // }

//     // old
//     // public function confirm(Request $request)
//     // {
//     //     $data = $request->validate([
//     //         'mobile'      => 'required',
//     //         'order_id'    => 'required',
//     //         'payment_id'  => 'required',
//     //         'signature'   => 'required',
//     //     ]);

//     //     $secret = env('RAZORPAY_KEY_SECRET');
//     //     $generated = hash_hmac('sha256', $data['order_id'].'|'.$data['payment_id'], $secret);
//     //     if (!hash_equals($generated, $data['signature'])) {
//     //         return response()->json(['message' => 'Invalid signature'], 422);
//     //     }

//     //     $inv = DB::table('invoices')->where('razorpay_order_id', $data['order_id'])->first();
//     //     if (!$inv) return response()->json(['message' => 'Invoice not found'], 404);

//     //     // DB::transaction(function () use ($inv, $data) {
//     //     //     // deterministically pick earliest unbilled rows
//     //     //     $rows = DB::table('lecture_attendance')
//     //     //         ->where('student_mobile', $data['mobile'])
//     //     //         ->whereNull('invoice_id')
//     //     //         ->orderBy('attended_at', 'asc')
//     //     //         ->limit($inv->lectures_count)
//     //     //         ->lockForUpdate()
//     //     //         ->get();

//     //     //     // attach exactly those ids
//     //     //     $ids = $rows->pluck('id')->all();
//     //     //     if ($ids) {
//     //     //         DB::table('lecture_attendance')
//     //     //             ->whereIn('id', $ids)
//     //     //             ->update([
//     //     //                 'invoice_id' => $inv->id,
//     //     //                 'updated_at' => now(),
//     //     //             ]);
//     //     //     }

//     //     //     DB::table('invoices')->where('id', $inv->id)->update([
//     //     //         'razorpay_payment_id' => $data['payment_id'],
//     //     //         'razorpay_signature'  => $data['signature'],
//     //     //         'paid_at'             => now(),
//     //     //         'updated_at'          => now(),
//     //     //     ]);
//     //     // });

//     //     DB::transaction(function () use ($inv, $data) {
//     //     $rows = DB::table('lecture_attendance')
//     //         ->where('student_mobile', $data['mobile'])
//     //         ->whereNull('invoice_id')
//     //         ->orderBy('attended_at', 'asc')
//     //         ->limit($inv->lectures_count)
//     //         ->lockForUpdate()
//     //         ->get();

//     //     $ids = $rows->pluck('id')->all();
//     //     if ($ids) {
//     //         DB::table('lecture_attendance')
//     //             ->whereIn('id', $ids)
//     //             ->update(['invoice_id' => $inv->id, 'updated_at' => now()]);
//     //     }

//     //     DB::table('invoices')->where('id', $inv->id)->update([
//     //         'razorpay_payment_id' => $data['payment_id'],
//     //         'razorpay_signature'  => $data['signature'],
//     //         'paid_at'             => now(),
//     //         'updated_at'          => now(),
//     //     ]);
//     //     });


//     //     return response()->json(['message' => 'Payment confirmed']);
//     // }


//     // public function confirm(Request $request)
//     // {
//     //     $data = $request->validate([
//     //         'mobile'      => 'required',
//     //         'order_id'    => 'required',
//     //         'payment_id'  => 'required',
//     //         'signature'   => 'required',
//     //     ]);

//     //     $key    = env('RAZORPAY_KEY_ID');
//     //     $secret = env('RAZORPAY_KEY_SECRET');

//     //     // verify signature
//     //     $generated = hash_hmac('sha256', $data['order_id'].'|'.$data['payment_id'], $secret);
//     //     if (!hash_equals($generated, $data['signature'])) {
//     //         return response()->json(['message' => 'Invalid signature'], 422);
//     //     }

//     //     // find invoice
//     //     $inv = DB::table('invoices')->where('razorpay_order_id', $data['order_id'])->first();
//     //     if (!$inv) return response()->json(['message' => 'Invoice not found'], 404);

//     //     // attach attendance rows to invoice (only null invoice_id)
//     //     DB::table('lecture_attendance')
//     //         ->where('student_mobile', $data['mobile'])
//     //         ->whereNull('invoice_id')
//     //         ->limit($inv->lectures_count) // lock exactly the set counted at order time
//     //         ->update([
//     //             'invoice_id' => $inv->id,
//     //             'updated_at' => now(),
//     //         ]);

//     //     // mark invoice paid
//     //     DB::table('invoices')->where('id', $inv->id)->update([
//     //         'razorpay_payment_id' => $data['payment_id'],
//     //         'razorpay_signature'  => $data['signature'],
//     //         'paid_at'             => now(),
//     //         'updated_at'          => now(),
//     //     ]);

//     //     return response()->json(['message' => 'Payment confirmed']);
//     // }
// }

//working starts

// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
// use Illuminate\Support\Facades\DB;
// use Illuminate\Support\Facades\Schema;
// use App\Models\Payment;              // ✅ add this
// // use Razorpay\Api\Api;             // (not used right now)
// // use Illuminate\Support\Carbon;    // (not used right now)

// class BillingController extends Controller
// {
//     private function ratePaise(): int
//     {
//         $row = DB::table('app_settings')->where('key', 'per_lecture_rate_paise')->first();
//         if ($row && is_numeric($row->value)) return (int) $row->value;
//         return 1000; // ₹10 per lecture
//     }

//     // GET /api/payments/me?mobile=...
//     public function myBilling(Request $request)
//     {
//         try {
//             $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

//             $rate = $this->ratePaise();

//             $bySubject = [];
//             $total = 0;

//             if (Schema::hasTable('lecture_attendance')) {
//                 $rows = DB::table('lecture_attendance')
//                     ->select('subjectname', DB::raw('COUNT(*) as cnt'))
//                     ->where('student_mobile', $mobile)
//                     ->whereNull('invoice_id')
//                     ->groupBy('subjectname')
//                     ->get();

//                 foreach ($rows as $r) {
//                     $bySubject[$r->subjectname] = (int) $r->cnt;
//                     $total += (int) $r->cnt;
//                 }
//             }

//             $amount = $total * $rate;

//             $history = Schema::hasTable('payments')
//                 ? Payment::where('mobile', $mobile)
//                     ->orderBy('created_at', 'desc')
//                     ->limit(30)
//                     ->get(['id','mobile','amount','currency','status','created_at','paid_at'])
//                 : collect([]);

//             return response()->json([
//                 'billing_model' => 'per_lecture',
//                 'rate_paise'    => $rate,
//                 'pending'       => [
//                     'total_lectures' => $total,
//                     'by_subject'     => $bySubject,   // Map<String, int>
//                     'amount_paise'   => $amount,
//                     'currency'       => 'INR',
//                 ],
//                 'history'       => $history,          // List
//             ]);
//         } catch (\Throwable $e) {
//             return response()->json([
//                 'error'   => 'billing_failed',
//                 'message' => $e->getMessage(),
//             ], 500);
//         }
//     }

//     // POST /api/payments/create-order { mobile }
//     public function createOrder(Request $request)
//     {
//         try {
//             $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

//             $rate = $this->ratePaise();

//             $pendingCount = 0;
//             if (Schema::hasTable('lecture_attendance')) {
//                 $pendingCount = (int) DB::table('lecture_attendance')
//                     ->where('student_mobile', $mobile)
//                     ->whereNull('invoice_id')
//                     ->count();
//             }

//             if ($pendingCount <= 0) {
//                 return response()->json(['message' => 'Nothing to pay'], 422);
//             }

//             $amount  = $pendingCount * $rate;
//             $orderId = 'order_'.bin2hex(random_bytes(8));

//             if (Schema::hasTable('payments')) {
//                 Payment::create([
//                     'mobile'   => $mobile,
//                     'amount'   => $amount,
//                     'currency' => 'INR',
//                     'status'   => 'created',
//                     'order_id' => $orderId,
//                     'notes'    => [
//                         'billing_model' => 'per_lecture',
//                         'lectures'      => $pendingCount,
//                         'rate_paise'    => $rate,
//                     ],
//                 ]);
//             }

//             return response()->json([
//                 'order_id' => $orderId,
//                 'key'      => config('services.razorpay.key_id', 'rzp_test_xxxxx'),
//                 'amount'   => $amount,
//                 'currency' => 'INR',
//             ]);
//         } catch (\Throwable $e) {
//             return response()->json([
//                 'error'   => 'create_order_failed',
//                 'message' => $e->getMessage(),
//             ], 500);
//         }
//     }

//     // POST /api/payments/confirm { mobile, order_id, payment_id, signature }
//     public function confirm(Request $request)
//     {
//         try {
//             $data = $request->validate([
//                 'mobile'     => 'required|string',
//                 'order_id'   => 'required|string',
//                 'payment_id' => 'required|string',
//                 'signature'  => 'required|string',
//             ]);

//             if (!Schema::hasTable('payments')) {
//                 return response()->json(['message' => 'ok (no payments table yet)']);
//             }

//             $p = Payment::where('mobile', $data['mobile'])
//                 ->where('order_id', $data['order_id'])
//                 ->firstOrFail();

//             // (Signature verification can be added here if/when you wire Razorpay fully)
//             $p->update([
//                 'status'     => 'paid',
//                 'payment_id' => $data['payment_id'],
//                 'paid_at'    => now(),
//             ]);

//             return response()->json(['message' => 'ok']);
//         } catch (\Throwable $e) {
//             return response()->json([
//                 'error'   => 'confirm_failed',
//                 'message' => $e->getMessage(),
//             ], 500);
//         }
//     }
// }

//working ends


namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Carbon;
use App\Models\Payment;

class BillingController extends Controller
{
    // GET /api/payments/me?mobile=...
    public function myBilling(Request $request)
    {
        try {
            $mobile = $request->validate(['mobile' => 'required|string'])['mobile'];

            // 1) Pull pending attendance by subject+teacher
            $pending = [];
            if (Schema::hasTable('lecture_attendance')) {
                $rows = DB::table('lecture_attendance')
                    ->select('subjectname','teacher_mobile', DB::raw('COUNT(*) as cnt'))
                    ->where('student_mobile', $mobile)
                    ->whereNull('invoice_id')
                    ->groupBy('subjectname','teacher_mobile')
                    ->get();

                foreach ($rows as $r) {
                    $key = $r->subjectname . '|' . (string)$r->teacher_mobile;
                    $pending[$key] = [
                        'subjectname'    => $r->subjectname,
                        'teacher_mobile' => (string)$r->teacher_mobile,
                        'count'          => (int)$r->cnt,
                    ];
                }
            }

            // 2) Build a price map from offerings
            $priceMap = [];
            if (Schema::hasTable('offerings')) {
                $offRows = DB::table('offerings')->where('active',1)->get();
                foreach ($offRows as $o) {
                    $key = $o->subjectname . '|' . $o->teacher_mobile;
                    $priceMap[$key] = (int)$o->price_paise;
                }
            }

            // Fallback global rate (used only if a subject+teacher is missing in offerings)
            $globalRate = 1000;
            if (Schema::hasTable('app_settings')) {
                $val = DB::table('app_settings')->where('key','per_lecture_rate_paise')->value('value');
                if (is_numeric($val)) $globalRate = (int)$val;
            }

            // 3) Compute per-subject amounts
            $bySubject = [];          // { "Maths|98765": {count, rate_paise, amount_paise, subjectname, teacher_mobile} }
            $amountTotal = 0;
            $countTotal  = 0;

            foreach ($pending as $key => $row) {
                $rate = $priceMap[$key] ?? $globalRate;
                $amt  = $rate * $row['count'];
                $bySubject[$key] = [
                    'subjectname'    => $row['subjectname'],
                    'teacher_mobile' => $row['teacher_mobile'],
                    'count'          => $row['count'],
                    'rate_paise'     => $rate,
                    'amount_paise'   => $amt,
                ];
                $amountTotal += $amt;
                $countTotal  += $row['count'];
            }

            $history = Schema::hasTable('payments')
                ? Payment::where('mobile', $mobile)->orderBy('created_at','desc')->limit(30)->get()
                : collect([]);

            return response()->json([
                'billing_model' => 'per_lecture_per_subject',
                'pending' => [
                    'total_lectures'   => $countTotal,
                    'amount_paise'     => $amountTotal,
                    'currency'         => 'INR',
                    'by_subject'       => array_values($bySubject), // list of objects
                    'fallback_rate'    => $globalRate,
                ],
                'history' => $history,
            ]);
        } catch (\Throwable $e) {
            return response()->json(['error'=>'billing_failed','message'=>$e->getMessage()], 500);
        }
    }

    // POST /api/payments/create-order { mobile }
    public function createOrder(Request $request)
    {
        try {
            $mobile = $request->validate(['mobile'=>'required|string'])['mobile'];

            // recompute totals exactly like myBilling()
            $pending = DB::table('lecture_attendance')
                ->select('subjectname','teacher_mobile', DB::raw('COUNT(*) as cnt'))
                ->where('student_mobile', $mobile)
                ->whereNull('invoice_id')
                ->groupBy('subjectname','teacher_mobile')
                ->get();

            if ($pending->isEmpty()) {
                return response()->json(['message' => 'Nothing to pay'], 422);
            }

            $globalRate = 1000;
            if (Schema::hasTable('app_settings')) {
                $val = DB::table('app_settings')->where('key','per_lecture_rate_paise')->value('value');
                if (is_numeric($val)) $globalRate = (int)$val;
            }

            $offRows = DB::table('offerings')->where('active',1)->get();
            $priceMap = [];
            foreach ($offRows as $o) {
                $priceMap[$o->subjectname . '|' . $o->teacher_mobile] = (int)$o->price_paise;
            }

            $amountTotal = 0;
            $lineItems = [];
            foreach ($pending as $r) {
                $key  = $r->subjectname.'|'.$r->teacher_mobile;
                $rate = $priceMap[$key] ?? $globalRate;
                $cnt  = (int)$r->cnt;
                $amt  = $rate * $cnt;
                $amountTotal += $amt;

                $lineItems[] = [
                    'subjectname'    => $r->subjectname,
                    'teacher_mobile' => $r->teacher_mobile,
                    'count'          => $cnt,
                    'rate_paise'     => $rate,
                    'amount_paise'   => $amt,
                ];
            }

            if ($amountTotal <= 0) {
                return response()->json(['message' => 'Nothing to pay'], 422);
            }

            $orderId = 'order_'.bin2hex(random_bytes(8));

            if (Schema::hasTable('payments')) {
                Payment::create([
                    'mobile'   => $mobile,
                    'amount'   => $amountTotal,
                    'currency' => 'INR',
                    'status'   => 'created',
                    'order_id' => $orderId,
                    'notes'    => [
                        'billing_model' => 'per_lecture_per_subject',
                        'items'         => $lineItems, // detailed breakdown
                    ],
                ]);
            }

            return response()->json([
                'order_id' => $orderId,
                'key'      => config('services.razorpay.key_id', 'rzp_test_xxxxx'),
                'amount'   => $amountTotal,
                'currency' => 'INR',
            ]);
        } catch (\Throwable $e) {
            return response()->json(['error'=>'create_order_failed','message'=>$e->getMessage()], 500);
        }
    }

    // POST /api/payments/confirm { mobile, order_id, payment_id, signature }
    public function confirm(Request $request)
    {
        try {
            $data = $request->validate([
                'mobile'     => 'required|string',
                'order_id'   => 'required|string',
                'payment_id' => 'required|string',
                'signature'  => 'required|string',
            ]);

            if (!Schema::hasTable('payments')) {
                return response()->json(['message' => 'ok (no payments table yet)']);
            }

            $p = Payment::where('mobile',$data['mobile'])
                ->where('order_id',$data['order_id'])->firstOrFail();

            $p->update([
                'status'     => 'paid',
                'payment_id' => $data['payment_id'],
                'paid_at'    => now(),
            ]);

            // NOTE: attendance rows can be linked to an invoice/payment later if you want.
            return response()->json(['message' => 'ok']);
        } catch (\Throwable $e) {
            return response()->json(['error'=>'confirm_failed','message'=>$e->getMessage()], 500);
        }
    }
}
