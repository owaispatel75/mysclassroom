<?php

// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
// use Illuminate\Support\Facades\DB;
// use Illuminate\Validation\Rule;

// class UserAdminController extends Controller
// {
//     // GET /api/users?role=student|teacher&search=&page=1&per_page=20
//     public function index(Request $request)
//     {
//         $role     = $request->query('role');        // optional filter
//         $search   = trim((string) $request->query('search', ''));
//         $perPage  = (int) $request->query('per_page', 50);
//         $page     = (int) $request->query('page', 1);

//         // $q = DB::table('users')
//         $q = DB::table('classroomusers')
//             ->select('id','fullname','mobile','email','role','active')
//             ->orderBy('fullname');

//         if ($role && in_array($role, ['student','teacher'], true)) {
//             $q->where('role', $role);
//         }
//         if ($search !== '') {
//             $q->where(function($w) use ($search) {
//                 $w->where('fullname', 'like', "%{$search}%")
//                   ->orWhere('mobile', 'like', "%{$search}%")
//                   ->orWhere('email', 'like', "%{$search}%");
//             });
//         }

//         // Only list non-deleted users (active=1)
//         $q->where('active', 1);

//         $total = (clone $q)->count();
//         $users = $q->forPage($page, $perPage)->get();

//         return response()->json([
//             'users'     => $users,
//             'page'      => $page,
//             'per_page'  => $perPage,
//             'total'     => $total,
//         ]);
//     }

//     // POST /api/users
//     public function store(Request $request)
//     {
//         $data = $request->validate([
//             'fullname' => 'nullable|string|max:120',
//             'mobile'   => 'required|string|max:20|unique:users,mobile',
//             'email'    => 'nullable|email|max:120',
//             'role'     => ['required', Rule::in(['student','teacher'])],
//             'active'   => 'nullable|boolean',
//         ]);

//         $now = now();
//         // $id = DB::table('users')->insertGetId([
//         $id = DB::table('classroomusers')->insertGetId([
//             'fullname'  => $data['fullname'] ?? null,
//             'mobile'    => $data['mobile'],
//             'email'     => $data['email'] ?? null,
//             'role'      => $data['role'],
//             'active'    => $data['active'] ?? 1,
//             'created_at'=> $now,
//             'updated_at'=> $now,
//         ]);

//         // $user = DB::table('users')
//         $user = DB::table('classroomusers')
//             ->select('id','fullname','mobile','email','role','active')
//             ->where('id', $id)->first();

//         return response()->json(['user' => $user], 201);
//     }

//     // PUT /api/users/{id}
//     public function update($id, Request $request)
//     {
//         $data = $request->validate([
//             'fullname' => 'nullable|string|max:120',
//             'mobile'   => [
//                 'nullable','string','max:20',
//                 Rule::unique('users','mobile')->ignore($id)
//             ],
//             'email'    => 'nullable|email|max:120',
//             'role'     => ['nullable', Rule::in(['student','teacher'])],
//             'active'   => 'nullable|boolean',
//         ]);

//         $payload = [];
//         foreach (['fullname','mobile','email','role','active'] as $f) {
//             if ($request->filled($f)) $payload[$f] = $data[$f];
//         }
//         if (!$payload) {
//             return response()->json(['message'=>'Nothing to update'], 422);
//         }
//         $payload['updated_at'] = now();

//         $count = DB::table('classroomusers')->where('id', $id)->update($payload);
//         // $count = DB::table('users')->where('id', $id)->update($payload);
//         if (!$count) return response()->json(['message'=>'Not found'], 404);

//         // $user = DB::table('users')
//         $user = DB::table('classroomusers')
//             ->select('id','fullname','mobile','email','role','active')
//             ->where('id', $id)->first();

//         return response()->json(['user' => $user]);
//     }

//     // DELETE /api/users/{id}
//     public function destroy($id)
//     {
//         // Soft-delete by marking inactive (safer)
//         // $count = DB::table('users')->where('id', $id)->update([
//         $count = DB::table('classroomusers')->where('id', $id)->update([
//             'active'     => 0,
//             'updated_at' => now(),
//         ]);
//         if (!$count) return response()->json(['message'=>'Not found'], 404);

//         return response()->json(['message' => 'Deleted']);
//     }
// }

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class UserAdminController extends Controller
{
    // POST /api/admin/users
    public function store(Request $request)
    {
        $v = $request->validate([
            'fullname' => ['required','string','max:120'],
            'email'    => ['nullable','email','max:190', Rule::unique('classroomusers','email')],
            'mobile'   => ['required','string','max:20', Rule::unique('classroomusers','mobile')],
            'role'     => ['required', Rule::in(['student','teacher','admin'])],
            'active'   => ['sometimes','boolean'], // default true below
        ]);

        $now = now();

        DB::table('classroomusers')->insert([
            'fullname'   => $v['fullname'],
            'email'      => $v['email'] ?? null,
            'mobile'     => $v['mobile'],
            'role'       => $v['role'],
            'active'     => array_key_exists('active',$v) ? (int)$v['active'] : 1,
            'is_logged'  => 0,
            'device_id'  => null,
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        return response()->json(['message' => 'Created'], 201);
    }

    // PUT /api/admin/users/{id}
    public function update($id, Request $request)
    {
        // validate with "ignore" on the same table
        $v = $request->validate([
            'fullname' => ['sometimes','required','string','max:120'],
            'email'    => ['sometimes','nullable','email','max:190',
                           Rule::unique('classroomusers','email')->ignore($id, 'id')],
            'mobile'   => ['sometimes','required','string','max:20',
                           Rule::unique('classroomusers','mobile')->ignore($id, 'id')],
            'role'     => ['sometimes', Rule::in(['student','teacher','admin'])],
            'active'   => ['sometimes','boolean'],
        ]);

        $payload = [];
        foreach (['fullname','email','mobile','role'] as $k) {
            if ($request->has($k)) $payload[$k] = $v[$k] ?? null;
        }
        if ($request->has('active')) $payload['active'] = (int)$v['active'];
        $payload['updated_at'] = now();

        $n = DB::table('classroomusers')->where('id', $id)->update($payload);
        if (!$n) return response()->json(['message' => 'Not found'], 404);

        return response()->json(['message' => 'Updated']);
    }

    // DELETE /api/admin/users/{id}
    public function destroy($id)
    {
        $n = DB::table('classroomusers')->where('id', $id)->delete();
        if (!$n) return response()->json(['message' => 'Not found'], 404);
        return response()->json(['message' => 'Deleted']);
    }

    // GET /api/admin/users?role=student|teacher&search=...
    public function index(Request $request)
    {
        $role = $request->query('role');  // optional
        $search = $request->query('search'); // optional

        $q = DB::table('classroomusers');
        if ($role) $q->where('role', $role);
        if ($search) {
            $q->where(function ($w) use ($search) {
                $w->where('fullname', 'like', "%$search%")
                  ->orWhere('mobile', 'like', "%$search%")
                  ->orWhere('email', 'like', "%$search%");
            });
        }

        // If you only want “active” users by default, uncomment:
        // $q->where('active', 1);

        return response()->json([
            'users' => $q->orderBy('fullname')->limit(1000)->get(),
        ]);
    }
}
