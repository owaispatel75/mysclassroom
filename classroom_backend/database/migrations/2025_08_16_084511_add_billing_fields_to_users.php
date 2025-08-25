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
//         Schema::table('users', function (Blueprint $table) {
//             //
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::table('users', function (Blueprint $table) {
//             //
//         });
//     }
// };

// database/migrations/2025_08_16_000002_add_billing_fields_to_users.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::table('classroomusers', function (Blueprint $t) {
      if (!Schema::hasColumn('classroomusers','trial_ends_at')) {
        $t->date('trial_ends_at')->nullable()->after('email');
      }
      if (!Schema::hasColumn('classroomusers','paid_until')) {
        $t->date('paid_until')->nullable()->after('trial_ends_at');
      }
    });
  }
  public function down(): void {
    Schema::table('classroomusers', function (Blueprint $t) {
      if (Schema::hasColumn('classroomusers','trial_ends_at')) $t->dropColumn('trial_ends_at');
      if (Schema::hasColumn('classroomusers','paid_until')) $t->dropColumn('paid_until');
    });
  }
};