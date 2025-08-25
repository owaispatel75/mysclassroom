<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    // GET /api/teachers  ->  [{ fullname, mobile }]
    public function teachers()
    {
        $rows = DB::table('classroomusers')
            ->select('fullname', 'mobile')
            ->where('role', 'teacher')
            ->orderBy('fullname')
            ->get();

        return response()->json(['teachers' => $rows]);
    }
}
