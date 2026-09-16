/**
 * Minimal JWT sign/verify for the mock server only.
 *
 * The signing secret is a fixed, public string — fine here because the
 * "server" and the "client" run in the same browser tab, so no real secret
 * management is possible or meaningful. Never reuse this secret or this
 * module outside the mock.
 */

const MOCK_JWT_SECRET = "student-app-mock-server-secret";
const MOCK_JWT_TTL_SECONDS = 3 * 24 * 60 * 60; // 3 days

type MockJwtPayload = {
  sub: string;
  iat: number;
  exp: number;
};

function base64UrlEncode(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function base64UrlDecode(value: string): Uint8Array {
  const padded = value
    .replace(/-/g, "+")
    .replace(/_/g, "/")
    .padEnd(Math.ceil(value.length / 4) * 4, "=");
  return Uint8Array.from(atob(padded), (char) => char.charCodeAt(0));
}

function encodeJson(value: unknown): string {
  return base64UrlEncode(new TextEncoder().encode(JSON.stringify(value)));
}

function decodeJson<T>(value: string): T {
  return JSON.parse(new TextDecoder().decode(base64UrlDecode(value))) as T;
}

async function importSigningKey(): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(MOCK_JWT_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
}

async function sign(signingInput: string): Promise<string> {
  const key = await importSigningKey();
  const signature = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(signingInput));
  return base64UrlEncode(new Uint8Array(signature));
}

export async function createMockJwt(accountId: string): Promise<string> {
  const issuedAt = Math.floor(Date.now() / 1000);
  const payload: MockJwtPayload = {
    sub: accountId,
    iat: issuedAt,
    exp: issuedAt + MOCK_JWT_TTL_SECONDS,
  };
  const signingInput = `${encodeJson({ alg: "HS256", typ: "JWT" })}.${encodeJson(payload)}`;
  return `${signingInput}.${await sign(signingInput)}`;
}

/** Returns the account id (the `sub` claim) for a valid, unexpired token. */
export async function verifyMockJwt(token: string): Promise<string | undefined> {
  const [header, payload, signature] = token.split(".");
  if (!header || !payload || !signature) return undefined;
  if (signature !== (await sign(`${header}.${payload}`))) return undefined;

  try {
    const claims = decodeJson<MockJwtPayload>(payload);
    return Math.floor(Date.now() / 1000) < claims.exp ? claims.sub : undefined;
  } catch {
    return undefined;
  }
}
