"use client";

import LinkPrimitive from "next/link";
import { twMerge } from "tailwind-merge";
import {
    type ComponentRef,
    forwardRef,
    type ComponentProps,
    type FC,
    useState,
    useEffect,
} from "react";

import { dataAttribute } from "~/element";
import { firstPartyOrigins } from "~/environment";
import { fetchServerEnv } from "~/environment";

export const Link = forwardRef<
	ComponentRef<typeof LinkPrimitive>,
	ComponentProps<typeof LinkPrimitive>
>(({ href: _href, children, className, ...props }, reference) => {
    // State to store the computed `href` and `external` values
    const [href, setHref] = useState("http://fallback.vsekai.local");
    const [external, setExternal] = useState(true);

    useEffect(() => {
        const loadServerEnv = async () => {
            const serverEnv = await fetchServerEnv();
            const originEnv = serverEnv?.origin ?? "http://fallback2.vsekai.local";

            if (_href) {
                const url = new URL(_href.toString(), originEnv);

                setHref(
                    url.origin === originEnv
                        ? url.href.replace(originEnv, "")
                        : url.href
                );
                setExternal(
                    !firstPartyOrigins.has(url.origin) && !(originEnv === url.origin)
                );
            }
        };

        if (typeof window !== "undefined") {
            loadServerEnv();
        }
    }, [_href]);

    return (
        <LinkPrimitive
            data-external={dataAttribute(external)}
            href={href}
            ref={reference}
            target={external ? "_blank" : undefined}
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
