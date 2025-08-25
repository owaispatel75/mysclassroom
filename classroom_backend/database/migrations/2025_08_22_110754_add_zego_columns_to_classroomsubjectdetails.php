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
//         Schema::table('classroomsubjectdetails', function (Blueprint $table) {
//             //
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('classroomsubjectdetails', function (Blueprint $table) {
//             //
//         });
//     }
// };

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('classroomsubjectdetails', function (Blueprint $table) {
            // add after 'status' if it exists in your schema
            if (!Schema::hasColumn('classroomsubjectdetails', 'zego_room_id')) {
                $table->string('zego_room_id', 120)->nullable()->after('status');
            }
            if (!Schema::hasColumn('classroomsubjectdetails', 'zego_started_at')) {
                $table->dateTime('zego_started_at')->nullable()->after('zego_room_id');
            }
            if (!Schema::hasColumn('classroomsubjectdetails', 'zego_ended_at')) {
                $table->dateTime('zego_ended_at')->nullable()->after('zego_started_at');
            }
        });
    }

    public function down(): void
    {
        Schema::table('classroomsubjectdetails', function (Blueprint $table) {
            // drop only if they exist (safe on repeated rollbacks)
            if (Schema::hasColumn('classroomsubjectdetails', 'zego_ended_at')) {
                $table->dropColumn('zego_ended_at');
            }
            if (Schema::hasColumn('classroomsubjectdetails', 'zego_started_at')) {
                $table->dropColumn('zego_started_at');
            }
            if (Schema::hasColumn('classroomsubjectdetails', 'zego_room_id')) {
                $table->dropColumn('zego_room_id');
            }
        });
    }
};
