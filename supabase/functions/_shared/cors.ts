// CORS for every edge function. Only the origins listed in the ALLOWED_ORIGINS
// secret (comma-separated, e.g. "https://app.example.com,http://localhost:5173")
// are echoed back; any other origin gets no Access-Control-Allow-Origin, so the
// browser blocks the response.
const allowedOrigins = new Set(
  (Deno.env.get("ALLOWED_ORIGINS") ?? "")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean),
);

export function corsHeaders(request: Request): Record<string, string> {
  const origin = request.headers.get("Origin");
  const headers: Record<string, string> = {
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    Vary: "Origin",
  };
  if (origin && allowedOrigins.has(origin)) {
    headers["Access-Control-Allow-Origin"] = origin;
  }
  return headers;
}

// Answers the preflight; any other method returns null and is handled by the function.
export function handlePreflight(request: Request): Response | null {
  if (request.method !== "OPTIONS") return null;
  return new Response(null, { status: 204, headers: corsHeaders(request) });
}
