import { redirect } from "next/navigation";
import { firstPartyOrigins } from "~/environment";
import { fetchServerEnv, getFirstPartyOrigins } from "~/fetchServerEnv"; // Import the fetch utility

/**
 * Redirects the user to the return intent, if it is a first-party origin, otherwise to the home page.
 * Dynamically fetches the `origin` value from the server environment.
 * @see https://www.fastly.com/blog/open-redirects-real-world-abuse-and-recommendations/
 */
export async function restoreReturnIntent(ri: string): Promise<void> {
    try {
        const serverEnv = await fetchServerEnv(); // Fetch the server environment
        const origin = serverEnv?.origin ?? "http://fallback.vsekai.local"; // Use fetched origin or fallback
        const firstPartyOrigins = await getFirstPartyOrigins();

        const returnIntent = new URL(ri, origin);

        if (!firstPartyOrigins.has(returnIntent.origin)) {
            return redirect("/"); // Redirect to home if not a first-party origin
        }

        redirect(returnIntent.href); // Redirect to the return intent
    } catch (error) {
        console.error("Error fetching server environment:", error);
        redirect("/"); // Fallback to home on error
    }
}
