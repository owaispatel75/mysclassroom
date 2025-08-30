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
            if (!Schema::hasColumn('classroomusers', 'active')) {
                $table->boolean('active')->default(true)->after('role');
            }
        });
    }

    public function down(): void
    {
        Schema::table('classroomusers', function (Blueprint $table) {
            $table->dropColumn('active');
        });
    }
};