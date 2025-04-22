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
        // First drop users_log table if it exists to avoid foreign key constraint issues
        Schema::dropIfExists('users_log');
        Schema::dropIfExists('users');

        Schema::create('users', function (Blueprint $table) {
            $table->id('user_id');
            $table->string('full_name')->unique();
            $table->string('email')->unique();
            $table->string('phonenumber', 20)->unique();
            $table->date('date_of_birth');
            $table->string('reference_code', 10)->default('COMPANY');
            $table->string('usdt_address', 255)->nullable();
            $table->string('profile_image', 255);
            $table->string('password');
            $table->string('ref_code', 6)->unique();
            $table->timestamp('created_date')->useCurrent();
            $table->timestamp('updated_date')->useCurrent()->useCurrentOnUpdate();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');

        // Recreate the original users table
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });
    }
};
