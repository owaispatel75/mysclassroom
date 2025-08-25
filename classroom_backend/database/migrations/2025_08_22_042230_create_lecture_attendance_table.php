<?php

// use Illuminate\Database\Migrations\Migration;
// use Illuminate\Database\Schema\Blueprint;
// use Illuminate\Support\Facades\Schema;

// return new class extends Migration
// {
//     /**
//      * Run the migrations.
//      */
//     public function up(): void
//     {
//         Schema::create('lecture_attendance', function (Blueprint $table) {
//             $table->id();
//             $table->timestamps();
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::dropIfExists('lecture_attendance');
//     }
// };

// database/migrations/2025_08_16_100000_create_lecture_attendance_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('lecture_attendance', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('session_id'); // FK -> classroomsubjectdetails.id
            $table->string('student_mobile', 20);
            $table->string('subjectname');            // denormalized for easy reporting
            $table->string('teacher_mobile')->nullable(); // from classroommobile
            $table->timestamp('attended_at')->useCurrent();
            $table->unsignedBigInteger('invoice_id')->nullable(); // null = unbilled
            $table->timestamps();

            $table->unique(['session_id', 'student_mobile']); // idempotency
            $table->index(['student_mobile', 'invoice_id']);
        });
    }

    public function down(): void {
        Schema::dropIfExists('lecture_attendance');
    }
};
