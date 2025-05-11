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
            // Add trader field
            $table->boolean('is_trader')->default(false)->after('email');
            
            // Add wallet fields
            $table->decimal('cash_wallet', 15, 2)->default(0)->after('is_trader');
            $table->decimal('voucher_wallet', 15, 2)->default(0)->after('cash_wallet');
            $table->decimal('travel_wallet', 15, 2)->default(0)->after('voucher_wallet');
            $table->decimal('xlm_wallet', 15, 2)->default(0)->after('travel_wallet');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'is_trader',
                'cash_wallet',
                'voucher_wallet',
                'travel_wallet',
                'xlm_wallet'
            ]);
        });
    }
};
