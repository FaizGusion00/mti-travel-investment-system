<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'users';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'id';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'full_name',
        'email',
        'phonenumber',
        'address',
        'date_of_birth',
        'affiliate_code',
        'referral_id',
        'profile_image',
        'usdt_address',
        'password',
        'is_trader',
        'status',
        'cash_wallet',
        'voucher_wallet',
        'travel_wallet',
        'xlm_wallet',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'date_of_birth' => 'date',
        'password' => 'hashed',
        'is_trader' => 'boolean',
        'cash_wallet' => 'decimal:2',
        'voucher_wallet' => 'decimal:2',
        'travel_wallet' => 'decimal:2',
        'xlm_wallet' => 'decimal:2',
    ];

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The name of the "created at" column.
     *
     * @var string
     */
    const CREATED_AT = 'created_at';

    /**
     * The name of the "updated at" column.
     *
     * @var string
     */
    const UPDATED_AT = 'updated_date';

    /**
     * Get the logs for the user.
     */
    public function logs()
    {
        return $this->hasMany(UserLog::class, 'user_id', 'user_id');
    }

    /**
     * Get the URL for the user's profile image.
     */
    public function getProfileImageUrlAttribute()
    {
        if ($this->profile_image) {
            // Handle both new path format (with 'avatars/' prefix) and old format
            if (strpos($this->profile_image, 'avatars/') === 0) {
                return asset('storage/' . $this->profile_image);
            } else {
                return asset('storage/avatars/' . $this->profile_image);
            }
        }
        // Return default avatar if none exists
        return asset('storage/avatars/default.png');
    }

    /**
     * Check if the user is a trader.
     *
     * @return bool
     */
    public function isTrader()
    {
        return (bool) $this->is_trader;
    }
    
    /**
     * Get the user who referred this user.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function referrer()
    {
        return $this->belongsTo(User::class, 'referral_id');
    }
    
    /**
     * Get the users who were referred by this user.
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function referrals()
    {
        return $this->hasMany(User::class, 'referral_id');
    }
}
