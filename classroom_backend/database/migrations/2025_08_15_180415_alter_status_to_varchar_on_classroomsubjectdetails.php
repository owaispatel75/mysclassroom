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
//         Schema::table('varchar_on_classroomsubjectdetails', function (Blueprint $table) {
            
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('varchar_on_classroomsubjectdetails', function (Blueprint $table) {
//             //
//         });
//     }
// };

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        // Convert status to VARCHAR(20) with default 'scheduled'
        DB::statement("
            ALTER TABLE classroomsubjectdetails
            MODIFY status VARCHAR(20) NOT NULL DEFAULT 'scheduled'
        ");
    }

    public function down(): void
    {
        // If you previously had tinyint, revert (adjust if different)
        DB::statement("
            ALTER TABLE classroomsubjectdetails
            MODIFY status TINYINT(1) NOT NULL DEFAULT 0
        ");
    }
};
