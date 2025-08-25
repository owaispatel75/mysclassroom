<?php

// namespace App\Http\Controllers\API;

// use App\Http\Controllers\Controller;
// use Illuminate\Http\Request;
// use App\Models\OtpVerification;
// use App\Models\ClassroomUser;

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\OtpVerification;
use App\Models\ClassroomUser;

class OtpController extends Controller
{
    // public function sendOtp(Request $request)
    // {
    //     $data = $request->validate(['mobile' => 'required']);

    //     // You can change to 6-digit easily
    //     $otp = (string)random_int(1000, 9999);

    //     OtpVerification::updateOrCreate(
    //         ['mobile' => $data['mobile']],
    //         ['otp' => $otp, 'expires_at' => now()->addMinutes(5), 'verified' => false]
    //     );

    //     return response()->json(['message' => 'OTP generated']);
    // }

    // public function fetchOtp(Request $request)
    // {
    //     $request->validate(['mobile' => 'required']);

    //     $otpRow = OtpVerification::where('mobile', $request->mobile)
    //         ->where('verified', false)
    //         ->where('expires_at', '>=', now())
    //         ->first();

    //     return response()->json(['otp' => $otpRow?->otp]); // Flutter shows via local notification
    // }

    // public function verifyOtp(Request $request)
    // {
    //     $data = $request->validate([
    //         'mobile' => 'required',
    //         'otp'    => 'required'
    //     ]);

    //     $otpRow = OtpVerification::where('mobile', $data['mobile'])
    //         ->where('verified', false)
    //         ->where('expires_at', '>=', now())
    //         ->first();

    //     if (!$otpRow || $otpRow->otp !== $data['otp']) {
    //         return response()->json(['message' => 'Invalid or expired OTP'], 422);
    //     }

    //     $otpRow->update(['verified' => true]);

    //     // Find pre-seeded user by mobile to get role
    //     $user = \App\Models\ClassroomUser::where('mobile', $data['mobile'])->first();

    //     if (!$user) {
    //         return response()->json([
    //             'message' => 'User not found. Please contact admin to register.'
    //         ], 404);
    //     }

    //     return response()->json([
    //         'user' => [
    //             'id' => $user->id,
    //             'fullname' => $user->fullname,
    //             'mobile' => $user->mobile,
    //             'role' => $user->role,
    //         ]
    //     ]);
    // }

    public function sendOtp(Request $request)
    {
        $data = $request->validate([
            'mobile'    => 'required',
            'device_id' => 'nullable|string',
        ]);

        // if user exists & logged on another device, block
        $user = ClassroomUser::where('mobile', $data['mobile'])->first();
        if ($user && $user->is_logged && $user->device_id && ($data['device_id'] ?? '') !== $user->device_id) {
            return response()->json([
                'message' => 'User already logged in on another device',
                'already_logged_in' => true
            ], 423); // 423 Locked
        }

        // generate & store OTP
        $otp = (string) random_int(1000, 9999);
        OtpVerification::updateOrCreate(
            ['mobile' => $data['mobile']],
            ['otp' => $otp, 'expires_at' => now()->addMinutes(5), 'verified' => false]
        );

        return response()->json(['message' => 'OTP generated']);
    }

    public function fetchOtp(Request $request)
    {
        $request->validate(['mobile' => 'required']);

        $row = OtpVerification::where('mobile', $request->mobile)
            ->where('verified', false)
            ->where('expires_at', '>=', now())
            ->first();

        return response()->json(['otp' => $row?->otp]);
    }

    public function verifyOtp(Request $request)
    {
        $data = $request->validate([
            'mobile'    => 'required',
            'otp'       => 'required',
            'device_id' => 'required'
        ]);

        $row = OtpVerification::where('mobile', $data['mobile'])
            ->where('verified', false)
            ->where('expires_at', '>=', now())
            ->first();

        if (!$row || $row->otp !== $data['otp']) {
            return response()->json(['message' => 'Invalid or expired OTP'], 422);
        }

        $row->update(['verified' => true]);

        $user = ClassroomUser::where('mobile', $data['mobile'])->first();
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // still bound elsewhere?
        if ($user->is_logged && $user->device_id && $user->device_id !== $data['device_id']) {
            return response()->json([
                'message' => 'User already logged in on another device',
                'already_logged_in' => true
            ], 423);
        }

        // bind to current device
        $user->update([
            'is_logged'     => true,
            'device_id'     => $data['device_id'],
            'last_login_at' => now()
        ]);

        return response()->json([
            'user' => [
                'id'       => $user->id,
                'fullname' => $user->fullname,
                'mobile'   => $user->mobile,
                'role'     => $user->role,
                'email'    => $user->email,
            ]
        ]);
    }
}
