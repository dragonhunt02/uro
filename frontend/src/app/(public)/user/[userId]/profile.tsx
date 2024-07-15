"use client";

import { twMerge } from "tailwind-merge";
import { Ellipsis, Pencil, Rss, UserPlus } from "lucide-react";

import { useOptionalSession } from "~/hooks/session";
import { DialogTrigger } from "~/components/dialog";
import { Button, ButtonGroup } from "~/components/button";
import { VSekaiMark } from "~/components/vsekai-mark";

import { useUser } from "../data";

import { Navigation, NavigationItem } from "./navigation";
import { EditProfile } from "./edit-profile";
import { StatusBadge } from "./status-badge";
import { UserImage } from "./user-image";

import type { FC } from "react";

const ProfileActionNavigation: FC<{ userId: string }> = ({ userId }) => {
	const session = useOptionalSession();

	const user = useUser(userId);
	if (!user) return null;

	return (
		<div className="flex gap-2">
			{session?.user.id === user.id ? (
				<>
					<EditProfile userId={userId}>
						<DialogTrigger asChild>
							<Button type="light">
								<Pencil className="size-4" /> Edit profile
							</Button>
						</DialogTrigger>
					</EditProfile>
				</>
			) : (
				<ButtonGroup>
					<Button type="light">
						<UserPlus className="size-4" /> Friend
					</Button>
					<Button>
						<Rss className="size-4" /> Follow
					</Button>
				</ButtonGroup>
			)}
			<Button iconOnly type="ghost">
				<Ellipsis className="size-4" />
			</Button>
		</div>
	);
};

export const UserProfile: FC<{ userId: string }> = ({ userId }) => {
	const session = useOptionalSession();

	const user = useUser(userId);
	if (!user) return null;

	const { username, display_name, banner, status, biography } = user;

	return (
		<div className="w-full">
			<div className="absolute z-10 w-full">
				<div className="mx-auto flex max-w-screen-xl justify-between gap-4 p-4 xl:gap-8">
					<NavigationItem
						invert
						className="shrink-0 xl:w-72"
						href="/"
						Icon={VSekaiMark}
					>
						V-Sekai
					</NavigationItem>
					{session && (
						<Button
							className="flex items-center gap-4 p-0 text-white"
							href={`/@${session.user.username}`}
							type="ghost"
						>
							<div className="flex flex-col items-end">
								<span className="truncate whitespace-nowrap">
									{session.user.display_name}
								</span>
								<span className="text-sm leading-none opacity-75">
									@{session.user.username}
								</span>
							</div>
							<UserImage
								priority
								className="size-10"
								height={40}
								user={session.user}
								width={40}
							/>
						</Button>
					)}
				</div>
			</div>
			<div
				className="relative aspect-[16/4] min-h-64 w-full bg-cover bg-center before:absolute before:inset-0 before:bg-black/50"
				style={{
					backgroundImage: banner ? `url(${banner})` : undefined
				}}
			/>
			<div className="relative z-10 mx-auto -mt-20 flex max-w-screen-xl gap-4 px-4 xl:gap-8">
				<Navigation />
				<div className="flex w-full flex-col gap-4">
					<div className="flex gap-4 md:gap-8">
						<UserImage
							priority
							className="size-24 md:size-36"
							height={144}
							user={user}
							width={144}
						/>
						<div
							className={twMerge(
								"flex w-full flex-col",
								status && !["offline", "invisible"].includes(status)
									? "gap-3"
									: "gap-10"
							)}
						>
							<div className="dark flex items-center justify-between gap-8">
								<div className={twMerge("flex flex-col")}>
									<span className="truncate whitespace-nowrap text-4xl">
										{display_name}
									</span>
									<span className="text-sm leading-none opacity-75">
										@{username}
									</span>
								</div>
								<ProfileActionNavigation userId={user.id} />
							</div>
							<StatusBadge user={user} />
							<span className="hidden md:inline">
								{biography || "No biography available."}
							</span>
						</div>
					</div>
					<span className="md:hidden">
						{biography || "No biography available."}
					</span>
					<pre className="whitespace-pre-wrap rounded-xl border border-tertiary-200 p-4">
						{JSON.stringify(user, null, 2)}
					</pre>
				</div>
			</div>
		</div>
	);
};
