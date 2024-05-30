
/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
// import { serve } from "https://deno.land/std@0.140.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'

// create the Supabase Client to use it
const supURL = Deno.env.get("_SUPABASE_URL") as string;
const supKey = Deno.env.get("_SUPABASE_ANON_KEY") as string;
const supabase = createClient(supURL, supKey);

console.log("Hello from Functions!")

// Testing things

// Deno.serve(async (req) => {
//   const { name } = await req.json()
//   // const body = await req.json()
//   const data = {
//     message: `Hello ${name}!`,
//   }

//   console.log("BODY: " + name)
//   console.log("BODY REQUEST: " + name.request)
//   console.log("Body.request null? " + (!name.request))
  
//   let { data: shoppinglist, error } = await supabase
//   .from('shoppinglist')
//   .select('*');

//   return new Response(
//     JSON.stringify(
//       {
//         data,
//         shoppinglist,
//       }
//     ),
//     { headers: { "Content-Type": "application/json" } },
//   )
// })
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
    const { email, password } = await req.json();
    
    const { data , error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ user: data.user }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/hello-world' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
