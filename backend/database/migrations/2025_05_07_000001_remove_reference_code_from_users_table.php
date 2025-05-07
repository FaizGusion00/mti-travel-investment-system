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
        Schema::table('users', function (Blueprint $table) {
            // Remove redundant reference_code field
            if (Schema::hasColumn('users', 'reference_code')) {
                $table->dropColumn('reference_code');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Add back reference_code field if needed
            if (!Schema::hasColumn('users', 'reference_code')) {
                $table->string('reference_code', 10)->nullable()->after('ref_code');
            }
        });
    }
};
