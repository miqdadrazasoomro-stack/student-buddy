// Student Buddy - permanently deletes the calling user's account.
// Deleting the auth user cascades to profiles and all tables that reference it.
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return json({ error: "unauthorized", message: "Please sign in again." }, 401);

  const { error: delError } = await admin.auth.admin.deleteUser(data.user.id);
  if (delError) {
    console.error("deleteUser failed", delError);
    return json({ error: "delete_failed", message: "Could not delete the account. Please try again." }, 500);
  }
  return json({ ok: true });
});
