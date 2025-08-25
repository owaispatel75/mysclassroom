<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('classroomsubjectdetails', function (Blueprint $table) {
            if (!Schema::hasColumn('classroomsubjectdetails', 'subjectendtime')) {
                $table->dateTime('subjectendtime')->nullable()->after('subjectduration');
            }
            if (!Schema::hasColumn('classroomsubjectdetails', 'status')) {
                // scheduled | live | ended
                $table->string('status', 20)->default('scheduled')->after('subjectendtime');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('classroomsubjectdetails', function (Blueprint $table) {
            if (Schema::hasColumn('classroomsubjectdetails', 'subjectendtime')) {
                $table->dropColumn('subjectendtime');
            }
            if (Schema::hasColumn('classroomsubjectdetails', 'status')) {
                $table->dropColumn('status');
            }
        });
    }
};
