import { client } from "@hey-api/client-fetch";
import { randomInt } from "@ariesclark/extensions";

import { apiOrigin, development } from "./environment";
import { useServerEnv, fetchEnv } from "~/hooks/server-env";
import { fetchServerEnv } from "~/fetchServerEnv";

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

	//#### Modify to baseUrl when server side request
	if (typeof window !== "undefined"){
		
        //const responsee = await fetch("/api/env");
        //const envJson = await responsee.json();
        console.log("yaho")
        //console.log(JSON.stringify(envJson))
	
        const envJson = await fetchServerEnv();
        console.log(envJson)
			
	const newBaseUrl = envJson?.origin || "";
		//process.env.API_ORIGIN || ""; // NOT WORKING it fallbacks to empty
        const pathName = originalUrl.pathname || "";
	const pathQuery = originalUrl.search || "";
	
        //let newRequest2 = new Request(`${protocol}${newBaseUrl2}${originalUrl.pathname}`, {
        //     ...request,
        //     headers: request.headers,
        // });
		
	const originalBody = await request.text();
        console.log("origbody")
        console.log(originalBody)
        let request2 = new Request(`${newBaseUrl}${pathName}${pathQuery}`, {
             //...request,
             method: request.method,
             body: originalBody,
             headers: request.headers,
             redirect: request.redirect,
             credentials: request.credentials,
             referrer: request.referrer,
             cache: request.cache
	});
		
	console.log('inside request');
	console.log(newBaseUrl, originalUrl.pathname);
		
	console.log(request);
	console.log(request2);
	//console.log(newRequest2);
	return fetch(request2);
	
	} else {
		return fetch(request)
	}
};

export * from "./__generated/api";
export * as api from "./__generated/api";
