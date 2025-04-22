<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class IsAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if user is authenticated and is an admin
        if (!$request->user() || !$this->isAdmin($request->user())) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        return $next($request);
    }

    /**
     * Check if the user is an admin.
     * This is a placeholder - you would implement your own admin check logic.
     * 
     * @param  \App\Models\User  $user
     * @return bool
     */
    private function isAdmin($user): bool
    {
        // For example, you might check for an admin flag or specific email domains
        // For now, we'll just check if the user has a specific ref_code
        return $user->ref_code === 'ADMIN';
    }
}
