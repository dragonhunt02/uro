'use client';

import { useEffect } from 'react';
import { prefetchEnvVariables } from '~/serverEnv';

export function ClientPrefetch() {
  useEffect(() => {
    if (typeof window !== 'undefined') {
    prefetchEnvVariables().catch((error) =>
      console.error('Error prefetching environment variables:', error)
    );
    } else {
      console.log('Cant prefetch env server sideError prefetching environment variables:')
    }
  }, []);

  return null; // This component doesn't render anything visible
}
