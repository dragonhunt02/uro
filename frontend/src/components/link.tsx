import LinkPrimitive from "next/link";
import { twMerge } from "tailwind-merge";
import {
	type ComponentRef,
	forwardRef,
	type ComponentProps,
	type FC,
	useMemo
} from "react";

import { dataAttribute } from "~/element";
import { firstPartyOrigins, origin } from "~/environment";

export const Link = forwardRef<
	ComponentRef<typeof LinkPrimitive>,
	ComponentProps<typeof LinkPrimitive>
>(({ href: _href, children, className, ...props }, reference) => {
	const { href, external } = useMemo(() => {

		try {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "/api/env", false); // `false` makes it synchronous
    xhr.send();
  } catch (error) {
    console.error("error.message");
  }

		if (xhr.status !== 200){
      throw new Error(`Failed to fetch server environment: ${xhr.status}`);
    }
		const serverEnv = JSON.parse(xhr.responseText);
      console.log("Synchronous link serverEnv:", serverEnv);
		
		const url = new URL(_href.toString(), serverEnv.origin);
		const href =
			url.origin === serverEnv.origin ? url.href.replace(serverEnv.origin, "") : url.href;

		const external = !firstPartyOrigins.has(url.origin) && !(serverEnv.origin === url.origin);

		return { external, href };
	
	}, [_href]);

	return (
		<LinkPrimitive
			data-external={dataAttribute(external)}
			href={href}
			ref={reference}
			target={dataAttribute(external && "_blank")}
			className={twMerge(
				"outline-offset-2 outline-current transition-all focus-visible:outline",
				className
			)}
			{...props}
		>
			{children}
		</LinkPrimitive>
	);
});

Link.displayName = "Link";

export const InlineLink: FC<
	Omit<ComponentProps<typeof Link>, "href"> & { href: URL | string }
> = ({ children, className, ...props }) => {
	return (
		<Link
			className={twMerge(
				"text-blue-500 transition-all hover:text-blue-600 dark:text-blue-400 dark:hover:text-blue-500",
				className
			)}
			{...props}
		>
			{children}
		</Link>
	);
};
