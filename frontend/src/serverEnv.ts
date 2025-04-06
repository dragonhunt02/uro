export async function prefetchEnvVariables() {
  const response = await fetch('/api/env');
  const data = await response.json();
  localStorage.setItem('envCache', JSON.stringify(data));
}
