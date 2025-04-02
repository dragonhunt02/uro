"use client";

import { useQueryClient, useQuery } from "@tanstack/react-query";
import { redirect } from "next/dist/client/components/redirect";

import { listSharedFilesByTag } from "~/api";
import { getQueryClient } from "~/query";

import { useReturnIntent } from "./return-intent";
import { useLocation } from "./location";

export const useListSharedFiles = () => {
  const { withReturnIntent } = useReturnIntent();
  const { pathname } = useLocation();
  const queryClient = useQueryClient();

  const { data: sharedFiles } = useQuery({
    queryFn: async () => {
      const response = await listSharedFilesByTag({ pathParams: { tag: "downloads" } });
      if (!response) {
        //throw new Error("Network response was not ok");
        return null;
      }
      return response; //.json();
    },
    queryKey: ["shared-files-by-downloads", "downloads"],
    refetchOnWindowFocus: "always"
  });

  return sharedFiles;
};
/*
export const useListSharedFiles = () => {
	const { withReturnIntent } = useReturnIntent();
	const { pathname } = useLocation();
	const queryClient = useQueryClient();

	const { data: session } = useSuspenseQuery({
		queryFn: async () => {
			const data = await getOptionalSession();
			if (!data) return null;

			queryClient.setQueryData(["users", data.user.username], data.user);
			return data;
		},
		queryKey: ["session"],
		refetchOnWindowFocus: "always"
	});


	return session;
};

*/
