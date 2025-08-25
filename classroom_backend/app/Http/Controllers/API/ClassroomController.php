<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class ClassroomController extends Controller
{
    /**
     * GET /api/classrooms/today
     * Returns today's sessions that have NOT finished yet.
     * Optional filters later: ?classroomid=... or by student mapping.
     */
    // public function today(Request $request)
    // {
    //     $now   = Carbon::now();
    //     $start = $now->copy()->startOfDay();
    //     $end   = $now->copy()->endOfDay();

    //     // Base query for today
    //     $q = DB::table('classroomsubjectdetails')
    //         ->select(
    //             'id',
    //             'classroomid',
    //             'classroomname',
    //             'classroommobile',
    //             'subjectname',
    //             'subjectstarttime',
    //             'subjectduration',
    //             'subjectendtime',
    //             'status'
    //         )
    //         ->whereBetween('subjectstarttime', [$start, $end])
    //         ->orderBy('subjectstarttime');

    //     // (Optional) filter by classroom/grade later
    //     if ($request->filled('classroomid')) {
    //         $q->where('classroomid', $request->integer('classroomid'));
    //     }

    //     $rows = $q->get();

    //     // inside today(Request $request) before returning $sessions
    //     $studentMobile = $request->query('mobile'); // only passed by student FE
    //     if ($studentMobile) {
    //         $now = \Illuminate\Support\Carbon::now();
    //         $entitled = \App\Models\StudentSubscription::where('student_mobile', $studentMobile)
    //             ->where('valid_to', '>=', $now)
    //             ->get(['subjectname', 'teacher_mobile']);
    //         // Build a set of allowed pairs
    //         $allow = [];
    //         foreach ($entitled as $e) {
    //             $allow[] = [$e->subjectname, $e->teacher_mobile];
    //         }
    //         // Filter computed $sessions:
    //         $sessions = array_values(array_filter($sessions, function ($s) use ($allow) {
    //             foreach ($allow as $pair) {
    //                 if ($s['subject'] === $pair[0] && ($pair[1] ?? null) === request('classroommobile', $pair[1])) {
    //                     return true;
    //                 }
    //             }
    //             return false;
    //         }));
    //     }

    //     // Compute endAt and filter out finished sessions
    //     $sessions = [];
    //     foreach ($rows as $r) {
    //         $startAt = Carbon::parse($r->subjectstarttime);
    //         $endAt   = $r->subjectendtime
    //             ? Carbon::parse($r->subjectendtime)
    //             : (clone $startAt)->addMinutes((int) $r->subjectduration);

    //         if ($endAt->lte($now)) {
    //             // already ended -> skip (rule)
    //             continue;
    //         }

    //         // Status normalization (if teacher hasn't toggled, infer scheduled/live)
    //         $status = $r->status;
    //         if (!in_array($status, ['scheduled','live','ended'], true)) {
    //             $status = 'scheduled';
    //         }
    //         if ($status !== 'live') {
    //             if ($startAt->gt($now))     $status = 'scheduled';
    //             if ($startAt->lte($now))    $status = 'live'; // auto-live when window started (optional)
    //         }

    //         $sessions[] = [
    //             'id'              => $r->id,
    //             'subject'         => $r->subjectname,
    //             'start_at'        => $startAt->toIso8601String(),
    //             'end_at'          => $endAt->toIso8601String(),
    //             'duration_mins'   => (int) $r->subjectduration,
    //             'status'          => $status,                 // scheduled | live
    //             'joinable'        => $status === 'live',      // FE enables button
    //         ];
    //     }

    //     return response()->json(['sessions' => $sessions]);
    // }

    public function today(Request $request)
    {
        $now   = \Illuminate\Support\Carbon::now();
        $start = $now->copy()->startOfDay();
        $end   = $now->copy()->endOfDay();

        // Base query for today
        $q = \Illuminate\Support\Facades\DB::table('classroomsubjectdetails')
            ->select(
                'id',
                'classroomid',
                'classroomname',
                'classroommobile',     // teacher mobile
                'subjectname',
                'subjectstarttime',
                'subjectduration',
                'subjectendtime',
                'status'
            )
            ->whereBetween('subjectstarttime', [$start, $end])
            ->orderBy('subjectstarttime');

        // (Optional) filter by classroom/grade
        if ($request->filled('classroomid')) {
            $q->where('classroomid', $request->integer('classroomid'));
        }

        $rows = $q->get();

        // Compute endAt and filter out finished sessions
        $sessions = [];
        foreach ($rows as $r) {
            $startAt = \Illuminate\Support\Carbon::parse($r->subjectstarttime);
            $endAt   = $r->subjectendtime
                ? \Illuminate\Support\Carbon::parse($r->subjectendtime)
                : (clone $startAt)->addMinutes((int) $r->subjectduration);

            if ($endAt->lte($now)) {
                // already ended -> skip (rule)
                continue;
            }

            // Normalize status (optional auto-live when window started)
            $status = in_array($r->status, ['scheduled','live','ended'], true) ? $r->status : 'scheduled';
            if ($status !== 'live') {
                if     ($startAt->gt($now))  { $status = 'scheduled'; }
                elseif ($startAt->lte($now)) { $status = 'live'; }
            }

            $sessions[] = [
                'id'              => (int) $r->id,
                'subject'         => $r->subjectname,
                'teacher_mobile'  => $r->classroommobile,        // <-- include this so we can match
                'start_at'        => $startAt->toIso8601String(),
                'end_at'          => $endAt->toIso8601String(),
                'duration_mins'   => (int) $r->subjectduration,
                'status'          => $status,                    // scheduled | live
                'joinable'        => $status === 'live',
            ];
        }

        // Optional: filter by student’s active entitlements (subject + teacher)
        // Only run this when 'mobile' is provided by the student FE.
        if ($request->filled('mobile')) {
            $studentMobile = $request->query('mobile');

            // Adjust table/model to whatever you actually created for entitlements/enrollments.
            // Example assumes a `student_subscriptions` table with:
            //  - student_mobile
            //  - subjectname
            //  - teacher_mobile (nullable if subject-only)
            //  - valid_to (datetime)
            $entitled = \Illuminate\Support\Facades\DB::table('student_subscriptions')
                ->where('student_mobile', $studentMobile)
                ->where('valid_to', '>=', $now)
                ->get(['subjectname', 'teacher_mobile']);

            // Build a fast lookup set: "subject|teacher"
            $allow = [];
            foreach ($entitled as $e) {
                // If your subscription does not bind to a teacher, allow any teacher for that subject by using a wildcard marker.
                $key = $e->subjectname . '|' . ($e->teacher_mobile ?? '*');
                $allow[$key] = true;
            }

            $sessions = array_values(array_filter($sessions, function ($s) use ($allow) {
                $keyExact   = $s['subject'] . '|' . ($s['teacher_mobile'] ?? '');
                $keySubject = $s['subject'] . '|*';  // subject-only entitlement
                return isset($allow[$keyExact]) || isset($allow[$keySubject]);
            }));
        }

        return response()->json(['sessions' => $sessions]);
    }


    // GET /api/classrooms/teacher/today?mobile=9998887777
    // public function teacherToday(Request $request)
    // {
    //     $now   = Carbon::now();
    //     $start = $now->copy()->startOfDay();
    //     $end   = $now->copy()->endOfDay();

    //     $q = DB::table('classroomsubjectdetails')
    //         ->whereBetween('subjectstarttime', [$start, $end])
    //         ->orderBy('subjectstarttime');

    //     if ($request->filled('mobile')) { // filter this teacher’s subjects
    //         $q->where('classroommobile', $request->input('mobile'));
    //     }

    //     $rows = $q->get();

    //     $list = [];
    //     foreach ($rows as $r) {
    //         $startAt = Carbon::parse($r->subjectstarttime);
    //         $endAt   = $r->subjectendtime
    //             ? Carbon::parse($r->subjectendtime)
    //             : (clone $startAt)->addMinutes((int)$r->subjectduration);

    //         if ($endAt->lte($now)) continue; // hide finished

    //         $list[] = [
    //             'id'            => (int) $r->id,
    //             'subject'       => $r->subjectname,
    //             'start_at'      => $startAt->toIso8601String(),
    //             'end_at'        => $endAt->toIso8601String(),
    //             'duration_mins' => (int) $r->subjectduration,
    //             'status'        => $r->status ?: 'scheduled', // scheduled|live|ended
    //             'joinable'      => $status === 'live',
    //             'room_id'       => $r->zego_room_id,
    //         ];
    //     }

    //     return response()->json(['sessions' => $list]);
    // }

    public function teacherToday(Request $request)
    {
        $now   = Carbon::now();
        $start = $now->copy()->startOfDay();
        $end   = $now->copy()->endOfDay();

        $q = DB::table('classroomsubjectdetails')
            ->whereBetween('subjectstarttime', [$start, $end])
            ->orderBy('subjectstarttime');

        if ($request->filled('mobile')) {
            $q->where('classroommobile', $request->input('mobile'));
        }

        $rows = $q->get();

        $list = [];
        foreach ($rows as $r) {
            $startAt = Carbon::parse($r->subjectstarttime);
            $endAt   = $r->subjectendtime
                ? Carbon::parse($r->subjectendtime)
                : (clone $startAt)->addMinutes((int)$r->subjectduration);

            if ($endAt->lte($now)) continue;

            
            
            // normalize
            $status = in_array($r->status, ['scheduled','live','ended'], true) ? $r->status : 'scheduled';
            if ($status !== 'live') {
                if     ($startAt->gt($now))  { $status = 'scheduled'; }
                elseif ($startAt->lte($now)) { $status = 'live'; }
            }

            $list[] = [
                'id'            => (int) $r->id,
                'subject'       => $r->subjectname,
                'start_at'      => $startAt->toIso8601String(),
                'end_at'        => $endAt->toIso8601String(),
                'duration_mins' => (int) $r->subjectduration,
                'status'        => $status,
                'joinable'      => $status === 'live',
                'room_id'       => $r->zego_room_id ?? null,
            ];
        }

        return response()->json(['sessions' => $list]);
    }


    // POST /api/classrooms/{id}/start
    // public function startClass($id, Request $request)
    // {
    //     $now = Carbon::now();

    //     $row = DB::table('classroomsubjectdetails')->where('id', $id)->first();
    //     if (!$row) return response()->json(['message' => 'Not found'], 404);

    //     $startAt = $row->subjectstarttime ? Carbon::parse($row->subjectstarttime) : $now;

    //     DB::table('classroomsubjectdetails')->where('id', $id)->update([
    //         'subjectstarttime' => $startAt,  // set if empty; keep existing if present
    //         'status'           => 'live',
    //         'subjectendtime'   => null,      // clear any end
    //         'updated_at'       => $now,
    //     ]);

    //     return response()->json(['message' => 'Class started', 'start_at' => $startAt->toIso8601String()]);
    // }

    public function startClass($id, Request $request)
    {
        $now = \Illuminate\Support\Carbon::now();

        $row = DB::table('classroomsubjectdetails')->where('id', $id)->first();
        if (!$row) return response()->json(['message' => 'Not found'], 404);

        $startAt = $row->subjectstarttime ? \Illuminate\Support\Carbon::parse($row->subjectstarttime) : $now;

        // Generate stable room id if empty (e.g. class_{id}_YYYYMMDD)
        //$roomId = $row->zego_room_id ?: ('class_'.$id.'_'.now()->format('Ymd'));

        $roomId = $row->zego_room_id ?: ('class_'.$id.'_'.$now->format('Ymd'));

        DB::table('classroomsubjectdetails')->where('id', $id)->update([
            'subjectstarttime' => $startAt,
            'status'           => 'live',
            'subjectendtime'   => null,
            'zego_room_id'     => $roomId,
            'zego_started_at'  => $now,
            'zego_ended_at'    => null,
            'updated_at'       => $now,
        ]);

        return response()->json([
            'message'   => 'Class started',
            'start_at'  => $startAt->toIso8601String(),
            'room_id'   => $roomId,
        ]);
    }


    // POST /api/classrooms/{id}/end
    public function endClass($id, Request $request)
    {
        $now = Carbon::now();

        $row = DB::table('classroomsubjectdetails')->where('id', $id)->first();
        if (!$row) return response()->json(['message' => 'Not found'], 404);

        DB::table('classroomsubjectdetails')->where('id', $id)->update([
            'status'         => 'ended',
            'subjectendtime' => $now,
            'updated_at'     => $now,
        ]);

        return response()->json(['message' => 'Class ended', 'end_at' => $now->toIso8601String()]);
    }
}