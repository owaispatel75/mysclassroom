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
        Schema::table('classroomusers', function (Blueprint $table) {
            $table->boolean('is_logged')->default(false)->after('role');
            $table->string('device_id')->nullable()->after('is_logged');
            $table->timestamp('last_login_at')->nullable()->after('device_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('classroomusers', function (Blueprint $table) {
            $table->dropColumn(['is_logged','device_id','last_login_at']);
        });
    }
};
