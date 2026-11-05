<?php

use App\Http\Controllers\ProductController;
use Illuminate\Support\Facades\Route;

Route::get('/produk', [ProductController::class, 'index']);
Route::get('/produk/{id}', [ProductController::class, 'show']);
Route::post('/produk', [ProductController::class, 'store']);
Route::put('/produk/{id}', [ProductController::class, 'update']);
Route::delete('/produk/{id}', [ProductController::class, 'destroy']);