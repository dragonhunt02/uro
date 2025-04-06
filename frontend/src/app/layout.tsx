import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { HydrationBoundary } from "@tanstack/react-query";

import { getTheme } from "~/hooks/theme/server";
import { dehydrateAll, getQueryClient } from "~/query";
import { getOptionalSession } from "~/data/session";
import { prefetchEnvVariables } from "~/serverEnv";
import { ClientPrefetch } from '~/components/ClientPrefetch';
import { useEffect } from 'react';

import { Body, QueryProvider } from "./body";
import { LoadingIndicator } from "./loading-indicator";

import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
	description: "Your virtual reality platform, on your game engine.",
	title: "V-Sekai"
};

export default async function RootLayout({
	children
}: Readonly<{
	children: React.ReactNode;
}>) {
	const session = await getOptionalSession();
	//const prefetchEnv = await prefetchEnvVariables();

	const queryClient = getQueryClient();

	queryClient.setQueryData(["theme"], getTheme());
	queryClient.setQueryData(["session"], session);

	if (session)
		queryClient.setQueryData(["users", session.user.username], session.user);

        useEffect(() => {
		// Call prefetchEnvVariables only on the client side
		prefetchEnvVariables().catch(error => {
			console.error('Failed to prefetch environment variables:', error);
		});
	}, []);

						// <ClientPrefetch />
	
	return (
		<html lang="en">
			<QueryProvider>
				<HydrationBoundary state={dehydrateAll(queryClient)}>
					<Body>
						<ReactQueryDevtools />
						<LoadingIndicator />
						{children}
					</Body>
				</HydrationBoundary>
			</QueryProvider>
		</html>
	);
}
