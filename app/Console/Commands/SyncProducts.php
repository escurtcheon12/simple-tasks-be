<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class SyncProducts extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:sync-products';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Sync products from FakeStoreAPI into the local database.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting product synchronization...');

        $response = Http::get('https://fakestoreapi.com/products');

        if ($response->successful()) {
            $externalProducts = $response->json();

            foreach ($externalProducts as $externalProduct) {
                Product::updateOrCreate(
                    ['name' => $externalProduct['title']],
                    [
                        'price' => $externalProduct['price'],
                        'stock' => rand(1, 100), // Fake stock as external API doesn't provide it
                        'description' => $externalProduct['description'],
                    ]
                );
                $this->info("Synchronized product: {$externalProduct['title']}");
            }

            $this->info('Product synchronization completed successfully!');
        } else {
            $this->error('Failed to fetch products from FakeStoreAPI.');
            $this->error('Status: ' . $response->status());
            $this->error('Response: ' . $response->body());
        }
    }
}
