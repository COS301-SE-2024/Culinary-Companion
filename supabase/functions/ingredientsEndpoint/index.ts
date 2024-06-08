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
const supURL = Deno.env.get("_SUPABASE_URL") as string || 'http://localhost:54321';
const supKey = Deno.env.get("_SUPABASE_ANON_KEY") as string;
const supabase = createClient(supURL, supKey);

console.log("Hello from Ingredient Endpoint!")

Deno.serve(async (req) => {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    };

    if (req.method === "OPTIONS") {
        return new Response(null, {
            headers: corsHeaders,
        });
    }

    try {
        const { action, userId, recipeData, ingredientName, course, spiceLevel, cuisine } = await req.json();

        switch (action) {
            case 'getAllIngredients':
                return getAllIngredients(corsHeaders);
            case 'getIngredientNames':
                return getIngredientNames(corsHeaders);
            case 'getShoppingList':
                return getShoppingList(userId, corsHeaders);
            case 'getAvailableIngredients': // the pantry list
                return getAvailableIngredients(userId, corsHeaders); 
            case 'addRecipe':
              return addRecipe(userId, recipeData, corsHeaders);
            case 'addToShoppingList':
              return addToShoppingList(userId, ingredientName);
            case 'addToPantryList':
              return addToPantryList(userId, ingredientName);
            case 'removeFromShoppingList':
              return removeFromShoppingList(userId, ingredientName);
            case 'removeFromPantryList':
              return removeFromPantryList(userId, ingredientName);  
            case 'getUserRecipes':
                return getUserRecipes(userId, corsHeaders); 
            case 'getRecipesByCourse':
                return getRecipesByCourse(course, corsHeaders);  
            case 'getRecipesBySpiceLevel':
                return getRecipesBySpiceLevel(spiceLevel, corsHeaders);      
            case 'getRecipesByCuisine':
                return getRecipesByCuisine(cuisine, corsHeaders); 
            case 'getAllRecipes':
                return getAllRecipes(corsHeaders);
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
async function getAllIngredients(corsHeaders: HeadersInit) {
    try {
        const { data: ingredients, error } = await supabase
            .from('ingredient')
            .select('*');

        if (error) {
            throw new Error(error.message);
        }

        return new Response(JSON.stringify(ingredients), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }
}

// Get all the ingredient names and their ids
async function getIngredientNames(corsHeaders: HeadersInit) {
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
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }
}

// Get the shopping list per user id
async function getShoppingList(userId: string, corsHeaders: HeadersInit) {
    try {
        if (!userId) {
            throw new Error('User ID is required');
        }

        // Fetch shopping list items
        const { data: shoppingListItems, error: shoppingListError } = await supabase
            .from('shoppinglist')
            .select('shoppingid, ingredientid, quantity, measurmentunit')
            .eq('userid', userId);

        if (shoppingListError) {
            throw new Error(shoppingListError.message);
        }

        // Fetch ingredients
        const { data: ingredients, error: ingredientsError } = await supabase
            .from('ingredient')
            .select('ingredientid, name, category');

        if (ingredientsError) {
            throw new Error(ingredientsError.message);
        }

        // Combine shopping list items with ingredient names
        const shoppingList = shoppingListItems.map(item => {
            const ingredient = ingredients.find(ingredient => ingredient.ingredientid === item.ingredientid);
            return {
                shoppingid: item.shoppingid,
                ingredientid: item.ingredientid,
                quantity: item.quantity,
                measurmentunit: item.measurmentunit,
                ingredientName: ingredient ? ingredient.name : 'Unknown',
                category: ingredient ? ingredient.category : 'Unknown',
            };
        });

        return new Response(
            JSON.stringify({ shoppingList }),
            { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }
}

// Get the pantry list per user id
async function getAvailableIngredients(userId: string, corsHeaders: HeadersInit) {
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
            .select('ingredientid, name, category')
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
                category: ingredient ? ingredient.category : 'Unknown',
            };
        });

        return new Response(
            JSON.stringify({ availableIngredients: availableIngredientsWithNames }),
            { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
    }
}

// Add recipe to the db from the form
async function addRecipe(userId: string, recipeData: RecipeData, corsHeaders: HeadersInit) {
    try {
        const { name, description, methods, cookTime, cuisine, spiceLevel, prepTime, course, servingAmount, ingredients } = recipeData;

        // Insert the recipe
        const { data: insertedRecipeData, error: recipeError } = await supabase
            .from('recipe')
            .insert({
                name,
                description,
                steps: methods,
                cooktime: cookTime,
                cuisine,
                spicelevel: spiceLevel,
                preptime: prepTime,
                course,
                servings: servingAmount,
            })
            .select('recipeid')
            .single();

        if (recipeError) {
            console.error('Error inserting recipe:', recipeError);
            return new Response(JSON.stringify({ error: recipeError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        const recipeId = insertedRecipeData?.recipeid;

        if (!recipeId) {
            console.error('Failed to retrieve recipe ID');
            return new Response(JSON.stringify({ error: 'Failed to retrieve recipe ID' }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        const { error: userRecipeError } = await supabase
            .from('userUploadedRecipes')
            .insert({ userid: userId, recipeid: recipeId })
            .select('*')
            .single();

        if (userRecipeError) {
            console.error('Error inserting user recipe:', userRecipeError);
            return new Response(JSON.stringify({ error: userRecipeError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        for (const ingredient of ingredients) {
            const { data: ingredientData, error: ingredientError } = await supabase
                .from('ingredient')
                .select('ingredientid')
                .eq('name', ingredient.name)
                .single();

            if (ingredientError) {
                console.error('Error fetching ingredient:', ingredientError);
                return new Response(JSON.stringify({ error: `Ingredient not found: ${ingredient.name}` }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }

            const ingredientId = ingredientData?.ingredientid;

            if (!ingredientId) {
                console.error(`Failed to retrieve ingredient ID for ${ingredient.name}`);
                return new Response(JSON.stringify({ error: `Failed to retrieve ingredient ID for ${ingredient.name}` }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }

            const { error: recipeIngredientError } = await supabase
                .from('recipeingredients')
                .insert({
                    recipeid: recipeId,
                    ingredientid: ingredientId,
                    quantity: ingredient.quantity,
                    measurementunit: ingredient.unit,
                });

            if (recipeIngredientError) {
                console.error('Error inserting recipe ingredient:', recipeIngredientError);
                return new Response(JSON.stringify({ error: recipeIngredientError.message }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }
        }

        return new Response(JSON.stringify({ success: true, recipeId }), {
            status: 200,
            headers: corsHeaders,
        });
    } catch (e) {
        console.error('Error in addRecipe function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}


async function addToShoppingList(userId: string, ingredientName: string) {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json"
    };
    try {
        if (!userId || !ingredientName) {
            throw new Error('User ID and ingredient name are required');
        }

        // Get the ingredient ID from the ingredient name
        const { data: ingredientData, error: ingredientError } = await supabase
            .from('ingredient')
            .select('ingredientid')
            .eq('name', ingredientName)
            .single();

        if (ingredientError) {
            return new Response(JSON.stringify({ error: `Ingredient not found: ${ingredientName}` }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        const ingredientId = ingredientData?.ingredientid;

        if (!ingredientId) {
            return new Response(JSON.stringify({ error: `Failed to retrieve ingredient ID for ${ingredientName}` }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        // Insert the ingredient into the shopping list
        const { error: shoppingListError } = await supabase
            .from('shoppinglist')
            .insert({
                userid: userId,
                ingredientid: ingredientId,
                quantity: 1, // Default quantity, adjust as needed
                measurmentunit: 'unit' // Default measurement unit, adjust as needed
            });

        if (shoppingListError) {
            return new Response(JSON.stringify({ error: shoppingListError.message }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ success: true }), { 
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), { 
            status: 500,
            headers: corsHeaders,
        });
    }
}

// Add an ingredient to the pantry list
async function addToPantryList(userId: string, ingredientName: string) {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json"
    };
    try {
        if (!userId || !ingredientName) {
            throw new Error('User ID and ingredient name are required');
        }

        // Get the ingredient ID from the ingredient name
        const { data: ingredientData, error: ingredientError } = await supabase
            .from('ingredient')
            .select('ingredientid')
            .eq('name', ingredientName)
            .single();

        if (ingredientError) {
            return new Response(JSON.stringify({ error: `Ingredient not found: ${ingredientName}` }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        const ingredientId = ingredientData?.ingredientid;

        if (!ingredientId) {
            return new Response(JSON.stringify({ error: `Failed to retrieve ingredient ID for ${ingredientName}` }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        // Insert the ingredient into the pantry list
        const { error: pantryListError } = await supabase
            .from('availableingredients')
            .insert({
                userid: userId,
                ingredientid: ingredientId,
                quantity: 1, // Default quantity, adjust as needed
                measurmentunit: 'unit' // Default measurement unit, adjust as needed
            });

        if (pantryListError) {
            return new Response(JSON.stringify({ error: pantryListError.message }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ success: true }), { 
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), { 
            status: 500,
            headers: corsHeaders,
        });
    }
}

// Function to remove an ingredient from the shopping list
async function removeFromShoppingList(userId: string, ingredientName: string) {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json"
    };
    try {
        if (!userId || !ingredientName) {
            return new Response(JSON.stringify({ error: 'User ID and Ingredient Name are required' }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        // Fetch ingredient ID by name
        const { data: ingredient, error: ingredientError } = await supabase
            .from('ingredient')
            .select('ingredientid')
            .eq('name', ingredientName)
            .single();

        if (ingredientError || !ingredient) {
            return new Response(JSON.stringify({ error: `Ingredient not found: ${ingredientName}` }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        const ingredientId = ingredient.ingredientid;

        // Delete ingredient from shopping list
        const { error: shoppingListError } = await supabase
            .from('shoppinglist')
            .delete()
            .eq('userid', userId)
            .eq('ingredientid', ingredientId);

        if (shoppingListError) {
            return new Response(JSON.stringify({ error: shoppingListError.message }), { 
                status: 500,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ success: true }), { 
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), { 
            status: 500,
            headers: corsHeaders,
        });
    }
}

// Function to remove an ingredient from the pantry list
async function removeFromPantryList(userId: string, ingredientName: string) {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json"
    };
    try {
        if (!userId || !ingredientName) {
            return new Response(JSON.stringify({ error: 'User ID and Ingredient Name are required' }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        // Fetch ingredient ID by name
        const { data: ingredient, error: ingredientError } = await supabase
            .from('ingredient')
            .select('ingredientid')
            .eq('name', ingredientName)
            .single();

        if (ingredientError || !ingredient) {
            return new Response(JSON.stringify({ error: `Ingredient not found: ${ingredientName}` }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        const ingredientId = ingredient.ingredientid;

        // Delete ingredient from pantry list
        const { error: pantryListError } = await supabase
            .from('availableingredients')
            .delete()
            .eq('userid', userId)
            .eq('ingredientid', ingredientId);

        if (pantryListError) {
            return new Response(JSON.stringify({ error: pantryListError.message }), { 
                status: 500,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ success: true }), { 
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), { 
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getUserRecipes(userId: string, corsHeaders: HeadersInit) {
    if (!userId) {
        throw new Error('User ID is required');
    }

    try {
        // Fetch user-uploaded recipes
        const { data: userRecipes, error: userRecipesError } = await supabase
            .from('userUploadedRecipes')
            .select('recipeid')
            .eq('userid', userId);

        if (userRecipesError) {
            console.error('Error fetching user recipes:', userRecipesError);
            return new Response(JSON.stringify({ error: userRecipesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        if (!userRecipes || userRecipes.length === 0) {
            return new Response(JSON.stringify({ error: 'No recipes found for this user' }), {
                status: 404,
                headers: corsHeaders,
            });
        }

        const recipeIds = userRecipes.map(userRecipe => userRecipe.recipeid);

        // Fetch recipes based on recipe IDs
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('*')
            .in('recipeid', recipeIds);

        if (recipesError) {
            console.error('Error fetching recipes:', recipesError);
            return new Response(JSON.stringify({ error: recipesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(recipes), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getUserRecipes function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getRecipesByCourse(course: string, corsHeaders: HeadersInit) {
    if (!course) {
        throw new Error('Course is required');
    }

    try {
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('*')
            .eq('course', course);

        if (recipesError) {
            console.error('Error fetching recipes by course:', recipesError);
            return new Response(JSON.stringify({ error: recipesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(recipes), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getRecipesByCourse function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getRecipesBySpiceLevel(spiceLevel: number, corsHeaders: HeadersInit) {
    if (spiceLevel === undefined || spiceLevel === null) {
        throw new Error('Spice level is required');
    }

    try {
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('*')
            .eq('spicelevel', spiceLevel);

        if (recipesError) {
            console.error('Error fetching recipes by spice level:', recipesError);
            return new Response(JSON.stringify({ error: recipesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(recipes), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getRecipesBySpiceLevel function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getRecipesByCuisine(cuisine: string, corsHeaders: HeadersInit) {
    if (!cuisine) {
        throw new Error('Cuisine is required');
    }

    try {
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('*')
            .eq('cuisine', cuisine);

        if (recipesError) {
            console.error('Error fetching recipes by cuisine:', recipesError);
            return new Response(JSON.stringify({ error: recipesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(recipes), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getRecipesByCuisine function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getAllRecipes(corsHeaders: HeadersInit) {
    try {
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('*');

        if (recipesError) {
            console.error('Error fetching all recipes:', recipesError);
            return new Response(JSON.stringify({ error: recipesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(recipes), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getAllRecipes function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
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