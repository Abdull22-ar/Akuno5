<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Schema;

class ProductController extends Controller
{
    private function jsonResponse($status, $code, $message, $data = null, $errors = null)
    {
        $response = [
            'status'  => $status,
            'code'    => (string) $code,
            'message' => $message,
        ];

        if ($data !== null) {
            $response['data'] = $data;
        }

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        return response()->json($response, (int) $code);
    }

    public function index(Request $request)
    {
        $query = Product::query();

        if ($request->has('kategori') && !empty($request->kategori)) {
            $query->where('kategori', $request->kategori);
        }

        if ($request->has('cari') && !empty($request->cari)) {
            $query->where('nama', 'like', '%' . $request->cari . '%');
        }

        $products = $query->get();

        return $this->jsonResponse(
            'sukses',
            200,
            'Daftar produk berhasil diambil',
            $products
        );
    }

    public function show($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return $this->jsonResponse(
                'gagal',
                404,
                'Produk tidak ditemukan'
            );
        }

        return $this->jsonResponse(
            'sukses',
            200,
            'Rincian produk berhasil diambil',
            $product
        );
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama'        => 'required|string|max:255',
            'harga'       => 'required|integer|min:0',
            'kategori'    => 'required|string',
            'stok'        => 'required|integer|min:0',
            'tersedia'    => 'required|boolean',
            'deskripsi'   => 'nullable|string',
            'satuan_jual' => 'required|string',
            'mudah_rusak' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return $this->jsonResponse(
                'gagal',
                422,
                'Data yang dikirim tidak lengkap',
                null,
                $validator->errors()
            );
        }

        $product = Product::create($request->all());

        return $this->jsonResponse(
            'sukses',
            201,
            'Produk berhasil ditambahkan',
            $product
        );
    }

    public function update(Request $request, $id)
    {
        $product = Product::find($id);

        if (!$product) {
            return $this->jsonResponse(
                'gagal',
                404,
                'Produk tidak ditemukan'
            );
        }

        $validator = Validator::make($request->all(), [
            'nama'        => 'sometimes|required|string|max:255',
            'harga'       => 'sometimes|required|integer|min:0',
            'kategori'    => 'sometimes|required|string',
            'stok'        => 'sometimes|required|integer|min:0',
            'tersedia'    => 'sometimes|required|boolean',
            'deskripsi'   => 'nullable|string',
            'satuan_jual' => 'sometimes|required|string',
            'mudah_rusak' => 'sometimes|required|boolean',
        ]);

        if ($validator->fails()) {
            return $this->jsonResponse(
                'gagal',
                422,
                'Validasi gagal',
                null,
                $validator->errors()
            );
        }

        $product->update($request->all());

        return $this->jsonResponse(
            'sukses',
            200,
            'Produk berhasil diperbarui',
            $product
        );
    }

    public function destroy($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return $this->jsonResponse(
                'gagal',
                404,
                'Produk tidak ditemukan'
            );
        }

        // Pengecekan aman: hanya jalankan aturan 409 jika tabel order_details benar-benar sudah ada
        if (Schema::hasTable('order_details')) {
            $isUsed = $product->orderDetails()->whereHas('order', function ($query) {
                $query->whereNotIn('status', ['selesai', 'dibatalkan']);
            })->exists();

            if ($isUsed) {
                return $this->jsonResponse(
                    'gagal',
                    409,
                    'Produk tidak dapat dihapus karena masih terpakai pada pesanan aktif'
                );
            }
        }

        $product->delete();

        return $this->jsonResponse(
            'sukses',
            200,
            'Produk berhasil dihapus'
        );
    }
}