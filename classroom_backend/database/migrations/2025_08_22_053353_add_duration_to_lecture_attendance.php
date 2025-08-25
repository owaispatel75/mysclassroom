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
//         Schema::table('lecture_attendance', function (Blueprint $table) {
//             //
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('lecture_attendance', function (Blueprint $table) {
//             //
//         });
//     }
// };

// database/migrations/2025_08_16_110000_add_duration_to_lecture_attendance.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('lecture_attendance', function (Blueprint $t) {
            if (!Schema::hasColumn('lecture_attendance','started_at'))  $t->timestamp('started_at')->nullable()->after('attended_at');
            if (!Schema::hasColumn('lecture_attendance','stopped_at'))  $t->timestamp('stopped_at')->nullable()->after('started_at');
            if (!Schema::hasColumn('lecture_attendance','attended_mins')) $t->integer('attended_mins')->default(0)->after('stopped_at');
        });
    }
    public function down(): void {
        Schema::table('lecture_attendance', function (Blueprint $t) {
            if (Schema::hasColumn('lecture_attendance','attended_mins')) $t->dropColumn('attended_mins');
            if (Schema::hasColumn('lecture_attendance','stopped_at'))   $t->dropColumn('stopped_at');
            if (Schema::hasColumn('lecture_attendance','started_at'))   $t->dropColumn('started_at');
        });
    }
};
