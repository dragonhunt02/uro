import { usePathname, useSearchParams } from "next/navigation";

import { origin } from "~/environment";

type Location = URL & { current: string };

/**
 * A combination of {@link usePathname} and {@link useSearchParams}.
 */
export function useLocation(): Location {
	const pathname = usePathname();
	const searchParameters = useSearchParams();
	const api_origin = await origin();

	const current = `${pathname}${searchParameters.size > 0 ? `?${searchParameters.toString()}` : ""}`;
	return Object.assign(new URL(current, api_origin), { current });
}
