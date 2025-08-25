<?php

// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
// use Illuminate\Support\Carbon;
// use Illuminate\Support\Facades\DB;

// class ClassroomAdminController extends Controller
// {
//     // GET /api/classrooms/subjects?date=2025-08-15
//     public function index(Request $request)
//     {
//         $date = $request->query('date');
//         $start = $date ? Carbon::parse($date)->startOfDay() : Carbon::now()->startOfDay();
//         $end   = (clone $start)->endOfDay();

//         $rows = DB::table('classroomsubjectdetails')
//             ->whereBetween('subjectstarttime', [$start, $end])
//             ->orderBy('subjectstarttime')
//             ->get();

//         $list = $rows->map(function ($r) {
//             $startAt = Carbon::parse($r->subjectstarttime);
//             $endAt   = $r->subjectendtime
//                 ? Carbon::parse($r->subjectendtime)
//                 : (clone $startAt)->addMinutes((int)$r->subjectduration);

//             return [
//                 'id'            => (int)$r->id,
//                 'classroomid'   => $r->classroomid,
//                 'classroomname' => $r->classroomname,
//                 'teacher_mobile'=> $r->classroommobile, // using your existing column
//                 'subject'       => $r->subjectname,
//                 'start_at'      => $startAt->toIso8601String(),
//                 'end_at'        => $endAt->toIso8601String(),
//                 'duration_mins' => (int)$r->subjectduration,
//                 'status'        => $r->status ?: 'scheduled',
//             ];
//         });

//         return response()->json(['sessions' => $list]);
//     }

//     // POST /api/classrooms/subjects
//     public function store(Request $request)
//     {
//         $data = $request->validate([
//             'classroomid'    => 'nullable',
//             'classroomname'  => 'nullable|string',
//             'teacher_mobile' => 'nullable|string',
//             'subject'        => 'required|string|max:120',
//             'start_at'       => 'required|date',
//             'duration_mins'  => 'required|integer|min:1|max:600',
//             'status'         => 'nullable|in:scheduled,live,ended',
//         ]);

//         $now = Carbon::now();
//         $id = DB::table('classroomsubjectdetails')->insertGetId([
//             'classroomid'        => $data['classroomid'] ?? null,
//             'classroomname'      => $data['classroomname'] ?? null,
//             'classroommobile'    => $data['teacher_mobile'] ?? null,
//             'subjectname'        => $data['subject'],
//             'subjectstarttime'   => Carbon::parse($data['start_at']),
//             'subjectduration'    => (int)$data['duration_mins'],
//             'status'             => $data['status'] ?? 'scheduled',
//             'created_at'         => $now,
//             'updated_at'         => $now,
//         ]);

//         return response()->json(['id' => $id], 201);
//     }

//     // PUT /api/classrooms/subjects/{id}
//     public function update($id, Request $request)
//     {
//         $data = $request->validate([
//             'classroomid'    => 'nullable',
//             'classroomname'  => 'nullable|string',
//             'teacher_mobile' => 'nullable|string',
//             'subject'        => 'nullable|string|max:120',
//             'start_at'       => 'nullable|date',
//             'duration_mins'  => 'nullable|integer|min:1|max:600',
//             'status'         => 'nullable|in:scheduled,live,ended',
//         ]);

//         $payload = [];
//         foreach ([
//             'classroomid'       => 'classroomid',
//             'classroomname'     => 'classroomname',
//             'teacher_mobile'    => 'classroommobile',
//             'subject'           => 'subjectname',
//             'duration_mins'     => 'subjectduration',
//             'status'            => 'status',
//         ] as $in => $col) {
//             if ($request->filled($in)) $payload[$col] = $request->input($in);
//         }
//         if ($request->filled('start_at')) {
//             $payload['subjectstarttime'] = Carbon::parse($request->input('start_at'));
//         }
//         $payload['updated_at'] = Carbon::now();

//         $count = DB::table('classroomsubjectdetails')->where('id', $id)->update($payload);
//         if (!$count) return response()->json(['message' => 'Not found'], 404);

//         return response()->json(['message' => 'Updated']);
//     }

//     // DELETE /api/classrooms/subjects/{id}
//     public function destroy($id)
//     {
//         $count = DB::table('classroomsubjectdetails')->where('id', $id)->delete();
//         if (!$count) return response()->json(['message' => 'Not found'], 404);
//         return response()->json(['message' => 'Deleted']);
//     }
// }

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class ClassroomAdminController extends Controller
{
    // GET /api/classrooms/subjects?date=YYYY-MM-DD
    public function index(Request $request)
    {
        $date = $request->query('date');
        $start = $date ? Carbon::parse($date)->startOfDay() : Carbon::now()->startOfDay();
        $end   = (clone $start)->endOfDay();

        $rows = DB::table('classroomsubjectdetails')
            ->whereBetween('subjectstarttime', [$start, $end])
            ->orderBy('subjectstarttime')
            ->get();

        $list = $rows->map(function ($r) {
            $startAt = Carbon::parse($r->subjectstarttime);
            $endAt   = $r->subjectendtime
                ? Carbon::parse($r->subjectendtime)
                : (clone $startAt)->addMinutes((int)$r->subjectduration);

            return [
                'id'            => (int)$r->id,
                'classroomid'   => $r->classroomid,
                'classroomname' => $r->classroomname,
                'teacher_mobile'=> $r->classroommobile,
                'subject'       => $r->subjectname,
                'start_at'      => $startAt->toIso8601String(),
                'end_at'        => $endAt->toIso8601String(),
                'duration_mins' => (int)$r->subjectduration,
                'status'        => $r->status ?: 'scheduled',
            ];
        });

        return response()->json(['sessions' => $list]);
    }

    public function store(Request $request)
    {
        try {
            $data = $request->validate([
                'classroomid'    => 'nullable',
                'classroomname'  => 'nullable|string',
                'teacher_mobile' => 'nullable|string',
                'subject'        => 'required|string|max:120',
                'start_at'       => 'required|date',
                'duration_mins'  => 'required|integer|min:1|max:600',
                'status'         => 'nullable|in:scheduled,live,ended',
            ]);

            $now      = \Illuminate\Support\Carbon::now();
            $startAt  = \Illuminate\Support\Carbon::parse($data['start_at']);
            $duration = (int) $data['duration_mins'];
            $status   = $data['status'] ?? 'scheduled';

            // compute end (for ended we persist an end time; otherwise null)
            $computedEnd = ($status === 'ended')
                ? (clone $startAt)->addMinutes($duration)
                : null;

            $id = \Illuminate\Support\Facades\DB::table('classroomsubjectdetails')->insertGetId([
                'classroomid'        => $data['classroomid'] ?? null,
                'classroomname'      => $data['classroomname'] ?? null,
                'classroommobile'    => $data['teacher_mobile'] ?? null,
                'subjectname'        => $data['subject'],
                'subjectstarttime'   => $startAt,
                'subjectduration'    => $duration,
                'subjectendtime'     => $computedEnd,    // nullable unless ended
                'status'             => $status,         // scheduled|live|ended
                'created_at'         => $now,
                'updated_at'         => $now,
            ]);

            return response()->json(['id' => $id], 201);
        } catch (\Throwable $e) {
            // TEMP: bubble the real reason so you can see it in the client
            return response()->json([
                'message' => 'Create failed',
                'error'   => $e->getMessage(),
            ], 422);
        }
    }

    public function update($id, Request $request)
    {
        try {
            $data = $request->validate([
                'classroomid'    => 'nullable',
                'classroomname'  => 'nullable|string',
                'teacher_mobile' => 'nullable|string',
                'subject'        => 'nullable|string|max:120',
                'start_at'       => 'nullable|date',
                'duration_mins'  => 'nullable|integer|min:1|max:600',
                'status'         => 'nullable|in:scheduled,live,ended',
            ]);

            $payload = [];
            if ($request->filled('classroomid'))    $payload['classroomid']     = $request->input('classroomid');
            if ($request->filled('classroomname'))  $payload['classroomname']   = $request->input('classroomname');
            if ($request->filled('teacher_mobile')) $payload['classroommobile'] = $request->input('teacher_mobile');
            if ($request->filled('subject'))        $payload['subjectname']     = $request->input('subject');
            if ($request->filled('duration_mins'))  $payload['subjectduration'] = (int)$request->input('duration_mins');
            if ($request->filled('start_at'))       $payload['subjectstarttime']= \Illuminate\Support\Carbon::parse($request->input('start_at'));
            if ($request->filled('status'))         $payload['status']          = $request->input('status');

            // keep end time consistent with status
            if ($request->filled('status')) {
                $status = $request->input('status');

                if ($status === 'ended') {
                    $row = \Illuminate\Support\Facades\DB::table('classroomsubjectdetails')->where('id', $id)->first();
                    if (!$row) return response()->json(['message' => 'Not found'], 404);

                    $startAt = isset($payload['subjectstarttime'])
                        ? $payload['subjectstarttime']
                        : ($row->subjectstarttime ? \Illuminate\Support\Carbon::parse($row->subjectstarttime) : \Illuminate\Support\Carbon::now());

                    $mins = isset($payload['subjectduration'])
                        ? (int)$payload['subjectduration']
                        : (int)($row->subjectduration ?? 0);

                    $payload['subjectendtime'] = $mins > 0
                        ? (clone $startAt)->addMinutes($mins)
                        : \Illuminate\Support\Carbon::now();
                } else {
                    $payload['subjectendtime'] = null;
                }
            }

            $payload['updated_at'] = \Illuminate\Support\Carbon::now();

            $count = \Illuminate\Support\Facades\DB::table('classroomsubjectdetails')->where('id', $id)->update($payload);
            if (!$count) return response()->json(['message' => 'Not found'], 404);

            return response()->json(['message' => 'Updated']);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Update failed',
                'error'   => $e->getMessage(),
            ], 422);
        }
    }


    // // POST /api/classrooms/subjects
    // public function store(Request $request)
    // {
    //     $data = $request->validate([
    //         'classroomid'    => 'nullable',
    //         'classroomname'  => 'nullable|string',
    //         'teacher_mobile' => 'nullable|string',
    //         'subject'        => 'required|string|max:120',
    //         'start_at'       => 'required|date',
    //         'duration_mins'  => 'required|integer|min:1|max:600',
    //         'status'         => 'nullable|in:scheduled,live,ended',
    //     ]);

    //     $now     = Carbon::now();
    //     $startAt = Carbon::parse($data['start_at']);
    //     $endAt   = (clone $startAt)->addMinutes((int)$data['duration_mins']);

    //     // If admin creates as "ended", persist a sensible end time
    //     $status  = $data['status'] ?? 'scheduled';
    //     $endCol  = $status === 'ended' ? $endAt : null;

    //     $id = DB::table('classroomsubjectdetails')->insertGetId([
    //         'classroomid'        => $data['classroomid'] ?? null,
    //         'classroomname'      => $data['classroomname'] ?? null,
    //         'classroommobile'    => $data['teacher_mobile'] ?? null,
    //         'subjectname'        => $data['subject'],
    //         'subjectstarttime'   => $startAt,
    //         'subjectduration'    => (int)$data['duration_mins'],
    //         'subjectendtime'     => $endCol,
    //         'status'             => $status,
    //         'created_at'         => $now,
    //         'updated_at'         => $now,
    //     ]);

    //     return response()->json(['id' => $id], 201);
    // }

    // // PUT /api/classrooms/subjects/{id}
    // public function update($id, Request $request)
    // {
    //     $data = $request->validate([
    //         'classroomid'    => 'nullable',
    //         'classroomname'  => 'nullable|string',
    //         'teacher_mobile' => 'nullable|string',
    //         'subject'        => 'nullable|string|max:120',
    //         'start_at'       => 'nullable|date',
    //         'duration_mins'  => 'nullable|integer|min:1|max:600',
    //         'status'         => 'nullable|in:scheduled,live,ended',
    //     ]);

    //     $payload = [];

    //     // simple column map
    //     foreach ([
    //         'classroomid'       => 'classroomid',
    //         'classroomname'     => 'classroomname',
    //         'teacher_mobile'    => 'classroommobile',
    //         'subject'           => 'subjectname',
    //         'duration_mins'     => 'subjectduration',
    //         'status'            => 'status',
    //     ] as $in => $col) {
    //         if ($request->filled($in)) $payload[$col] = $request->input($in);
    //     }

    //     if ($request->filled('start_at')) {
    //         $payload['subjectstarttime'] = Carbon::parse($request->input('start_at'));
    //     }

    //     // handle subjectendtime consistently with status
    //     if ($request->filled('status')) {
    //         $status = $request->input('status');
    //         if ($status === 'ended') {
    //             // If caller didn’t explicitly pass an end, compute a reasonable one
    //             // based on (start + duration). Fallback to now() if columns missing.
    //             $row = DB::table('classroomsubjectdetails')->where('id', $id)->first();
    //             $startAt = $row?->subjectstarttime ? Carbon::parse($row->subjectstarttime) : Carbon::now();
    //             $mins    = (int)($request->input('duration_mins') ?? $row?->subjectduration ?? 0);
    //             $payload['subjectendtime'] = $mins > 0 ? (clone $startAt)->addMinutes($mins) : Carbon::now();
    //         } else {
    //             // moving back to scheduled/live => clear end time
    //             $payload['subjectendtime'] = null;
    //         }
    //     }

    //     $payload['updated_at'] = Carbon::now();

    //     $count = DB::table('classroomsubjectdetails')->where('id', $id)->update($payload);
    //     if (!$count) return response()->json(['message' => 'Not found'], 404);

    //     return response()->json(['message' => 'Updated']);
    // }

    // DELETE /api/classrooms/subjects/{id}
    public function destroy($id)
    {
        $count = DB::table('classroomsubjectdetails')->where('id', $id)->delete();
        if (!$count) return response()->json(['message' => 'Not found'], 404);
        return response()->json(['message' => 'Deleted']);
    }
}
