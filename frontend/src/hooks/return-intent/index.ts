import { useMemo, useState, useEffect } from "react";
import { useRouter } from "next/navigation";

import { firstPartyOrigins } from "~/environment";
import { fetchServerEnv } from "~/fetchServerEnv"; // Import the fetch utility
import { useLocation } from "../location";

function minimizeHref(href: URL | string, origin: string) {
    const url = new URL(href.toString(), origin);
    return url.origin === origin ? url.href.replace(origin, "") : url.href;
}

export function useReturnIntent() {
    const router = useRouter();

    const { current, searchParams } = useLocation();
    const _returnIntent = searchParams.get("ri");

    // State to hold the dynamically fetched origin
    const [origin, setOrigin] = useState("http://fallback.vsekai.local");

    // Fetch the `origin` dynamically using `fetchServerEnv`
    useEffect(() => {
        const loadOriginEnv = async () => {
            const serverEnv = await fetchServerEnv();
            const dynamicOrigin = serverEnv?.origin ?? "http://fallback.vsekai.local";
            setOrigin(dynamicOrigin); // Update the origin
        };

        loadOriginEnv();
    }, []); // Run once when the component mounts

    return useMemo(() => {
        let returnIntent = _returnIntent ? new URL(_returnIntent, origin) : null;
        if (returnIntent && !firstPartyOrigins.has(returnIntent.origin)) {
            returnIntent = null;
        }

        return {
            // Navigate to the return intent or fallback
            restoreReturnIntent: (fallback: string = "/") =>
                router.push(returnIntent?.toString() || fallback),

            // The current return intent URL
            returnIntent,

            // Build a URL with the return intent included in the query parameters
            withReturnIntent: (pathname: string) => {
                const url = new URL(pathname, origin);
                url.searchParams.set(
                    "ri",
                    minimizeHref(returnIntent ? returnIntent.href : current, origin)
                );

                return url;
            }
        };
    }, [router, _returnIntent, current, origin]); // Depend on the dynamic `origin`
}
