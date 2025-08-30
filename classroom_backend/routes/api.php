<?php

// use Illuminate\Support\Facades\Route;
// use App\Http\Controllers\API\OtpController;
// use App\Http\Controllers\API\AuthController;

// Route::get('ping', function () {
//     return response()->json(['ok' => true]);
// });

// Route::post('send-otp', [OtpController::class, 'sendOtp']);
// Route::get('fetch-otp', [OtpController::class, 'fetchOtp']);    // polling
// Route::post('verify-otp', [OtpController::class, 'verifyOtp']);  // returns role + user -->

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\OtpController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\ClassroomController;
use App\Http\Controllers\API\ClassroomAdminController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\PaymentController;
use App\Http\Controllers\API\OfferingController;
use App\Http\Controllers\API\SubscriptionController;
use App\Http\Controllers\API\BillingController;
use App\Http\Controllers\API\AttendanceController;
use App\Http\Controllers\API\ReportsController;
use App\Http\Controllers\API\UserAdminController;

// quick health check
Route::get('ping', fn () => response()->json(['ok' => true]));

// // your OTP endpoints
// Route::post('send-otp', [OtpController::class, 'sendOtp']);
// Route::get('fetch-otp', [OtpController::class, 'fetchOtp']);
// Route::post('verify-otp', [OtpController::class, 'verifyOtp']);

// OTP + single-device auth
Route::post('send-otp', [OtpController::class, 'sendOtp']);
Route::get('fetch-otp', [OtpController::class, 'fetchOtp']);
Route::post('verify-otp', [OtpController::class, 'verifyOtp']);
Route::post('logout-all', [AuthController::class, 'logoutAll']);
Route::post('logout', [AuthController::class, 'logout']);
//Route::post('profile/update', [\App\Http\Controllers\API\ProfileController::class, 'update']);
Route::post('profile/update', [ProfileController::class, 'update']);
Route::get('classrooms/today', [ClassroomController::class, 'today']);
// teacher list (today, not finished) filtered by teacher mobile (optional)
Route::get('classrooms/teacher/today', [ClassroomController::class, 'teacherToday']);
// start / end
Route::post('classrooms/{id}/start', [ClassroomController::class, 'startClass']);
Route::post('classrooms/{id}/end',   [ClassroomController::class, 'endClass']);
// Admin CRUD (protect later with auth/middleware)
Route::get(   'classrooms/subjects',        [ClassroomAdminController::class, 'index']);   // ?date=YYYY-MM-DD
Route::post(  'classrooms/subjects',        [ClassroomAdminController::class, 'store']);
Route::put(   'classrooms/subjects/{id}',   [ClassroomAdminController::class, 'update']);
Route::delete('classrooms/subjects/{id}',   [ClassroomAdminController::class, 'destroy']);
Route::get('teachers', [UserController::class, 'teachers']);

//Route::get ('payments/me', [PaymentController::class,'me']);
//Route::get ('payments',    [PaymentController::class,'index']);        // admin
//Route::post('payments',    [PaymentController::class,'store']);        // admin manual
//Route::post('payments/trial', [PaymentController::class,'grantTrial']); // admin trial

// Route::post('payments/create-order', [PaymentController::class,'createOrder']); // student
// Route::post('payments/confirm',      [PaymentController::class,'confirm']);     // student

// Route::get('offerings', [OfferingController::class, 'index']); //old
Route::get('subscriptions/me', [SubscriptionController::class, 'me']);

//Route::post('payments/create-order', [PaymentsController::class, 'createOrder']);
//Route::post('payments/confirm',      [PaymentsController::class, 'confirm']);
// Route::post('payments/trial',        [PaymentsController::class, 'grantTrial']);

// ===== Attendance =====
Route::post('attendance/mark', [AttendanceController::class, 'mark']); // {session_id, mobile}

// ===== Billing (per lecture) =====
Route::get('payments/me', [BillingController::class, 'myBilling']); // ?mobile=...
Route::post('payments/create-order', [BillingController::class, 'createOrder']); // mobile
Route::post('payments/confirm', [BillingController::class, 'confirm']); // mobile, order_id, payment_id, signature

Route::get('reports/attendance', [ReportsController::class, 'attendance']); // ?from=YYYY-MM-DD&to=YYYY-MM-DD
Route::get('reports/revenue',    [ReportsController::class, 'revenue']);    // ?from=YYYY-MM-DD&to=YYYY-MM-DD


Route::post('attendance/start', [AttendanceController::class, 'start']);
Route::post('attendance/stop',  [AttendanceController::class, 'stop']);

// list / create / update / delete
Route::get(   'offerings',        [OfferingController::class, 'index']);
Route::post(  'offerings',        [OfferingController::class, 'store']);
Route::put(   'offerings/{id}',   [OfferingController::class, 'update']);
Route::delete('offerings/{id}',   [OfferingController::class, 'destroy']);

Route::post('/subscriptions/enroll', [SubscriptionController::class, 'enroll']);
Route::post('/subscriptions/unenroll', [SubscriptionController::class, 'unenroll']);

// Admin Users CRUD
Route::get   ('users',        [UserAdminController::class, 'index']);   // ?role=student|teacher&search=&page=1&per_page=20
Route::post  ('users',        [UserAdminController::class, 'store']);   // create
Route::put   ('users/{id}',   [UserAdminController::class, 'update']);  // update
Route::delete('users/{id}',   [UserAdminController::class, 'destroy']); // delete (soft via active=0 or hard)
