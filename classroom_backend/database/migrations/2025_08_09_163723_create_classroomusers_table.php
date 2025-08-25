<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    // public function up(): void
    // {
    //     Schema::create('classroomusers', function (Blueprint $table) {
    //         $table->id();
    //         $table->timestamps();
    //     });
    // }

    public function up()
    {
        Schema::create('classroomusers', function (Blueprint $table) {
            $table->id();
            $table->string('fullname')->nullable();
            $table->string('mobile')->unique();
            $table->string('aadharcardnumber')->nullable();
            $table->string('aadharcard')->nullable(); // upload path
            $table->date('dob')->nullable();
            $table->date('joiningdate')->nullable();
            $table->enum('role', ['admin','teacher','student']);
            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classroomusers');
    }
};
