<?php

// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use App\Models\StudentSubscription;
// use Illuminate\Http\Request;
// use Illuminate\Support\Carbon;

// class SubscriptionController extends Controller
// {
//     public function me(Request $request)
//     {
//         $request->validate(['mobile' => 'required']);
//         $mobile = $request->query('mobile');
//         $now = Carbon::now();

//         $subs = StudentSubscription::where('student_mobile', $mobile)
//             ->where('valid_to', '>=', $now)
//             ->orderBy('valid_to', 'desc')
//             ->get();

//         return response()->json([
//             'subscriptions' => $subs->map(fn($s) => [
//                 'subject'        => $s->subjectname,
//                 'teacher_mobile' => $s->teacher_mobile,
//                 'valid_from'     => $s->valid_from->toIso8601String(),
//                 'valid_to'       => $s->valid_to->toIso8601String(),
//                 'status'         => $s->status,
//             ]),
//         ]);
//     }

//     public function enroll(Request $request) {
//     $mobile = $request->input('mobile');
//     $subjectId = $request->input('subject_id');

//     DB::table('student_subscriptions')->updateOrInsert(
//         ['student_mobile' => $mobile, 'subject_id' => $subjectId],
//         ['status' => 'active', 'created_at' => now()]
//     );

//     return response()->json(['message' => 'Enrolled']);
//     }

//     public function unenroll(Request $request) {
//         $mobile = $request->input('mobile');
//         $subjectId = $request->input('subject_id');

//         DB::table('student_subscriptions')
//             ->where('student_mobile', $mobile)
//             ->where('subject_id', $subjectId)
//             ->delete();

//         return response()->json(['message' => 'Unenrolled']);
//     }

// }


namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use App\Models\Offering;
use App\Models\StudentSubscription;

class SubscriptionController extends Controller
{
    public function me(Request $request)
    {
        $request->validate(['mobile' => 'required']);
        $mobile = $request->query('mobile');
        $now = Carbon::now();

        $subs = StudentSubscription::where('student_mobile', $mobile)
            ->where('status', 'active')
            ->where('valid_to', '>=', $now)
            ->orderBy('valid_to', 'desc')
            ->get();

        return response()->json([
            'subscriptions' => $subs->map(fn ($s) => [
                'subject'        => $s->subjectname,
                'teacher_mobile' => $s->teacher_mobile,
                'valid_from'     => $s->valid_from->toIso8601String(),
                'valid_to'       => $s->valid_to->toIso8601String(),
                'status'         => $s->status,
            ]),
        ]);
    }

    public function enroll(Request $request)
    {
        try {
            $data = $request->validate([
                'mobile'     => 'required|string',
                'subject_id' => 'required|integer|exists:offerings,id',
            ]);

            $off = Offering::findOrFail($data['subject_id']);

            $from = Carbon::now();
            $to   = (clone $from)->addYears(5); // long-running access

            StudentSubscription::updateOrCreate(
                [
                    'student_mobile' => $data['mobile'],
                    'subjectname'    => $off->subjectname,
                    'teacher_mobile' => $off->teacher_mobile,
                ],
                [
                    'valid_from' => $from,
                    'valid_to'   => $to,
                    'status'     => 'active',
                ]
            );

            return response()->json(['ok' => true]);
        } catch (\Throwable $e) {
            return response()->json([
                'error'   => 'enroll_failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function unenroll(Request $request)
    {
        try {
            $data = $request->validate([
                'mobile'     => 'required|string',
                'subject_id' => 'required|integer|exists:offerings,id',
            ]);

            $off = Offering::findOrFail($data['subject_id']);

            StudentSubscription::where('student_mobile', $data['mobile'])
                ->where('subjectname', $off->subjectname)
                ->where('teacher_mobile', $off->teacher_mobile)
                ->update([
                    'status'   => 'inactive',
                    'valid_to' => Carbon::now(),
                ]);

            return response()->json(['ok' => true]);
        } catch (\Throwable $e) {
            return response()->json([
                'error'   => 'unenroll_failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
