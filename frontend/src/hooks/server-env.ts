"use client";

import { useQueryClient, useQuery } from "@tanstack/react-query";
//import { redirect } from "next/dist/client/components/redirect";

import { listSharedFilesByTag } from "~/api";
import { getQueryClient } from "~/query";

import { useReturnIntent } from "./return-intent";
import { useLocation } from "./location";

export const useServerEnv = () => {
  const { data: serverEnv, error } = useQuery({
    queryFn: async () => {
      const response = await fetch('/api/env');
      if (!response.ok) {
        throw new Error('Failed to fetch server environment data');
      }
      return await response.json();
    },
    queryKey: ["server-env"],
    refetchOnWindowFocus: false,
  });

  if (error) {
    console.error('Error fetching server environment:', error);
  }

  return serverEnv;
};
