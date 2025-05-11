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
        Schema::table('otps', function (Blueprint $table) {
            // Add data column if it doesn't exist
            if (!Schema::hasColumn('otps', 'data')) {
                $table->json('data')->nullable()->after('otp');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('otps', function (Blueprint $table) {
            // Drop the data column if it exists
            if (Schema::hasColumn('otps', 'data')) {
                $table->dropColumn('data');
            }
        });
    }
};
