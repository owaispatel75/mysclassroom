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
//         Schema::create('offerings', function (Blueprint $table) {
//             $table->id();
//             $table->timestamps();
//         });
//     }

//     /**
//      * Reverse the migrations.
//      */
//     public function down(): void
//     {
//         Schema::dropIfExists('offerings');
//     }
// };

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('offerings', function (Blueprint $table) {
            $table->id();
            $table->string('subjectname', 120);
            $table->string('teacher_mobile', 20); // maps to classroomsubjectdetails.classroommobile
            $table->unsignedInteger('price_paise'); // e.g., 49900
            $table->string('currency', 10)->default('INR');
            $table->boolean('active')->default(true);
            $table->timestamps();

            $table->index(['subjectname', 'teacher_mobile']);
        });
    }
    public function down(): void {
        Schema::dropIfExists('offerings');
    }
};
