import { useMemo } from "react";
import { useRouter } from "next/navigation";

import { firstPartyOrigins, origin } from "~/environment";

import { useLocation } from "../location";

const api_origin = await origin();

function minimizeHref(href: URL | string) {
	const url = new URL(href.toString(), api_origin);
	return url.origin === api_origin ? url.href.replace(api_origin, "") : url.href;
}

export function useReturnIntent() {
	const router = useRouter();

	const { current, searchParams } = useLocation();
	const _returnIntent = searchParams.get("ri");

	return useMemo(() => {
		let returnIntent = _returnIntent ? new URL(_returnIntent, api_origin) : null;
		if (returnIntent && !firstPartyOrigins.has(returnIntent.origin))
			returnIntent = null;

		return {
			restoreReturnIntent: (fallback: string = "/") =>
				router.push(returnIntent?.toString() || fallback),
			returnIntent,
			withReturnIntent: (pathname: string) => {
				const url = new URL(pathname, api_origin);
				url.searchParams.set(
					"ri",
					minimizeHref(returnIntent ? returnIntent.href : current)
				);

				return url;
			}
		};
	}, [router, _returnIntent, current]);
}
