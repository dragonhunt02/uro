import { useEffect, useState } from 'react';

export async function prefetchEnvVariables() {
  if (typeof window === 'undefined') {
    console.error('Cannot use localStorage in a server context.');
    return;
  }

  const response = await fetch('/api/env');
  const data = await response.json();
  console.log(data);
  //localStorage.setItem('envCache', JSON.stringify(data));
}

export function getEnvVariables(): { apiOrigin: string } {
  if (typeof window === 'undefined') {
    throw new Error('localStorage is not available in the server environment.');
  }
    return { apiOrigin: "string" };
 /*
  const cachedData = localStorage.getItem('envCache');
  if (!cachedData) {
    throw new Error('Environment variables are not available yet!');
  }
  return JSON.parse(cachedData);
  */
}

interface ServerEnv {
  origin?: string;
  apiOrigin?: string; // Combining possible values from both environment variables
  turnstileSiteKey?: string;
}
/*
export function getServerEnv(): ServerEnv {
	const [env, setEnv] = useState({});

  useEffect(() => {
    fetch('/api/env')
      .then((res) => res.json())
      .then((data) => setEnv(data))
  }, []);

  console.log(env);
return env;
}
*/
