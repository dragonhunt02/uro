import { client } from "@hey-api/client-fetch";
import { randomInt } from "@ariesclark/extensions";

import { apiOrigin, development } from "./environment";
import { useServerEnv, fetchEnv } from "~/hooks/server-env";
import { fetchServerEnv } from "~/environment";

const config = client.getConfig();

async function getCurrentHeaders() {
	return typeof window === "undefined"
		? (await import("next/headers")).headers()
		: new Headers();
}

const relevantHeaders = new Set([
	"authorization",
	"cookie",
	"user-agent",
	"x-forwarded-for",
	"x-forwarded-host",
	"x-forwarded-port",
	"x-forwarded-proto"
]);

config.baseUrl = apiOrigin;
config.fetch = async (request: Request) => {

	if (development)
		// Simulate network latency in development, encouraging optimistic updates & proper loading states.
		await new Promise((resolve) =>
			setTimeout(
				resolve,
				// Random latency between 20ms and 200ms, doubled for non-GET requests.
				randomInt(20, 200) * (request.method.toUpperCase() === "GET" ? 1 : 2)
			)
		);

	const headers = await getCurrentHeaders();

	for (const [key, value] of headers.entries()) {
		if (!relevantHeaders.has(key.toLowerCase())) continue;
		request.headers.set(key, value);
	}

	const originalUrl = new URL(request.url);
        const protocol = originalUrl.protocol;

	//#### Modify to baseUrl when server side request
	if (typeof window !== "undefined"){
	
        const serverEnv = await fetchServerEnv();
        //console.log(serverEnv)
			
	const newBaseUrl = serverEnv?.origin || "";
	//process.env.API_ORIGIN || ""; // NOT WORKING it fallbacks to empty
        const pathName = originalUrl.pathname || "";
	const pathQuery = originalUrl.search || "";
	const originalBody = await request.text();

        let newRequest = new Request(`${newBaseUrl}${pathName}${pathQuery}`, {
             method: request.method,
             headers: request.headers,
             redirect: request.redirect,
             credentials: request.credentials,
             referrer: request.referrer,
             cache: request.cache,
		...(["POST", "PUT", "PATCH"].includes(request.method) && originalBody.trim() !== "" && { body: originalBody }) 
	});
		
	console.log(request);
	console.log(newRequest);
	return fetch(newRequest);
	
	} else {
		return fetch(request)
	}
};

export * from "./__generated/api";
export * as api from "./__generated/api";
