import { client } from "@hey-api/client-fetch";
import { randomInt } from "@ariesclark/extensions";

import { apiOrigin, development } from "./environment";
import { useServerEnv, fetchEnv } from "~/hooks/server-env";

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

config.baseUrl = apiOrigin; //"https://bad.request.vsekai.local"; //apiOrigin";
config.fetch = async (request: Request) => {
	//const serverEnv = await fetchEnv();
	//const newBaseUrl = serverEnv.apiOrigin;

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
        //const newBaseUrl2 = "//api.example.local";
	const newBaseUrl = process.env.API_ORIGIN || ""; // NOT WORKING it fallbacks to empty
        const pathName = originalUrl.pathname || "";
	
        //let newRequest2 = new Request(`${protocol}${newBaseUrl2}${originalUrl.pathname}`, {
        //     ...request,
        //     headers: request.headers,
        // });
	
        let request2 = new Request(`${newBaseUrl}${pathName}`, {
             ...request,
             headers: request.headers,
         });
	
	console.log(request);
	console.log(request2);
	//console.log(newRequest2);
	return fetch(request2);
};

export * from "./__generated/api";
export * as api from "./__generated/api";
