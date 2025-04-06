export async function prefetchEnvVariables() {
  const response = await fetch('/api/env');
  const data = await response.json();
  localStorage.setItem('envCache', JSON.stringify(data));
}

export function getEnvVariables(): { apiOrigin: string } {
  const cachedData = localStorage.getItem('envCache');
  if (!cachedData) {
    throw new Error('Environment variables are not available yet!');
  }
  return JSON.parse(cachedData);
}
