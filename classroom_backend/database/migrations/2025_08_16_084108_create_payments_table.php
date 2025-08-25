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
//         Schema::create('payments', function (Blueprint $table) {
//             $table->id();
//             $table->timestamps();
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::dropIfExists('payments');
//     }
// };

// database/migrations/2025_08_16_000001_create_payments_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('payments', function (Blueprint $t) {
      $t->id();
      $t->string('mobile', 20);              // student mobile
      $t->integer('amount');                 // in paise (₹ * 100)
      $t->string('currency', 10)->default('INR');
      $t->enum('status', ['created','paid','failed','refunded'])->default('created');
      $t->string('order_id')->nullable();    // razorpay order id
      $t->string('payment_id')->nullable();  // razorpay payment id
      $t->timestamp('paid_at')->nullable();

      // access window this payment covers (optional but handy)
      $t->date('period_start')->nullable();
      $t->date('period_end')->nullable();

      $t->json('notes')->nullable();
      $t->timestamps();

      $t->index(['mobile','status']);
    });
  }
  public function down(): void {
    Schema::dropIfExists('payments');
  }
};
