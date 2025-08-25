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
//         Schema::table('settings', function (Blueprint $table) {
//             //
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('settings', function (Blueprint $table) {
//             //
//         });
//     }
// };

// database/migrations/2025_08_16_100200_add_rate_to_settings_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        if (!Schema::hasTable('app_settings')) {
            Schema::create('app_settings', function (Blueprint $table) {
                $table->id();
                $table->string('key')->unique();
                $table->string('value');
                $table->timestamps();
            });
        }
        // seed default = ₹10 per lecture (1000 paise)
        \DB::table('app_settings')->updateOrInsert(
            ['key' => 'per_lecture_rate_paise'],
            ['value' => '1000', 'updated_at' => now(), 'created_at' => now()]
        );
    }
    public function down(): void {
        // optional: keep settings
    }
};
