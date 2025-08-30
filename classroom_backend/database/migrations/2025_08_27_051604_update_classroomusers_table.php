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
//         Schema::table('classroomusers', function (Blueprint $table) {
//             //
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('classroomusers', function (Blueprint $table) {
//             //
//         });
//     }
// };

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('classroomusers', function (Blueprint $table) {
            if (!Schema::hasColumn('classroomusers', 'fullname')) {
                $table->string('fullname')->nullable();
            }
            if (!Schema::hasColumn('classroomusers', 'email')) {
                $table->string('email')->nullable();
            } else {
                $table->string('email')->nullable()->change();
            }
            if (!Schema::hasColumn('classroomusers', 'mobile')) {
                $table->string('mobile')->unique()->index();
            }
            if (!Schema::hasColumn('classroomusers', 'role')) {
                $table->enum('role', ['admin','teacher','student'])->default('student')->index();
            }
            if (!Schema::hasColumn('classroomusers', 'is_logged')) {
                $table->boolean('is_logged')->default(false);
            }
            if (!Schema::hasColumn('classroomusers', 'device_id')) {
                $table->string('device_id')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('classroomusers', function (Blueprint $table) {
            // Rollback cleanly if needed
            $table->dropColumn(['fullname','email','mobile','role','is_logged','device_id']);
        });
    }
};
