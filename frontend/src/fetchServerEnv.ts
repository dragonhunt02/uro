export const fetchServerEnv = async (): Promise<{ origin: string } | null> => {
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
