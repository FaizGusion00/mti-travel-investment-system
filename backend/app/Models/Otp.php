<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Carbon\Carbon;

class Otp extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'email',
        'otp',
        'type',
        'used',
        'expires_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'used' => 'boolean',
        'expires_at' => 'datetime',
    ];

    /**
     * Scope a query to only include valid OTPs.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeValid($query)
    {
        return $query->where('used', false)
                     ->where('expires_at', '>', Carbon::now());
    }

    /**
     * Check if the OTP is valid.
     *
     * @return bool
     */
    public function isValid()
    {
        return !$this->used && $this->valid_until > Carbon::now();
    }

    /**
     * Mark the OTP as used.
     *
     * @return bool
     */
    public function markAsUsed()
    {
        $this->used = true;
        return $this->save();
    }
}
