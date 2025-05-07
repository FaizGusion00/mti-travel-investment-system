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
        Schema::create('transactions', function (Blueprint $table) {
            $table->id('transaction_id');
            $table->enum('wallet_type', ['cash_wallet', 'voucher_wallet', 'travel_wallet', 'xlm_wallet']);
            $table->unsignedBigInteger('from_account')->nullable(); // Can be null for system transactions
            $table->unsignedBigInteger('to_account');
            $table->decimal('amount', 15, 2);
            $table->enum('status', ['success', 'failed'])->default('success');
            $table->timestamp('created_at')->useCurrent();
            
            // Add foreign key constraints
            $table->foreign('from_account')->references('id')->on('users')->onDelete('set null');
            $table->foreign('to_account')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
