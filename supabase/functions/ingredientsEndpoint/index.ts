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
    appliances: { name: string }[];
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
        const { action, userId, recipeData, ingredientName, course, spiceLevel, cuisine, category, recipeid, applianceName } = await req.json();

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
            case 'getUserRecipes': // uploaded recipes
                return getUserRecipes(userId, corsHeaders); 
            case 'getUserFavourites':
                return getUserFavourites(userId, corsHeaders);
            case 'getRecipesByCourse':
                return getRecipesByCourse(course, corsHeaders);  
            case 'getRecipesBySpiceLevel':
                return getRecipesBySpiceLevel(spiceLevel, corsHeaders);      
            case 'getRecipesByCuisine':
                return getRecipesByCuisine(cuisine, corsHeaders); 
            case 'getAllRecipes':
                return getAllRecipes(corsHeaders);
            case 'getIngredientsByCategory':
                return getIngredientsByCategory(category, corsHeaders);
            case 'getCategoryOfIngredient':
                return getCategoryOfIngredient(ingredientName, corsHeaders);
            case 'getIngredientNameAndCategory':
                return getIngredientNameAndCategory(corsHeaders);
            case 'getRecipe':
                return getRecipe(recipeid, corsHeaders);
            case 'getAllAppliances':
                return getAllAppliances(corsHeaders);
            case 'addUserAppliance':
                return addUserAppliance(userId, applianceName, corsHeaders);
            case 'getUserAppliances':
                return getUserAppliances(userId, corsHeaders);
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
        const { 
            name, 
            description, 
            methods, 
            cookTime, 
            cuisine, 
            spiceLevel, 
            prepTime, 
            course, 
            servingAmount, 
            ingredients, 
            appliances 
        } = recipeData;

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

        // Insert ingredients
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

        // Insert appliances
        for (const appliance of appliances) {
            const { data: applianceData, error: applianceError } = await supabase
                .from('appliances')
                .select('applianceid')
                .eq('name', appliance.name)
                .single();

            if (applianceError) {
                console.error('Error fetching appliance:', applianceError);
                return new Response(JSON.stringify({ error: `Appliance not found: ${appliance.name}` }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }

            const applianceId = applianceData?.applianceid;

            if (!applianceId) {
                console.error(`Failed to retrieve appliance ID for ${appliance.name}`);
                return new Response(JSON.stringify({ error: `Failed to retrieve appliance ID for ${appliance.name}` }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }

            const { error: recipeApplianceError } = await supabase
                .from('recipeAppliances')
                .insert({
                    recipeid: recipeId,
                    applianceid: applianceId,
                });

            if (recipeApplianceError) {
                console.error('Error inserting recipe appliance:', recipeApplianceError);
                return new Response(JSON.stringify({ error: recipeApplianceError.message }), {
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

async function getUserFavourites(userId: string, corsHeaders: HeadersInit) {
    try {
        // Ensure userId is provided
        if (!userId) {
            throw new Error('User ID is required');
        }

        // Fetch user's favorite recipes
        const { data: userFavourites, error: userFavouritesError } = await supabase
            .from('userFavorites')
            .select('recipeid')
            .eq('userid', userId);

        if (userFavouritesError) {
            throw new Error(`Error fetching user favourites: ${userFavouritesError.message}`);
        }

        if (!userFavourites || userFavourites.length === 0) {
            return new Response(JSON.stringify({ error: 'No favourite recipes found for this user' }), {
                status: 404,
                headers: corsHeaders,
            });
        }

        const recipeIds = userFavourites.map(favourite => favourite.recipeid);

        // Fetch recipes based on recipe IDs
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('*')
            .in('recipeid', recipeIds);

        if (recipesError) {
            throw new Error(`Error fetching recipes: ${recipesError.message}`);
        }

        return new Response(JSON.stringify(recipes), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        console.error('Error in getUserFavourites function:', error);
        return new Response(JSON.stringify({ error: error.message }), {
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

async function getIngredientsByCategory(category: string, corsHeaders: HeadersInit) {
    try {
        const { data: ingredients, error: ingredientsError } = await supabase
            .from('ingredient')
            .select('*')
            .eq('category', category);

        if (ingredientsError) {
            console.error('Error fetching ingredients by category:', ingredientsError);
            return new Response(JSON.stringify({ error: ingredientsError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(ingredients), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getIngredientsByCategory function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getCategoryOfIngredient(ingredient_name: string, corsHeaders: HeadersInit) {
    try {
        const { data: ingredient, error: ingredientError } = await supabase
            .from('ingredient')
            .select('category')
            .eq('name', ingredient_name)
            .single();

        if (ingredientError) {
            console.error('Error fetching ingredient category:', ingredientError);
            return new Response(JSON.stringify({ error: ingredientError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(ingredient), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getCategoryOfIngredient function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getIngredientNameAndCategory(corsHeaders: HeadersInit) {
    try {
        const { data: ingredients, error: ingredientsError } = await supabase
            .from('ingredient')
            .select('name, category');

        if (ingredientsError) {
            console.error('Error fetching ingredients with categories:', ingredientsError);
            return new Response(JSON.stringify({ error: ingredientsError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify(ingredients), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error('Error in getIngredientNameAndCategory function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getRecipe(recipeId: string, corsHeaders: HeadersInit) {
    try {
        // Ensure recipeId is provided
        if (!recipeId) {
            throw new Error('Recipe ID is required');
        }

        // Fetch recipe details
        const { data: recipeData, error: recipeError } = await supabase
            .from('recipe')
            .select('*')
            .eq('recipeid', recipeId)
            .single();

        if (recipeError) {
            throw new Error(`Error fetching recipe: ${recipeError.message}`);
        }

        if (!recipeData) {
            throw new Error(`Recipe not found for ID: ${recipeId}`);
        }

        // Fetch recipe appliances
        const { data: appliancesData, error: appliancesError } = await supabase
            .from('recipeAppliances')
            .select('applianceid')
            .eq('recipeid', recipeId);

        if (appliancesError) {
            throw new Error(`Error fetching recipe appliances: ${appliancesError.message}`);
        }

        // Fetch appliance names based on appliance ids
        const applianceIds = appliancesData.map(appliance => appliance.applianceid);
        const { data: applianceNamesData, error: applianceNamesError } = await supabase
            .from('appliances')
            .select('name')
            .in('applianceid', applianceIds);

        if (applianceNamesError) {
            throw new Error(`Error fetching appliance names: ${applianceNamesError.message}`);
        }

        const applianceNames = applianceNamesData.map(appliance => appliance.name);

        // Fetch recipe ingredients
        const { data: ingredientsData, error: ingredientsError } = await supabase
            .from('recipeingredients')
            .select('ingredientid, quantity, measurementunit')
            .eq('recipeid', recipeId);

        if (ingredientsError) {
            throw new Error(`Error fetching recipe ingredients: ${ingredientsError.message}`);
        }

        // Fetch ingredient names based on ingredient ids
        const ingredientIds = ingredientsData.map(ingredient => ingredient.ingredientid);
        const { data: ingredientNamesData, error: ingredientNamesError } = await supabase
            .from('ingredient')
            .select('ingredientid, name')
            .in('ingredientid', ingredientIds);

        if (ingredientNamesError) {
            throw new Error(`Error fetching ingredient names: ${ingredientNamesError.message}`);
        }

        const ingredients = ingredientsData.map(ingredient => {
            const ingredientName = ingredientNamesData.find(nameData => nameData.ingredientid === ingredient.ingredientid)?.name;
            return {
                ingredientid: ingredient.ingredientid,
                name: ingredientName,
                quantity: ingredient.quantity,
                measurementunit: ingredient.measurementunit,
            };
        });

        // Create a custom object with the desired structure
        const recipe = {
            recipeId: recipeData.recipeid,
            name: recipeData.name,
            description: recipeData.description,
            steps: recipeData.steps,
            cooktime: recipeData.cooktime,
            cuisine: recipeData.cuisine,
            spicelevel: recipeData.spicelevel,
            preptime: recipeData.preptime,
            course: recipeData.course,
            keywords: recipeData.keywords,
            servings: recipeData.servings,
            photo: recipeData.photo,
            appliances: applianceNames,
            ingredients: ingredients,
        };

        // Stringify the custom object and return the JSON response
        return new Response(JSON.stringify(recipe, null, 2), {
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

async function getAllAppliances(corsHeaders: HeadersInit) {
    try {
        // Fetch all appliances
        const { data: appliancesData, error: appliancesError } = await supabase
            .from('appliances')
            .select('applianceid, name');

        if (appliancesError) {
            throw new Error(`Error fetching appliances: ${appliancesError.message}`);
        }

        return new Response(JSON.stringify(appliancesData, null, 2), {
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

async function addUserAppliance(userId: string, applianceName: string, corsHeaders: HeadersInit) {
    try {
        // Ensure userId and applianceName are provided
        if (!userId || !applianceName) {
            throw new Error('User ID and Appliance Name are required');
        }

        // Fetch the appliance ID based on the appliance name
        const { data: applianceData, error: applianceError } = await supabase
            .from('appliances')
            .select('applianceid')
            .eq('name', applianceName)
            .single();

        if (applianceError) {
            console.error('Error fetching appliance:', applianceError);
            return new Response(JSON.stringify({ error: applianceError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        const applianceId = applianceData?.applianceid;

        if (!applianceId) {
            console.error(`Failed to retrieve appliance ID for ${applianceName}`);
            return new Response(JSON.stringify({ error: `Failed to retrieve appliance ID for ${applianceName}` }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        // Insert into userAppliances table
        const { error: userApplianceError } = await supabase
            .from('userAppliances')
            .insert({ userid: userId, applianceid: applianceId })
            .select('*')
            .single();

        if (userApplianceError) {
            console.error('Error inserting user appliance:', userApplianceError);
            return new Response(JSON.stringify({ error: userApplianceError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ success: true }), {
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        console.error('Error in addUserAppliance function:', error);
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function getUserAppliances(userId: string, corsHeaders: HeadersInit) {
    try {
        // Ensure userId is provided
        if (!userId) {
            throw new Error('User ID is required');
        }

        // Fetch user appliances for the specified user
        const { data: userAppliancesData, error: userAppliancesError } = await supabase
            .from('userAppliances')
            .select('applianceid')
            .eq('userid', userId);

        if (userAppliancesError) {
            console.error('Error fetching user appliances:', userAppliancesError);
            return new Response(JSON.stringify({ error: userAppliancesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        if (!userAppliancesData || userAppliancesData.length === 0) {
            return new Response(JSON.stringify({ error: 'No appliances found for this user' }), {
                status: 404,
                headers: corsHeaders,
            });
        }

        // Extract appliance ids
        const applianceIds = userAppliancesData.map(userAppliance => userAppliance.applianceid);

        // Fetch appliance names based on appliance ids
        const { data: appliancesData, error: appliancesError } = await supabase
            .from('appliances')
            .select('applianceid, name')
            .in('applianceid', applianceIds);

        if (appliancesError) {
            console.error('Error fetching appliances:', appliancesError);
            return new Response(JSON.stringify({ error: appliancesError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        // Combine user appliances with appliance names
        const userAppliances = userAppliancesData.map(userAppliance => {
            const appliance = appliancesData.find(appliance => appliance.applianceid === userAppliance.applianceid);
            return {
                applianceid: userAppliance.applianceid,
                applianceName: appliance ? appliance.name : 'Unknown'
            };
        });

        return new Response(JSON.stringify(userAppliances, null, 2), {
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        console.error('Error in getUserAppliances function:', error);
        return new Response(JSON.stringify({ error: error.message }), {
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