/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'

// Create the Supabase Client
const supURL = Deno.env.get("_SUPABASE_URL") as string;
const supKey = Deno.env.get("_SUPABASE_ANON_KEY") as string;
const supabase = createClient(supURL, supKey);

console.log("Hello from User Endpoint!")

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
        const { action, userId, username, cuisine, spicelevel, dietaryConstraint } = await req.json();

        switch (action) {
            case 'getUserDetails':
                return getUserDetails(userId, corsHeaders); 
            case 'updateUserUsername':
                return updateUserUsername(userId, username, corsHeaders); 
            case 'updateUserCuisine':
                return updateUserCuisine(userId, cuisine, corsHeaders);
            case 'updateUserSpiceLevel':
                return updateUserSpiceLevel(userId, spicelevel, corsHeaders);       
            case 'addUserDietaryConstraints':
                return addUserDietaryConstraints(userId, dietaryConstraint, corsHeaders);
            case 'removeUserDietaryConstraints':
                return removeUserDietaryConstraints(userId, dietaryConstraint, corsHeaders);
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

async function getUserDetails(userId: string, corsHeaders: HeadersInit) {
  if (!userId) {
      throw new Error('User ID is required');
  }

  try {
      // Fetch user profile details
      const { data: userProfiles, error: userProfileError } = await supabase
          .from('userProfile')
          .select('upid, userid, cuisineid, spicelevel, username, profilephoto')
          .eq('userid', userId);

      if (userProfileError) {
          throw new Error(userProfileError.message);
      }

      if (!userProfiles || userProfiles.length === 0) {
          throw new Error('User profile not found');
      }

      // Fetch dietary constraints for the user
      const { data: dietaryConstraints, error: constraintsError } = await supabase
          .from('userDietaryConstraints')
          .select('dietaryconstraintsid')
          .eq('userid', userId);

      if (constraintsError) {
          throw new Error(constraintsError.message);
      }

      // Fetch cuisine name
      const cuisineId = userProfiles[0].cuisineid; // Assuming there's only one cuisine for a user
      const { data: cuisineData, error: cuisineError } = await supabase
          .from('cuisine')
          .select('name')
          .eq('cuisineid', cuisineId)
          .single();

      if (cuisineError) {
          throw new Error(cuisineError.message);
      }

      const cuisineName = cuisineData ? cuisineData.name : 'Unknown';

      // Fetch names of dietary constraints
      const dietaryConstraintsIds = dietaryConstraints.map(constraint => constraint.dietaryconstraintsid);
      const { data: constraintNames, error: constraintNamesError } = await supabase
          .from('dietaryconstraints')
          .select('dietaryconstraintsid, name')
          .in('dietaryconstraintsid', dietaryConstraintsIds);

      if (constraintNamesError) {
          throw new Error(constraintNamesError.message);
      }

      // Combine user profiles with dietary constraints
      const userDetails = userProfiles.map(profile => {
          const userDietaryConstraints = constraintNames.filter(constraint => dietaryConstraintsIds.includes(constraint.dietaryconstraintsid));
          const dietaryConstraintNames = userDietaryConstraints.map(constraint => constraint.name);
          return {
              upid: profile.upid,
              userid: profile.userid,
              cuisine: cuisineName,
              spicelevel: profile.spicelevel,
              username: profile.username,
              profilephoto: profile.profilephoto,
              dietaryConstraints: dietaryConstraintNames,
          };
      });

      return new Response(JSON.stringify(userDetails), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  } catch (error) {
      return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  }
}


  async function updateUserUsername(userId: string, username: string, corsHeaders: HeadersInit) {
    if (!userId) {
        throw new Error('User ID is required');
    }

    if (!username) {
        throw new Error('Username is required');
    }

    try {
        const { data, error } = await supabase
            .from('userProfile')
            .update({ username })
            .eq('userid', userId)
            .select();  // Ensure that the updated data is returned

        if (error) {
            throw error;
        }

        return new Response(JSON.stringify(data), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

async function updateUserCuisine(userId: string, cuisine: string, corsHeaders: HeadersInit) {
  if (!userId) {
      throw new Error('User ID is required');
  }

  if (!cuisine) {
      throw new Error('Cuisine is required');
  }

  try {
      // Fetch cuisineid from cuisine name
      const { data: cuisineData, error: cuisineError } = await supabase
          .from('cuisine')
          .select('cuisineid')
          .eq('name', cuisine)
          .single();

      if (cuisineError) {
          throw new Error(cuisineError.message);
      }

      if (!cuisineData) {
          throw new Error('Cuisine not found');
      }

      const cuisineid = cuisineData.cuisineid;

      // Update user's cuisineid in userProfile
      const { data, error } = await supabase
          .from('userProfile')
          .update({ cuisineid })
          .eq('userid', userId)
          .select();  // Ensure that the updated data is returned

      if (error) {
          throw error;
      }

      return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  } catch (error) {
      return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  }
}

async function updateUserSpiceLevel(userId : string, spicelevel : number , corsHeaders : HeadersInit) {
  if (!userId) {
      throw new Error('User ID is required');
  }

  if (!spicelevel) {
      throw new Error('Spice level is required');
  }

  try {
      console.log('Updating spice level:', userId, spicelevel);

      const { data, error } = await supabase
          .from('userProfile')
          .update({ spicelevel })
          .eq('userid', userId)
          .select();  

      if (error) {
          throw error;
      }

      console.log('Update successful:', data);

      return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  } catch (error) {
      console.error('Error updating spice level:', error);

      return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  }
}

async function addUserDietaryConstraints(userId: string, dietaryConstraint: string, corsHeaders: HeadersInit) {
  if (!userId) {
      throw new Error('User ID is required');
  }

  if (!dietaryConstraint) {
      throw new Error('Dietary constraint is required');
  }

  try {
      // Fetch the dietary constraint ID
      const { data: existingConstraint, error: constraintError } = await supabase
          .from('dietaryconstraints')
          .select('dietaryconstraintsid')
          .eq('name', dietaryConstraint)
          .single();

      if (constraintError) {
          throw constraintError;
      }

      if (!existingConstraint) {
          throw new Error('Dietary constraint not found');
      }

      // Add the dietary constraint for the user
      const { data, error } = await supabase
          .from('userDietaryConstraints')
          .insert({ userid: userId, dietaryconstraintsid: existingConstraint.dietaryconstraintsid })
          .single();

      if (error) {
          throw error;
      }

      return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  } catch (error) {
      return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  }
}

async function removeUserDietaryConstraints(userId: string, dietaryConstraint: string, corsHeaders: HeadersInit) {
  if (!userId) {
      throw new Error('User ID is required');
  }

  if (!dietaryConstraint) {
      throw new Error('Dietary constraint is required');
  }

  try {
      // Fetch the dietary constraint ID
      const { data: existingConstraint, error: constraintError } = await supabase
          .from('dietaryconstraints')
          .select('dietaryconstraintsid')
          .eq('name', dietaryConstraint)
          .single();

      if (constraintError) {
          throw constraintError;
      }

      if (!existingConstraint) {
          throw new Error('Dietary constraint not found');
      }

      // Remove the dietary constraint for the user
      const { data, error } = await supabase
          .from('userDietaryConstraints')
          .delete()
          .eq('userid', userId)
          .eq('dietaryconstraintsid', existingConstraint.dietaryconstraintsid)
          .single();

      if (error) {
          throw error;
      }

      return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  } catch (error) {
      return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
  }
}




/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/userEndpoint' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
