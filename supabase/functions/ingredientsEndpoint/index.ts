/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'

// Define the structure of the recipeData object
interface RecipeData {
  name: string;
  description: string;
  methods: string;
  cookTime: number;
  cuisine: string;
  spiceLevel: number;
  prepTime: number;
  course: string;
  servingAmount: number;
  ingredients: { name: string, quantity: number, unit: string }[];
}

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
        const { action, userId, recipeData } = await req.json();

        switch (action) {
            case 'getAllIngredients':
                return getAllIngredients();
            case 'getIngredientNames':
                return getIngredientNames();
            case 'getShoppingList':
                return getShoppingList(userId);
            case 'getAvailableIngredients': // the pantry list
                return getAvailableIngredients(userId); 
            case 'addRecipe':
              return addRecipe(recipeData);               
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

// Get all the ingredients and their attributes
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

// Get all the ingredient names and their ids
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

// Get the shopping list per user id
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

// Get the pantry list per user id
async function getAvailableIngredients(userId: string) {
  try {
    if (!userId) {
      throw new Error('User ID is required');
    }

    // Fetch available ingredients
    const { data: availableIngredients, error: availableIngredientsError } = await supabase
      .from('availableingredients')
      .select('ingredientid, quantity, measurmentunit')
      .eq('userid', userId);

    if (availableIngredientsError) {
      throw new Error(availableIngredientsError.message);
    }

    // Fetch ingredient names
    const ingredientIds = availableIngredients.map(item => item.ingredientid);
    const { data: ingredients, error: ingredientsError } = await supabase
      .from('ingredient')
      .select('ingredientid, name')
      .in('ingredientid', ingredientIds);

    if (ingredientsError) {
      throw new Error(ingredientsError.message);
    }

    // Combine available ingredients with names
    const availableIngredientsWithNames = availableIngredients.map(item => {
      const ingredient = ingredients.find(ingredient => ingredient.ingredientid === item.ingredientid);
      return {
        ingredientid: item.ingredientid,
        quantity: item.quantity,
        measurmentunit: item.measurmentunit,
        name: ingredient ? ingredient.name : 'Unknown',
      };
    });

    return new Response(
      JSON.stringify({ availableIngredients: availableIngredientsWithNames }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

// Add recipe to the db from the form
async function addRecipe(recipeData: RecipeData) {
  try {
      const { name, description, methods, cookTime, cuisine, spiceLevel, prepTime, course, servingAmount, ingredients } = recipeData;

      // Insert the recipe
      const { data: insertedRecipeData, error: recipeError } = await supabase
          .from('recipe')
          .insert({
              name,
              description,
              steps: methods, // Save the methods directly in the recipe table
              cooktime: cookTime,
              cuisine,
              spicelevel: spiceLevel,
              preptime: prepTime,
              course,
              servings: servingAmount,
          })
          .select('recipeid') // Select only the recipe ID
          .single();

      if (recipeError) {
          return new Response(JSON.stringify({ error: recipeError.message }), { status: 400 });
      }

      const recipeId = insertedRecipeData?.recipeid; // Extract the recipe ID

      // Check if recipeId is null or undefined
      if (!recipeId) {
          return new Response(JSON.stringify({ error: 'Failed to retrieve recipe ID' }), { status: 400 });
      }

      // Insert ingredients
      for (const ingredient of ingredients) {
          const { data: ingredientData, error: ingredientError } = await supabase
              .from('ingredient')
              .select('ingredientid')
              .eq('name', ingredient.name)
              .single();

          if (ingredientError) {
              return new Response(JSON.stringify({ error: `Ingredient not found: ${ingredient.name}` }), { status: 400 });
          }

          const ingredientId = ingredientData?.ingredientid; // Extract the ingredient ID

          // Check if ingredientId is null or undefined
          if (!ingredientId) {
              return new Response(JSON.stringify({ error: `Failed to retrieve ingredient ID for ${ingredient.name}` }), { status: 400 });
          }

          // Insert into recipeingredients with the fetched recipeId
          const { error: recipeIngredientError } = await supabase
              .from('recipeingredients')
              .insert({
                  recipeid: recipeId,
                  ingredientid: ingredientId,
                  quantity: ingredient.quantity,
                  measurmentunit: ingredient.unit,
              });

          if (recipeIngredientError) {
              return new Response(JSON.stringify({ error: recipeIngredientError.message }), { status: 400 });
          }
      }

      return new Response(JSON.stringify({ success: true, recipeId }), { status: 200 });
  } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 500 });
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
