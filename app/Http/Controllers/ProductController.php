<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;

class ProductController extends Controller
{

    public function index()
    {
        return Product::paginate(10);
    }

    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'description' => 'nullable|string',
        ]);

        $product = Product::create($validatedData);

        return response()->json($product, 201);
    }

    public function show(string $id)
    {
        $product = Product::findOrFail($id);
        return response()->json($product);
    }

    public function update(Request $request, string $id)
    {
        $product = Product::findOrFail($id);

        $validatedData = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'price' => 'sometimes|required|numeric|min:0',
            'stock' => 'sometimes|required|integer|min:0',
            'description' => 'nullable|string',
        ]);

        $product->update($validatedData);

        return response()->json($product);
    }

    public function destroy(string $id)
    {
        $product = Product::findOrFail($id);
        $product->delete();

        return response()->json(null, 204);
    }

    public function syncProducts()
    {
        Artisan::call('app:sync-products');
        return response()->json(['message' => 'Product synchronization initiated.'], 200);
    }
}
