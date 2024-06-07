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
        const { action, userId, username } = await req.json();

        switch (action) {
            case 'getUserDetails':
                return getUserDetails(userId, corsHeaders); 
            case 'updateUserUsername':
                return updateUserUsername(userId, username, corsHeaders);             
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

      // Fetch all cuisines
      const { data: cuisines, error: cuisinesError } = await supabase
          .from('cuisine')
          .select('cuisineid, name');

      if (cuisinesError) {
          throw new Error(cuisinesError.message);
      }

      // Combine user profiles with cuisine names
      const userDetails = userProfiles.map(profile => {
          const cuisine = cuisines.find(c => c.cuisineid === profile.cuisineid);
          return {
              upid: profile.upid,
              userid: profile.userid,
              cuisineName: cuisine ? cuisine.name : 'Unknown',
              // cuisineid: profile.cuisineid,
              spicelevel: profile.spicelevel,
              username: profile.username,
              profilephoto: profile.profilephoto,
              
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

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/userEndpoint' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
