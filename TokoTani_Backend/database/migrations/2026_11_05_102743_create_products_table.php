<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up(): void
{
    Schema::create('categories', function (Blueprint $table) {
        $table->id();
        $table->string('nama_kategori');
        $table->timestamps();
    });

    Schema::create('products', function (Blueprint $table) {
        $table->id();
        $table->string('nama');
        $table->integer('harga');
        $table->string('kategori');
        $table->integer('stok');
        $table->boolean('tersedia')->default(true);
        $table->text('deskripsi')->nullable();
        $table->string('satuan_jual'); // Atribut khas pertanian[cite: 1, 8]
        $table->boolean('mudah_rusak'); // Atribut khas pertanian[cite: 1, 8]
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
