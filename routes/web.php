<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dbcheck', function () {
    try {
        \Illuminate\Support\Facades\DB::connection()->getPdo();
        return 'DB Connected: ' . \Illuminate\Support\Facades\DB::connection()->getDatabaseName();
    } catch (\Exception $e) {
        return 'DB Error: ' . $e->getMessage();
    }
});
