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
  if (typeof window !== "undefined") {
		try {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "/api/env", false); // `false` makes it synchronous
    xhr.send();
    console.warn(xhr.status);

		if (xhr.status === 200){
     // throw new Error(`Failed to fetch server environment: ${xhr.status}`);

		const serverEnv = JSON.parse(xhr.responseText);
      console.log("Synchronous link serverEnv:", serverEnv);
		let originEnv = "http://wrong.vsekai.local";
		originEnv = serverEnv?.origin ?? "http://wrong2.vsekai.local";
	console.log("oka")	
		const url = new URL(_href.toString(), originEnv);
console.log("okb")
		const href =
			url.origin === originEnv ? url.href.replace(originEnv, "") : url.href;
console.log("okc")
		const external = !firstPartyOrigins.has(url.origin) && !(originEnv === url.origin);

		return { external, href };
    } else {
    const fallb=new URL("http://wrong4.vsekai.local"); 
    const href=fallb.href; 
    const external = true;
		return { external, href };

}
	  } catch (error) {

    console.error("error.message", String(error));
           const fallbackUrl = new URL("http://fallback.vsekai.local");
            return { href: fallbackUrl.href, external: true };

  }

} else {
           const fallbackUrl2 = new URL("http://fallback2.vsekai.local");
            return { href: fallbackUrl2.href, external: true };

}
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
