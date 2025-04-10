import { client } from "@hey-api/client-fetch";
import { randomInt } from "@ariesclark/extensions";

import { apiOrigin, development, getServerEnv } from "./environment";

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
if (typeof window === "undefined") {
	config.baseUrl = apiOrigin;
} else {
	config.baseUrl = getServerEnv()?.origin;
}
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

	// console.log(request);
	return fetch(request);
};

export * from "./__generated/api";
export * as api from "./__generated/api";
