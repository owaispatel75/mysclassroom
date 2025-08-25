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
//         Schema::table('payments', function (Blueprint $table) {
//             //
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('payments', function (Blueprint $table) {
//             //
//         });
//     }
// };

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('payments', function (Blueprint $table) {
            if (!Schema::hasColumn('payments', 'offering_id')) {
                $table->unsignedBigInteger('offering_id')->nullable()->after('mobile');
            }
            if (!Schema::hasColumn('payments', 'subjectname')) {
                $table->string('subjectname', 120)->nullable()->after('offering_id');
            }
            if (!Schema::hasColumn('payments', 'teacher_mobile')) {
                $table->string('teacher_mobile', 20)->nullable()->after('subjectname');
            }
        });
    }

    public function down(): void {
        Schema::table('payments', function (Blueprint $table) {
            if (Schema::hasColumn('payments', 'offering_id')) $table->dropColumn('offering_id');
            if (Schema::hasColumn('payments', 'subjectname')) $table->dropColumn('subjectname');
            if (Schema::hasColumn('payments', 'teacher_mobile')) $table->dropColumn('teacher_mobile');
        });
    }
};