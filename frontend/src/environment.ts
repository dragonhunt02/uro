function environment<T>(value: unknown, name: string): T {
	if (!value) throw new Error(`Missing environment variable: ${name}.`);
	return value as T;
}

export const development = process.env.NODE_ENV === "development";

export const origin = environment<string>(
	process.env.NEXT_PUBLIC_ORIGIN,
	"NEXT_PUBLIC_ORIGIN"
);

export const apiOrigin = environment<string>(
	process.env.API_ORIGIN || process.env.NEXT_PUBLIC_API_ORIGIN,
	"API_ORIGIN and or NEXT_PUBLIC_API_ORIGIN"
);

export const turnstileSiteKey = environment<string>(
	process.env.NEXT_PUBLIC_TURNSTILE_SITEKEY,
	"NEXT_PUBLIC_TURNSTILE_SITEKEY"
);

if (development) {
	process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";
}

export const urls = {
	discord: "https://discord.gg/7BQDHesck8",
	github: "https://github.com/v-sekai",
	twitter: "https://twitter.com/vsekaiofficial"
};

/**
 * A set of first-party origins, these are given special treatment in the
 * application, such as in OAuth2 redirection & opening links in a new tab.
 */
export const firstPartyOrigins = new Set([origin]);


// Runtime fetch from API
let envCache: { origin: string } | null = null;
let envFetchPromise: Promise<{ origin: string } | null> | null = null;

export const fetchServerEnv = async (): Promise<{ origin: string } | null> => {
    if (typeof window === "undefined") return null;

    if (envCache) {
        console.log("Using in-memory cache:", envCache);
        return envCache;
    }

    // Return ongoing fetch request if multiple calls happen at the same time
    if (envFetchPromise) {
        console.log("Waiting for existing fetch request...");
        return envFetchPromise;
    }

    envFetchPromise = (async () => {
        try {
            const cachedEnv = localStorage.getItem("serverEnv");
            if (cachedEnv) {
                envCache = JSON.parse(cachedEnv);
                console.log("Using localStorage cache:", envCache);
                return envCache;
            }

            const response = await fetch("/api/env");
            if (response.ok) {
                envCache = await response.json();
                console.log("Fetched serverEnv:", envCache);
                localStorage.setItem("serverEnv", JSON.stringify(envCache));
                return envCache;
            } else {
                console.error(`Failed to fetch server environment: ${response.status}`);
            }
        } catch (error) {
            console.error("Error fetching server environment:", error);
        }

        return null;
    })();

    return envFetchPromise;
};

/**
 * A set of first-party origins, these are given special treatment in the
 * application, such as in OAuth2 redirection & opening links in a new tab.
 * Add to set below if required.
 */
const firstPartyOrigins_new: Set<string> = new Set([]);

export const getFirstPartyOrigins = async (): Promise<Set<string>> => {
    const serverEnv = await fetchServerEnv();
    const appOrigin = serverEnv?.origin;
    let origins = firstPartyOrigins_new;

    // Ensure firstPartyOrigins includes fetched origin
    if (appOrigin) {
        origins.add(appOrigin);
    }

    //console.log("First-party origins:", [...origins]);
    return origins;
};
