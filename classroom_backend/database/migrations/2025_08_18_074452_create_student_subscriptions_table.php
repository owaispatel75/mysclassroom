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
//         Schema::create('enrollments', function (Blueprint $table) {
//             $table->id();
//             $table->timestamps();
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::dropIfExists('enrollments');
//     }
// };

// use Illuminate\Database\Migrations\Migration;
// use Illuminate\Database\Schema\Blueprint;
// use Illuminate\Support\Facades\Schema;

// return new class extends Migration {
//     public function up(): void {
//         Schema::create('student_subscriptions', function (Blueprint $table) {
//             $table->id();
//             $table->string('student_mobile', 20);
//             $table->string('subjectname', 120);
//             $table->string('teacher_mobile', 20)->nullable(); // if you want subject-only access, leave null
//             $table->dateTime('valid_from');
//             $table->dateTime('valid_to');
//             $table->string('status', 20)->default('active'); // trial|active|expired
//             $table->timestamps();

//             $table->index(['student_mobile', 'subjectname', 'teacher_mobile']);
//         });
//     }
//     public function down(): void {
//         Schema::dropIfExists('student_subscriptions');
//     }
// };

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('student_subscriptions')) {
            Schema::create('student_subscriptions', function (Blueprint $table) {
                $table->id();
                $table->string('student_mobile', 20);
                $table->string('subjectname', 120);
                $table->string('teacher_mobile', 20)->nullable();
                $table->dateTime('valid_from');
                $table->dateTime('valid_to');
                $table->string('status', 20)->default('active');
                $table->timestamps();
            });
        } else {
            // If the table already exists, only add missing columns
            Schema::table('student_subscriptions', function (Blueprint $table) {
                if (!Schema::hasColumn('student_subscriptions', 'student_mobile')) {
                    $table->string('student_mobile', 20);
                }
                if (!Schema::hasColumn('student_subscriptions', 'subjectname')) {
                    $table->string('subjectname', 120);
                }
                if (!Schema::hasColumn('student_subscriptions', 'teacher_mobile')) {
                    $table->string('teacher_mobile', 20)->nullable();
                }
                if (!Schema::hasColumn('student_subscriptions', 'valid_from')) {
                    $table->dateTime('valid_from');
                }
                if (!Schema::hasColumn('student_subscriptions', 'valid_to')) {
                    $table->dateTime('valid_to');
                }
                if (!Schema::hasColumn('student_subscriptions', 'status')) {
                    $table->string('status', 20)->default('active');
                }
                if (!Schema::hasColumn('student_subscriptions', 'created_at')) {
                    $table->timestamps();
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('student_subscriptions')) {
            Schema::dropIfExists('student_subscriptions');
        }
    }
};
