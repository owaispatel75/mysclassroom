<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ClassroomUser;

class ProfileController extends Controller
{
    public function update(Request $request)
    {
        $data = $request->validate([
            'mobile'   => 'required',            // key
            'fullname' => 'required|string|max:100',
            'email'    => 'nullable|email|max:150',
            // NOTE: no 'mobile' update allowed here
        ]);

        $user = ClassroomUser::where('mobile', $data['mobile'])->first();
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // Only allow safe fields to change
        $user->forceFill([
            'fullname' => $data['fullname'],
            'email'    => $data['email'] ?? null,
        ])->save();

        return response()->json([
            'message' => 'Profile updated',
            'user' => [
                'fullname' => $user->fullname,
                'mobile'   => $user->mobile,
                'role'     => $user->role,
                'email'    => $user->email ?? null,
            ]
        ]);
    }
}