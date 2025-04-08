"use client";

import { usePathname, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import { fetchServerEnv } from "~/fetchServerEnv"; // Import the fetch function

type Location = URL & { current: string };

/**
 * A combination of {@link usePathname} and {@link useSearchParams}.
 * Dynamically fetches originEnv.
 */
export function useLocation(): Location {
    const pathname = usePathname();
    const searchParameters = useSearchParams();

    // State for originEnv with fallback
    const [originEnv, setOriginEnv] = useState("http://fallback.vsekai.local");

    // Fetch originEnv on mount
    useEffect(() => {
        const loadOriginEnv = async () => {
            const serverEnv = await fetchServerEnv();
            const origin = serverEnv?.origin ?? "http://fallback.vsekai.local";
            setOriginEnv(origin); // Update originEnv with fetched value
        };

        loadOriginEnv(); // Trigger fetch logic
    }, []);

    // Always compute the `current` URL using the latest originEnv
    const current = `${pathname}${
        searchParameters.size > 0 ? `?${searchParameters.toString()}` : ""
    }`;

console.log("currennt loc", String(current));

    // Create the location object, even if originEnv is still the fallback
    const location = Object.assign(new URL(current, originEnv), { current });
console.log("currennt loc", JSON.stringify(location));

    return location; // Always return a valid Location object
}
