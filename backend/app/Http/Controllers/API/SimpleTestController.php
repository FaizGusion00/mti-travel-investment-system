<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SimpleTestController extends Controller
{
    /**
     * A simple test endpoint that doesn't require any database access
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function test()
    {
        return response()->json([
            'status' => 'success',
            'message' => 'API is working correctly',
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * A simple authenticated test endpoint
     * 
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function authTest(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'message' => 'You are authenticated!',
            'user' => $request->user(),
            'timestamp' => now()->toIso8601String(),
        ]);
    }
}
