<?php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class ReportsController extends Controller
{
    // Attendance from lecture_attendance
    public function attendance(Request $req)
    {
        [$from, $to] = $this->range($req);

        $rows = DB::table('lecture_attendance')
            ->select('id','session_id','student_mobile','subjectname','teacher_mobile','attended_at')
            ->whereBetween('attended_at', [$from, $to])
            ->orderBy('attended_at', 'desc')
            ->get();

        // KPIs
        $total = $rows->count();
        $activeStudents = $rows->pluck('student_mobile')->unique()->count();

        // by day
        $byDay = DB::table('lecture_attendance')
            ->selectRaw('DATE(attended_at) as day, COUNT(*) as cnt')
            ->whereBetween('attended_at', [$from, $to])
            ->groupBy('day')
            ->orderBy('day')
            ->get();

        // by subject
        $bySubject = DB::table('lecture_attendance')
            ->selectRaw('subjectname, COUNT(*) as cnt')
            ->whereBetween('attended_at', [$from, $to])
            ->groupBy('subjectname')
            ->orderBy('cnt','desc')
            ->get();

        return response()->json([
            'from'            => $from->toDateString(),
            'to'              => $to->toDateString(),
            'kpis'            => [
                'total_attendances' => $total,
                'active_students'   => $activeStudents,
            ],
            'by_day'          => $byDay,
            'by_subject'      => $bySubject,
            'rows'            => $rows,
        ]);
    }

    // Revenue from invoices (paid_at not null)
    public function revenue(Request $req)
    {
        [$from, $to] = $this->range($req);

        $paid = DB::table('invoices')
            ->whereNotNull('paid_at')
            ->whereBetween('paid_at', [$from, $to])
            ->orderBy('paid_at', 'desc')
            ->get();

        $totalPaise = (int) $paid->sum('amount');

        // by month
        $byMonth = DB::table('invoices')
            ->selectRaw('DATE_FORMAT(paid_at, "%Y-%m") as ym, SUM(amount) as sum_paise')
            ->whereNotNull('paid_at')
            ->whereBetween('paid_at', [$from, $to])
            ->groupBy('ym')
            ->orderBy('ym')
            ->get();

        return response()->json([
            'from'         => $from->toDateString(),
            'to'           => $to->toDateString(),
            'total_paise'  => $totalPaise,
            'by_month'     => $byMonth,
            'invoices'     => $paid->map(function($r){
                return [
                    'id'       => $r->id,
                    'mobile'   => $r->student_mobile,
                    'amount'   => (int)$r->amount,
                    'currency' => $r->currency,
                    'paid_at'  => Carbon::parse($r->paid_at)->toIso8601String(),
                ];
            }),
        ]);
    }

    private function range(Request $req): array
    {
        $from = $req->query('from') ? Carbon::parse($req->query('from'))->startOfDay()
                                    : Carbon::now()->subDays(30)->startOfDay();
        $to   = $req->query('to')   ? Carbon::parse($req->query('to'))->endOfDay()
                                    : Carbon::now()->endOfDay();
        return [$from, $to];
    }
}