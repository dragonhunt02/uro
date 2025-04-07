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

export const Link = forwardRef<
    ComponentRef<typeof LinkPrimitive>,
    ComponentProps<typeof LinkPrimitive>
>(({ href: _href, children, className, ...props }, reference) => {
    // State to store the computed `href` and `external` values
    const [href, setHref] = useState("http://fallback.vsekai.local");
    const [external, setExternal] = useState(true);

    useEffect(() => {
        const fetchServerEnv = async () => {
            try {
                const response = await fetch("/api/env"); // Fetch server environment data
                if (response.ok) {
                    const serverEnv = await response.json();
                    console.log("Fetched serverEnv:", serverEnv);

                    // Determine the origin environment
                    const originEnv = serverEnv?.origin ?? "http://fallback2.vsekai.local";
                    const url = new URL(_href?.toString() || "", originEnv);
                    console.log("checktest url");
                    console.log(String(url));
                    console.log(originEnv);

                    // Update `href` and `external` based on conditions
                    setHref(
                        url.origin === originEnv
                            ? url.href.replace(originEnv, "")
                            : url.href
                    );
                    setExternal(
                        !firstPartyOrigins.has(url.origin) && !(originEnv === url.origin)
                    );
                } else {
                    console.error(
                        `Failed to fetch server environment: ${response.status}`
                    );
                }
            } catch (error) {
                console.error("Error fetching server environment:", error);
                // Fallback values in case of error
                setHref("http://fallback.vsekai.local");
                setExternal(true);
            }
        };

        if (typeof window !== "undefined") {
            fetchServerEnv(); // Call fetch logic only in the browser
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
