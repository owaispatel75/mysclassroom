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
    //     Schema::create('classroomsubjectdetails', function (Blueprint $table) {
    //         $table->id();
    //         $table->timestamps();
    //     });
    // }

    public function up()
    {
        Schema::create('classroomsubjectdetails', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('classroomid')->nullable();
            $table->string('classroomname')->nullable();
            $table->string('classroommobile')->nullable();
            $table->string('subjectname');
            $table->dateTime('subjectstarttime')->nullable();
            $table->integer('subjectduration')->nullable(); // minutes
            $table->enum('status', ['live','yet_to_start'])->default('yet_to_start');
            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classroomsubjectdetails');
    }
};
