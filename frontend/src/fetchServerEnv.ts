let envCache: { origin: string } | null = null;
let envFetchPromise: Promise<{ origin: string } | null> | null = null;

export const fetchServerEnv = async (): Promise<{ origin: string } | null> => {
    if (typeof window === "undefined") return null; // Prevent running in SSR

    // Return cached value if already available
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
 * Add to set if required.
 */
const firstPartyOrigins = new Set([]);

export const getFirstPartyOrigins = async (): Promise<Set<string>> => {
    const serverEnv = await fetchServerEnv();
    const appOrigin = serverEnv?.origin;
    if (appOrigin) {
        firstPartyOrigins.add(appOrigin);
    }

    console.log("First-party origins:", [...firstPartyOrigins]);

    return firstPartyOrigins; // Returning the Set directly
};

export const getFirstPartyOrigins = async (): Promise<Set<string>> => {
    const serverEnv = await fetchServerEnv();
    const appOrigin = serverEnv?.origin;
    let origins = firstPartyOrigins;

    // Ensure firstPartyOrigins includes the dynamically fetched origin
    if (appOrigin) {
        origins.add(appOrigin);
    }

    //console.log("First-party origins:", [...origins]);

    return origins;
};

export const fetchServerEnv1 = async (): Promise<{ origin: string } | null> => {
    try {
        const response = await fetch("/api/env"); // Fetch server environment data
        if (response.ok) {
            const serverEnv = await response.json();
            console.log("Fetched serverEnv:", serverEnv);
            return serverEnv; // Return the server environment
        } else {
            console.error(`Failed to fetch server environment: ${response.status}`);
        }
    } catch (error) {
        console.error("Error fetching server environment:", error);
    }
    return null; // Return null if the fetch fails
};
