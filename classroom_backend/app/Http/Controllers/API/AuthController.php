<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ClassroomUser;

class AuthController extends Controller
{
    public function logoutAll(Request $request)
    {
        $data = $request->validate(['mobile' => 'required']);
        $user = ClassroomUser::where('mobile', $data['mobile'])->first();
        if (!$user) return response()->json(['message' => 'User not found'], 404);

        $user->update(['is_logged' => false, 'device_id' => null]);
        return response()->json(['message' => 'Logged out from all devices']);
    }

    public function logout(Request $request)
    {
        $data = $request->validate([
            'mobile'    => 'required',
            'device_id' => 'required',
        ]);

        $user = \App\Models\ClassroomUser::where('mobile', $data['mobile'])->first();
        if (!$user) return response()->json(['message' => 'User not found'], 404);

        // only clear if the requester matches the bound device
        if ($user->device_id === $data['device_id']) {
            $user->forceFill(['is_logged' => false, 'device_id' => null])->save();
        }

        return response()->json(['message' => 'Logged out']);
    }

}
