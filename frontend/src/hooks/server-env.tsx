"use client";

import { useQueryClient, useQuery } from "@tanstack/react-query";
//import { redirect } from "next/dist/client/components/redirect";

import { listSharedFilesByTag } from "~/api";
import { getQueryClient } from "~/query";

import { useReturnIntent } from "./return-intent";
import { useLocation } from "./location";

export const useListDownloads = () => {
  const { withReturnIntent } = useReturnIntent();
  const { pathname } = useLocation();
  const queryClient = useQueryClient();

  const { data: serverEnv } = useQuery({
    queryFn: async () => {
      const response = await fetch('/api/env').then((res) => res.json());
      if (!response) {
        return null;
      }
      return response;
    },
    queryKey: ["server-env"],
    refetchOnWindowFocus: "always"
  });

  return serverEnv;
};
