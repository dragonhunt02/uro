'use client';

import { useEffect } from 'react';
import { prefetchEnvVariables } from '~/serverEnv';

export function ClientPrefetch() {
  useEffect(() => {
    prefetchEnvVariables().catch((error) =>
      console.error('Error prefetching environment variables:', error)
    );
  }, []);

  return null; // This component doesn't render anything visible
}
