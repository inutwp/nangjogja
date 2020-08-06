<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;

class TestController extends Controller
{
	public function home()
	{
		return view('welcome');
	}

    public function infoServer()
    {
    	// ob_start();
    	// return phpinfo();
    	return view('welcome');
    }
}
