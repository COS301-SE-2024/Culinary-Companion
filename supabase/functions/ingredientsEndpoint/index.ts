/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
// import { privateEncrypt } from 'crypto';
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
    photo:string;
  }

  interface Filters {
    course?: string[];
    spiceLevel?: number;
    cuisine?: string[]; 
    dietaryOptions?: string[];
    ingredientOption?: string; 
  }

  interface Ingredient {
    id: number;
    name: string;
    category: string;
    measurementUnit: string;
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
        const { action, userId, recipeData, ingredientName, course, spiceLevel, cuisine, category, recipeid, applianceName, quantity,measurementUnit, searchTerm, filters, keywords, dietaryConstraints, itemName, identifiedIngredient } = await req.json();

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
              return addToShoppingList(userId, ingredientName,quantity,measurementUnit);
            case 'addToPantryList':
              return addToPantryList(userId, ingredientName,quantity,measurementUnit);
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
            case 'removeUserAppliance':
                return removeUserAppliance(userId, applianceName, corsHeaders);
            case 'getUserAppliances':
                return getUserAppliances(userId, corsHeaders);
            case 'addUserFavorite':
                return addUserFavorite(userId, recipeid, corsHeaders);
            case 'removeUserFavorite':
                return removeUserFavorite(userId, recipeid, corsHeaders);
            case 'editShoppingListItem':
                return editShoppingListItem(userId, ingredientName, quantity, measurementUnit, corsHeaders);
            case 'editPantryItem':
                return editPantryItem(userId, ingredientName, quantity, measurementUnit, corsHeaders);
            case 'searchRecipes':
                return searchRecipes(searchTerm,corsHeaders);
            case 'filterRecipes':
                return filterRecipes(filters,corsHeaders);
            case 'addRecipeKeywords':
                return addRecipeKeywords(recipeid, keywords, corsHeaders);
            case 'getRecipeId':
                return getRecipeId(recipeData.name, corsHeaders);
            case 'addRecipeDietaryConstraints':
                return addRecipeDietaryConstraints(recipeid, dietaryConstraints, corsHeaders);
            case 'addIngredientIfNotExists':
                return addIngredientIfNotExists(ingredientName, measurementUnit, corsHeaders);
            case 'getRecipeSuggestions':
                return getRecipeSuggestions({spiceLevel,cuisine,dietaryConstraints}, corsHeaders);
            case 'getSuggestedFavorites':
                return getSuggestedFavorites(userId, corsHeaders);
            case 'findSimilarIngredients':
                return findSimilarIngredients(itemName, identifiedIngredient, corsHeaders);                
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

interface Ingredient {
    id: number;
    name: string;
    category: string;
    measurementUnit: string;
}

async function findSimilarIngredients(
    ingredientName: string, // item name
    ingredientType: string, // type of ingredient to be compared as part of the name
    corsHeaders: HeadersInit
) {
    if (!ingredientName) {
        console.error('Ingredient name is required.');
        return new Response(JSON.stringify({ error: 'Ingredient name is required' }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    try {
        // Fetch all ingredients
        const allIngredientsResponse = await getIngredientNames(corsHeaders);
        const allIngredients: Ingredient[] = await allIngredientsResponse.json();

        // Split ingredientName and ingredientType into search terms
        const nameTerms = ingredientName.toLowerCase().split(/\s+/);
        const typeTerms = ingredientType.toLowerCase().split(/\s+/);

        // Check for special cases
        const specialKeywords = ["flora", "stork", "rama"];
        const containsSpecialKeyword = [...nameTerms, ...typeTerms].some(term => specialKeywords.includes(term));

        // Filter ingredients based on name and type terms
        let similarIngredients = allIngredients.filter((ingredient: Ingredient) => {
            const ingredientNameLower = ingredient.name.toLowerCase();

            // Check if any of the name or type terms are included in the ingredient name
            return nameTerms.some(term => ingredientNameLower.includes(term)) ||
                   typeTerms.some(term => ingredientNameLower.includes(term));
        });

        // If special keywords are found, ensure margarine and butter are included
        if (containsSpecialKeyword) {
            const margarineAndButter = allIngredients.filter(ingredient =>
                ingredient.name.toLowerCase().includes("margarine") ||
                ingredient.name.toLowerCase().includes("butter")
            );
            // Combine the results, ensuring no duplicates
            similarIngredients = Array.from(new Set([...similarIngredients, ...margarineAndButter]));
        }

        // If no similar ingredients are found, return all ingredients
        if (similarIngredients.length === 0) {
            return new Response(JSON.stringify(allIngredients), {
                status: 200,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            });
        }

        return new Response(JSON.stringify(similarIngredients), {
            status: 200,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });

    } catch (error) {
        console.error('Unexpected error:', error);
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}



async function getSuggestedFavorites(userId: string, corsHeaders: HeadersInit) {
    try {
        if (!userId) {
            throw new Error('User ID is required');
        }

        //fetch users favorite recipes
        const { data: userFavorites, error: userFavoritesError } = await supabase
            .from('userFavorites')
            .select('recipeid')
            .eq('userid', userId);

        if (userFavoritesError) {
            throw new Error(`Error fetching user favorites: ${userFavoritesError.message}`);
        }

        if (!userFavorites || userFavorites.length === 0) {
            return new Response(JSON.stringify([]), {
                status: 200,
                headers: corsHeaders,
            });
        }

        const favoritedRecipeIds = userFavorites.map(fav => fav.recipeid);

        //find users with the same favorited recipes
        const { data: similarUsersFavorites, error: similarUsersFavoritesError } = await supabase
            .from('userFavorites')
            .select('userid, recipeid')
            .in('recipeid', favoritedRecipeIds)
            .neq('userid', userId); // Exclude the current user

        if (similarUsersFavoritesError) {
            throw new Error(`Error fetching similar users' favorites: ${similarUsersFavoritesError.message}`);
        }

        //get other users favorites 
        const otherUserIds = Array.from(new Set(similarUsersFavorites.map(fav => fav.userid)));
        const { data: otherUsersRecipes, error: otherUsersRecipesError } = await supabase
            .from('userFavorites')
            .select('recipeid')
            .in('userid', otherUserIds);

        if (otherUsersRecipesError) {
            throw new Error(`Error fetching other users' recipes: ${otherUsersRecipesError.message}`);
        }

        //remove recipes that the user has already favorited
        const suggestedRecipeIds = otherUsersRecipes
            .map(fav => fav.recipeid)
            .filter(recipeId => !favoritedRecipeIds.includes(recipeId));

        return new Response(JSON.stringify(suggestedRecipeIds), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}


async function getRecipeSuggestions(userPreferences: { spiceLevel: number; cuisine: string; dietaryConstraints: string[] }, corsHeaders: HeadersInit) {
    try {
        let query = supabase.from('recipe').select('recipeid');

        //conditions for or 
        const conditions: string[] = [];

        //spice level
        if (userPreferences.spiceLevel !== undefined && userPreferences.spiceLevel !== null) {
            conditions.push(`spicelevel.eq.${userPreferences.spiceLevel}`);
        }

        //cuisine
        if (userPreferences.cuisine && userPreferences.cuisine.length > 0) {
            conditions.push(`cuisine.eq.${userPreferences.cuisine}`);
        }

        //dietary constraints
        if (userPreferences.dietaryConstraints && userPreferences.dietaryConstraints.length > 0) {
            userPreferences.dietaryConstraints.forEach((option) => {
                conditions.push(`dietaryOptions.ilike.%${option}%`);
            });
        }

        //combine conditions
        if (conditions.length > 0) {
            query = query.or(conditions.join(','));
        }

        const { data: recipes, error: recipesError } = await query;

        if (recipesError) {
            console.error('Error fetching recipe suggestions:', recipesError);
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
        console.error('Error in getRecipeSuggestions function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}



async function addIngredientIfNotExists(
    ingredientName: string,
    measurementUnit: string,
    corsHeaders: HeadersInit
) {
    if (!ingredientName || !measurementUnit) {
        console.error('Invalid ingredient data provided.');
        return new Response(JSON.stringify({ error: 'Invalid ingredient data provided' }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    try {
        // Check if the ingredient exists
        const { data: existingIngredient, error: fetchError } = await supabase
            .from('ingredient')
            .select('ingredientid')
            .eq('name', ingredientName)
            .limit(1);

        if (fetchError) {
            console.error('Error fetching ingredient:', fetchError);
            return new Response(JSON.stringify({ error: fetchError.message }), {
                status: 500,
                headers: corsHeaders,
            });
        }

        // If the ingredient exists, return its ID
        if (existingIngredient && existingIngredient.length > 0) {
            return new Response(JSON.stringify({ ingredientId: existingIngredient[0].ingredientid }), {
                status: 200,
                headers: corsHeaders,
            });
        }

        // Find the current maximum ingredient ID
        const { data: maxIdResult, error: maxIdError } = await supabase
            .from('ingredient')
            .select('ingredientid')
            .order('ingredientid', { ascending: false })
            .limit(1);

        if (maxIdError) {
            console.error('Error fetching max ingredient ID:', maxIdError);
            return new Response(JSON.stringify({ error: maxIdError.message }), {
                status: 500,
                headers: corsHeaders,
            });
        }

        const newIngredientId = (maxIdResult && maxIdResult.length > 0) ? maxIdResult[0].ingredientid + 1 : 1;

        // Insert the new ingredient with the generated ID
        const { data: newIngredient, error: insertError } = await supabase
            .from('ingredient')
            .insert({
                ingredientid: newIngredientId,
                name: ingredientName,
                measurement_unit: measurementUnit
            })
            .select('ingredientid');

        if (insertError) {
            console.error('Error adding new ingredient:', insertError);
            return new Response(JSON.stringify({ error: insertError.message }), {
                status: 500,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ ingredientId: newIngredient[0].ingredientid }), {
            status: 200,
            headers: corsHeaders,
        });

    } catch (error) {
        console.error('Unexpected error:', error);
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}


async function filterRecipes(filters :Filters, corsHeaders: HeadersInit) {
    try {
        let query = supabase.from('recipe').select('recipeid');

        // Apply course filter
        if (filters.course && filters.course.length > 0) {
            query.in('course', filters.course);
        }

        // Apply spice level filter
        if (filters.spiceLevel !== undefined && filters.spiceLevel !== null) {
            query.eq('spicelevel', filters.spiceLevel);
        }

        // Apply cuisine filter
        if (filters.cuisine && filters.cuisine.length > 0) {
            query.in('cuisine', filters.cuisine);
        }

        // Apply dietary options filter
        if (filters.dietaryOptions && filters.dietaryOptions.length > 0) {
            filters.dietaryOptions.forEach((option) => {
                query = query.ilike('dietaryOptions', `%${option}%`);
            });
        }

        // // Apply ingredient options filter (custom logic as needed)
        // if (filters.ingredientOption) {
        //     // Custom filter logic for ingredientOption
        //     // This will depend on how ingredients are stored and should be filtered
        // }

        const { data: recipes, error: recipesError } = await query;

        if (recipesError) {
            console.error('Error fetching filtered recipes:', recipesError);
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
        console.error('Error in filterRecipes function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}


async function searchRecipes(searchTerm: string, corsHeaders: HeadersInit) {
    if (!searchTerm) {
        return new Response(JSON.stringify({ error: 'Search term is required' }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    try {
        const { data: recipes, error: recipesError } = await supabase
            .from('recipe')
            .select('recipeid, name, description') //return list of recipes 
            .or(`name.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%,course.ilike.%${searchTerm}%,cuisine.ilike.%${searchTerm}%,keywords.ilike.%${searchTerm}%`);

        if (recipesError) {
            console.error('Error searching for recipes:', recipesError);
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
        console.error('Error in searchRecipes function:', e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}




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

// Get all the ingredient names and their ids and categories
async function getIngredientNames(corsHeaders: HeadersInit) {
    try {
        const { data: ingredients, error } = await supabase
            .from('ingredient')
            .select('ingredientid, name, category, measurement_unit');

        if (error) {
            throw new Error(error.message);
        }

        const ingredientNames = ingredients.map(ingredient => ({
            id: ingredient.ingredientid,
            name: ingredient.name,
            category: ingredient.category,
            measurementUnit: ingredient.measurement_unit
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
            appliances,
            photo
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
                photo: photo,
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
            const ingredientResponse = await addIngredientIfNotExists(ingredient.name, ingredient.unit, corsHeaders);

            if (ingredientResponse.status !== 200) {
                console.error('Error adding or fetching ingredient:', await ingredientResponse.json());
                return new Response(JSON.stringify({ error: 'Failed to add or fetch ingredient' }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }

            const { ingredientId } = await ingredientResponse.json();

            // Insert the ingredient into the recipe ingredients table
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



async function addToShoppingList(userId: string, ingredientName: string, quantity: number, measurementUnit: string) {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json"
    };

    try {
        if (!userId || !ingredientName || quantity == null || !measurementUnit) {
            throw new Error('User ID, ingredient name, quantity, and measurement unit are required');
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

        // Check if the ingredient is already in the shopping list
        const { data: shoppingItem, error: shoppingError } = await supabase
            .from('shoppinglist')
            .select('quantity')
            .eq('userid', userId)
            .eq('ingredientid', ingredientId)
            .single();

        if (shoppingError && shoppingError.code !== 'PGRST116') { // PGRST116 indicates no rows returned
            return new Response(JSON.stringify({ error: shoppingError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        if (shoppingItem) {
            // If the item exists, update the quantity
            const newQuantity = shoppingItem.quantity + quantity;
            const { error: updateError } = await supabase
                .from('shoppinglist')
                .update({
                    quantity: newQuantity,
                    measurmentunit: measurementUnit // Assuming measurement unit remains the same
                })
                .eq('userid', userId)
                .eq('ingredientid', ingredientId);

            if (updateError) {
                return new Response(JSON.stringify({ error: updateError.message }), {
                    status: 400,
                    headers: corsHeaders,
                });
            }

            return new Response(JSON.stringify({ success: true, newQuantity }), {
                status: 200,
                headers: corsHeaders,
            });
        } else {
            // If the item does not exist, insert it
            const { error: shoppingListError } = await supabase
                .from('shoppinglist')
                .insert({
                    userid: userId,
                    ingredientid: ingredientId,
                    quantity: quantity, // Default quantity, adjust as needed
                    measurmentunit: measurementUnit // Default measurement unit, adjust as needed
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
        }
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}


async function editShoppingListItem(userId: string, ingredientName: string, quantity: number, measurementUnit: string, corsHeaders: HeadersInit) {
    try {
        if (!userId || !ingredientName || !quantity || !measurementUnit) {
            throw new Error('User ID, ingredient name, quantity, and measurement unit are required');
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

        // Update the shopping list item
        const { error: updateError } = await supabase
            .from('shoppinglist')
            .update({
                quantity: quantity,
                measurmentunit: measurementUnit
            })
            .eq('userid', userId)
            .eq('ingredientid', ingredientId);

        if (updateError) {
            return new Response(JSON.stringify({ error: updateError.message }), {
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

async function editPantryItem(userId: string, ingredientName: string, quantity: number, measurementUnit: string, corsHeaders: HeadersInit) {
    try {
        if (!userId || !ingredientName || quantity === undefined || !measurementUnit) {
            throw new Error('User ID, ingredient name, quantity, and measurement unit are required');
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

        // Update the pantry list item
        const { error: updateError } = await supabase
            .from('availableingredients')
            .update({
                quantity: quantity,
                measurmentunit: measurementUnit
            })
            .eq('userid', userId)
            .eq('ingredientid', ingredientId);

        if (updateError) {
            return new Response(JSON.stringify({ error: updateError.message }), {
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
async function addToPantryList(userId: string, ingredientName: string, quantity: number, measurementUnit: string) {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",  // You can restrict this to your Flutter app's URL
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json"
    };
    try {
        if (!userId || !ingredientName || !quantity || !measurementUnit) {
            throw new Error('User ID, ingredient name, quantity, and measurement unit are required');
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

        // Check if the ingredient is already in the pantry
        const { data: pantryItem, error: pantryError } = await supabase
            .from('availableingredients')
            .select('quantity')
            .eq('userid', userId)
            .eq('ingredientid', ingredientId)
            .single();

        if (pantryError && pantryError.code !== 'PGRST116') { // PGRST116 indicates no rows returned
            return new Response(JSON.stringify({ error: pantryError.message }), { 
                status: 400,
                headers: corsHeaders,
            });
        }

        if (pantryItem) {
            // If the item exists, update the quantity
            const newQuantity = pantryItem.quantity + quantity;
            const { error: updateError } = await supabase
                .from('availableingredients')
                .update({
                    quantity: newQuantity,
                    measurmentunit: measurementUnit // Assuming measurement unit remains the same
                })
                .eq('userid', userId)
                .eq('ingredientid', ingredientId);

            if (updateError) {
                return new Response(JSON.stringify({ error: updateError.message }), { 
                    status: 400,
                    headers: corsHeaders,
                });
            }

            return new Response(JSON.stringify({ success: true, newQuantity }), { 
                status: 200,
                headers: corsHeaders,
            });
        } else {
            // If the item does not exist, insert it
            const { error: pantryListError } = await supabase
                .from('availableingredients')
                .insert({
                    userid: userId,
                    ingredientid: ingredientId,
                    quantity: quantity, // Default quantity, adjust as needed
                    measurmentunit: measurementUnit // Default measurement unit, adjust as needed
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
        }
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
            .select('ingredientid, quantity')
            .eq('recipeid', recipeId);

        if (ingredientsError) {
            throw new Error(`Error fetching recipe ingredients: ${ingredientsError.message}`);
        }

        // Fetch ingredient names and measurement units based on ingredient ids
        const ingredientIds = ingredientsData.map(ingredient => ingredient.ingredientid);
        const { data: ingredientNamesData, error: ingredientNamesError } = await supabase
            .from('ingredient')
            .select('ingredientid, name, measurement_unit')
            .in('ingredientid', ingredientIds);

        if (ingredientNamesError) {
            throw new Error(`Error fetching ingredient names: ${ingredientNamesError.message}`);
        }

        const ingredients = ingredientsData.map(ingredient => {
            const ingredientData = ingredientNamesData.find(nameData => nameData.ingredientid === ingredient.ingredientid);
            return {
                ingredientid: ingredient.ingredientid,
                name: ingredientData?.name,
                quantity: ingredient.quantity,
                measurement_unit: ingredientData?.measurement_unit,
            };
        });

        //console.log('hereee:'ingredientData?.measurement_unit);

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

async function removeUserAppliance(userId: string, applianceName: string, corsHeaders: HeadersInit) {
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

        // Delete from userAppliances table
        const { error: userApplianceError } = await supabase
            .from('userAppliances')
            .delete()
            .eq('userid', userId)
            .eq('applianceid', applianceId);

        if (userApplianceError) {
            console.error('Error deleting user appliance:', userApplianceError);
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
        console.error('Error in removeUserAppliance function:', error);
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


// Function to add a user favorite
async function addUserFavorite(userId: string, recipeid: string, corsHeaders: HeadersInit) {
    try {
        // Ensure userId and recipeId are provided
        if (!userId || !recipeid) {
            throw new Error('User ID and Recipe ID are required');
        }

        // Insert the user favorite record
        const { error: userRecipeError } = await supabase
            .from('userFavorites')
            .insert({ userid: userId, recipeid: recipeid })
            .select('*')
            .single();

        if (userRecipeError) {
            console.error('Error adding user favorite:', userRecipeError);
            return new Response(JSON.stringify({ error: userRecipeError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ message: 'User favorite added successfully' }), {
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        console.error('Error in addUserFavorite function:', error);
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function removeUserFavorite(userId: string, recipeid: string, corsHeaders: HeadersInit) {
    try {
        // Ensure userId and recipeId are provided
        if (!userId || !recipeid) {
            throw new Error('User ID and Recipe ID are required');
        }

        // Insert the user favorite record
        const { error: userRecipeError } = await supabase
                .from('userFavorites')
                .delete()
                .eq('userid', userId)
                .eq('recipeid', recipeid);

        if (userRecipeError) {
            console.error('Error removing user favorite:', userRecipeError);
            return new Response(JSON.stringify({ error: userRecipeError.message }), {
                status: 400,
                headers: corsHeaders,
            });
        }

        return new Response(JSON.stringify({ message: 'User favorite removed successfully' }), {
            status: 200,
            headers: corsHeaders,
        });
    } catch (error) {
        console.error('Error in removeUserFavorite function:', error);
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: corsHeaders,
        });
    }
}

async function addRecipeKeywords(recipeid: string, keywords: string, corsHeaders: HeadersInit) {
    if (!recipeid) {
        console.error('Failed to retrieve recipe ID.');
        return new Response(JSON.stringify({ error: 'Failed to retrieve recipe ID' }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    const { error: recipeKeywordError } = await supabase
        .from('recipe')
        .update({ keywords })
        .eq('recipeid', recipeid);

    if (recipeKeywordError) {
        console.error('Error updating recipe keywords:', recipeKeywordError);
        return new Response(JSON.stringify({ error: recipeKeywordError.message }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    return new Response(JSON.stringify({ success: 'Recipe keywords updated successfully' }), {
        status: 200,
        headers: corsHeaders,
    });
}

async function getRecipeId(recipeName: string, corsHeaders: HeadersInit) {
    try {
        // Ensure recipeName is provided
        if (!recipeName) {
            throw new Error('Recipe name is required');
        }

        // Fetch recipe ID based on the recipe name
        const { data: recipeData, error: recipeError } = await supabase
            .from('recipe')
            .select('recipeid')
            .eq('name', recipeName)
            .single();

        if (recipeError) {
            throw new Error(`Error fetching recipe ID: ${recipeError.message}`);
        }

        if (!recipeData) {
            throw new Error(`Recipe not found for name: ${recipeName}`);
        }

        const recipeId = recipeData.recipeid;

        return new Response(JSON.stringify({ recipeId }, null, 2), {
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

async function addRecipeDietaryConstraints(recipeid: string, dietaryConstraints:  string, corsHeaders: HeadersInit) {
    if (!recipeid) {
        console.error('Failed to retrieve recipe ID.');
        return new Response(JSON.stringify({ error: 'Failed to retrieve recipe ID' }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    // Ensure dietaryConstraints is a valid JSON string
    if (typeof dietaryConstraints !== 'string') {
        console.error('Invalid dietary constraints format.');
        return new Response(JSON.stringify({ error: 'Invalid dietary constraints format' }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    const { error: dietaryConstraintError } = await supabase
        .from('recipe')
        .update({ dietaryOptions: dietaryConstraints })  // Adjust the column name if needed
        .eq('recipeid', recipeid);

    if (dietaryConstraintError) {
        console.error('Error updating recipe dietary constraints:', dietaryConstraintError);
        return new Response(JSON.stringify({ error: dietaryConstraintError.message }), {
            status: 400,
            headers: corsHeaders,
        });
    }

    return new Response(JSON.stringify({ success: 'Recipe dietary constraints updated successfully' }), {
        status: 200,
        headers: corsHeaders,
    });
}


/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/ingredientsEndpoint' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/