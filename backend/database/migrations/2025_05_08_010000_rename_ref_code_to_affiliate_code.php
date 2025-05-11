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
            // First drop the foreign key constraint on referral_id
            $table->dropForeign(['referral_id']);
            
            // Rename ref_code to affiliate_code
            $table->renameColumn('ref_code', 'affiliate_code');
            
            // Change referral_id to keep the same data type as affiliate_code
            $table->string('referral_id', 10)->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Restore original column name
            $table->renameColumn('affiliate_code', 'ref_code');
            
            // Restore referral_id to original type
            $table->unsignedBigInteger('referral_id')->nullable()->change();
            
            // Re-add foreign key constraint
            $table->foreign('referral_id')->references('id')->on('users')->onDelete('set null');
        });
    }
};
