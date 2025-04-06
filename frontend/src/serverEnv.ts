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
    return { apiOrigin: "string" };
  }
 /*
  const cachedData = localStorage.getItem('envCache');
  if (!cachedData) {
    throw new Error('Environment variables are not available yet!');
  }
  return JSON.parse(cachedData);
  */
}
