<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ApiTesterController extends Controller
{
    /**
     * Show the API tester page.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        return view('api-tester');
    }
}
