<?php
// app/Http/Controllers/API/AttendanceController.php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class AttendanceController extends Controller
{
    public function mark(Request $request)
    {
        $data = $request->validate([
            'session_id' => 'required|integer',
            'mobile'     => 'required|string',
        ]);

        $session = DB::table('classroomsubjectdetails')->where('id', $data['session_id'])->first();
        if (!$session) return response()->json(['message' => 'Session not found'], 404);

        // Upsert (unique session_id + mobile)
        DB::table('lecture_attendance')->updateOrInsert(
            ['session_id' => $session->id, 'student_mobile' => $data['mobile']],
            [
                'subjectname'    => $session->subjectname,
                'teacher_mobile' => $session->classroommobile,
                'attended_at'    => Carbon::now(),
                'created_at'     => Carbon::now(),
                'updated_at'     => Carbon::now(),
                // 'created_at'     => DB::raw('COALESCE(created_at, NOW())'),
            ]
        );

        return response()->json(['message' => 'Attendance recorded']);
    }

    // app/Http/Controllers/API/AttendanceController.php
    public function start(Request $request)
    {
        $data = $request->validate([
            'session_id' => 'required|integer',
            'mobile'     => 'required|string',
        ]);

        $s = DB::table('classroomsubjectdetails')->where('id', $data['session_id'])->first();
        if (!$s) return response()->json(['message'=>'Session not found'], 404);

        DB::table('lecture_attendance')->updateOrInsert(
            ['session_id'=>$s->id, 'student_mobile'=>$data['mobile']],
            [
                'subjectname'    => $s->subjectname,
                'teacher_mobile' => $s->classroommobile,
                'attended_at'    => now(),
                'started_at'     => now(),
                'updated_at'     => now(),
                'created_at'     => DB::raw('COALESCE(created_at, NOW())'),
            ]
        );

        return response()->json(['message'=>'started']);
    }

    public function stop(Request $request)
    {
        $data = $request->validate([
            'session_id' => 'required|integer',
            'mobile'     => 'required|string',
        ]);

        $row = DB::table('lecture_attendance')
            ->where('session_id', $data['session_id'])
            ->where('student_mobile', $data['mobile'])
            ->first();

        if (!$row) return response()->json(['message'=>'Not started'], 404);

        $started = $row->started_at ? Carbon::parse($row->started_at) : Carbon::parse($row->attended_at);
        $now     = Carbon::now();
        $mins    = max(0, $started->diffInMinutes($now));

        // cap by session duration if you want:
        $session = DB::table('classroomsubjectdetails')->where('id',$data['session_id'])->first();
        if ($session) $mins = min($mins, (int)$session->subjectduration);

        DB::table('lecture_attendance')
            ->where('id', $row->id)
            ->update([
                'stopped_at'   => $now,
                'attended_mins'=> $mins,
                'updated_at'   => $now,
            ]);

        return response()->json(['message'=>'stopped','mins'=>$mins]);
    }

}