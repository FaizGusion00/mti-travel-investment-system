<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'transactions';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'transaction_id';

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'wallet_type',
        'from_account',
        'to_account',
        'amount',
        'status',
        'created_at',
    ];

    /**
     * Get the sender user record associated with the transaction.
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'from_account');
    }

    /**
     * Get the recipient user record associated with the transaction.
     */
    public function recipient()
    {
        return $this->belongsTo(User::class, 'to_account');
    }
}
