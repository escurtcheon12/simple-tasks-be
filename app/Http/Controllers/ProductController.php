<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;

class ProductController extends Controller
{
<<<<<<< HEAD

=======
    /**
     * Display a listing of the resource.
     */
>>>>>>> 26dede97a3ec903688ce451e63b8f4a0611c0bf4
    public function index()
    {
        return Product::paginate(10);
    }

<<<<<<< HEAD
=======
    /**
     * Store a newly created resource in storage.
     */
>>>>>>> 26dede97a3ec903688ce451e63b8f4a0611c0bf4
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

<<<<<<< HEAD
=======
    /**
     * Display the specified resource.
     */
>>>>>>> 26dede97a3ec903688ce451e63b8f4a0611c0bf4
    public function show(string $id)
    {
        $product = Product::findOrFail($id);
        return response()->json($product);
    }

<<<<<<< HEAD
=======
    /**
     * Update the specified resource in storage.
     */
>>>>>>> 26dede97a3ec903688ce451e63b8f4a0611c0bf4
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

<<<<<<< HEAD
=======
    /**
     * Remove the specified resource from storage.
     */
>>>>>>> 26dede97a3ec903688ce451e63b8f4a0611c0bf4
    public function destroy(string $id)
    {
        $product = Product::findOrFail($id);
        $product->delete();

        return response()->json(null, 204);
    }

<<<<<<< HEAD
=======
    /**
     * Sync products from external API.
     */
>>>>>>> 26dede97a3ec903688ce451e63b8f4a0611c0bf4
    public function syncProducts()
    {
        Artisan::call('app:sync-products');
        return response()->json(['message' => 'Product synchronization initiated.'], 200);
    }
}
