<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Health check endpoint for CI/CD and load balancers
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'app' => config('app.name'),
        'version' => '1.0.0',
        'environment' => config('app.env'),
        'php_version' => PHP_VERSION,
        'laravel_version' => app()->version(),
    ], 200);
});
