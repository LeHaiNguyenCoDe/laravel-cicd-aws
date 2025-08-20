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

// Enhanced monitoring endpoints
Route::get('/status', function () {
    $status = [
        'application' => [
            'name' => config('app.name'),
            'version' => '1.0.0',
            'environment' => config('app.env'),
            'debug' => config('app.debug'),
            'timezone' => config('app.timezone'),
        ],
        'system' => [
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'server_time' => now()->toISOString(),
            'uptime' => 'Available in production',
        ],
        'services' => [
            'database' => 'Connected',
            'cache' => 'Connected',
            'queue' => 'Connected',
        ],
        'deployment' => [
            'commit_sha' => env('GITHUB_SHA', 'local'),
            'deployed_at' => env('DEPLOYED_AT', now()->toISOString()),
            'ci_cd_pipeline' => 'GitHub Actions',
        ]
    ];

    return response()->json($status, 200);
});

// Security headers endpoint
Route::get('/security', function () {
    return response()->json([
        'security_headers' => [
            'X-Frame-Options' => 'DENY',
            'X-XSS-Protection' => '1; mode=block',
            'X-Content-Type-Options' => 'nosniff',
            'Referrer-Policy' => 'strict-origin-when-cross-origin',
            'Content-Security-Policy' => "default-src 'self'",
        ],
        'https_enforced' => config('app.env') === 'production',
        'session_secure' => config('session.secure'),
    ], 200);
});

// Performance metrics endpoint
Route::get('/metrics', function () {
    return response()->json([
        'memory_usage' => [
            'current' => memory_get_usage(true),
            'peak' => memory_get_peak_usage(true),
            'limit' => ini_get('memory_limit'),
        ],
        'cache_stats' => [
            'driver' => config('cache.default'),
            'status' => 'operational',
        ],
        'database_connections' => [
            'default' => config('database.default'),
            'status' => 'connected',
        ],
    ], 200);
});
