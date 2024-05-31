/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'

// Create the Supabase Client
const supURL = Deno.env.get("_SUPABASE_URL") as string;
const supKey = Deno.env.get("_SUPABASE_ANON_KEY") as string;
const supabase = createClient(supURL, supKey);

console.log("Hello from Ingredient Endpoint!")

Deno.serve(async (req) => {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
    };

    if (req.method === "OPTIONS") {
        return new Response(null, {
            headers: corsHeaders,
        });
    }

    try {
        const { action, userId } = await req.json();

        switch (action) {
            case 'getAllIngredients':
                return getAllIngredients();
            case 'getIngredientNames':
                return getIngredientNames();
            case 'getShoppingList':
                return getShoppingList(userId);
            default:
                return new Response(JSON.stringify({ error: 'Invalid action' }), {
                    status: 400,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                });
        }
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
});

async function getAllIngredients() {
    try {
        const { data: ingredients, error } = await supabase
            .from('ingredient')
            .select('*');

        if (error) {
            throw new Error(error.message);
        }

        return new Response(JSON.stringify(ingredients), {
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
}

async function getIngredientNames() {
    try {
        const { data: ingredients, error } = await supabase
            .from('ingredient')
            .select('ingredientid, name');

        if (error) {
            throw new Error(error.message);
        }

        const ingredientNames = ingredients.map(ingredient => ({
            id: ingredient.ingredientid,
            name: ingredient.name
        }));

        return new Response(JSON.stringify(ingredientNames), {
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
}

async function getShoppingList(userId: string) {
  try {
      if (!userId) {
          throw new Error('User ID is required');
      }

      // Fetch shopping list items
      const { data: shoppingListItems, error: shoppingListError } = await supabase
          .from('shoppinglist')
          .select('slid, ingredientid, quantity, measurmentunit')
          .eq('userid', userId);

      if (shoppingListError) {
          throw new Error(shoppingListError.message);
      }

      // Fetch ingredients
      const { data: ingredients, error: ingredientsError } = await supabase
          .from('ingredient')
          .select('ingredientid, name');

      if (ingredientsError) {
          throw new Error(ingredientsError.message);
      }

      // Combine shopping list items with ingredient names
      const shoppingList = shoppingListItems.map(item => {
          const ingredient = ingredients.find(ingredient => ingredient.ingredientid === item.ingredientid);
          return {
              slid: item.slid,
              ingredientid: item.ingredientid,
              quantity: item.quantity,
              measurmentunit: item.measurmentunit,
              ingredientName: ingredient ? ingredient.name : 'Unknown',
          };
      });

      return new Response(
          JSON.stringify({ shoppingList }),
          { status: 200, headers: { 'Content-Type': 'application/json' } }
      );
  } catch (error) {
      return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
      });
  }
}


/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/ingredientsEndpoint' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
