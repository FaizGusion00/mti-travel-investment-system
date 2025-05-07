<?php

namespace App\Observers;

use App\Models\User;

class UserObserver
{
    /**
     * Handle the User "updated" event.
     */
    public function updated(User $user): void
    {
        // If cash_wallet has been updated
        if ($user->isDirty('cash_wallet')) {
            // Check if cash_wallet exceeds 1000 and user is pending
            if ($user->cash_wallet >= 1000 && $user->status === 'pending') {
                // Update user to approved status
                $user->status = 'approved';
                // Save without triggering the observer again
                $user->saveQuietly();
            }
        }
    }
}
