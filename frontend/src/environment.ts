let cachedEnv: Record<string, any> | null = null;

const fetchEnvironment = async () => {
  if (!cachedEnv) {
    const localStorageEnv = localStorage.getItem('env');
    if (localStorageEnv) {
      cachedEnv = JSON.parse(localStorageEnv);
    } else {
      const response = await fetch('/api/env');
      const data = await response.json();
      localStorage.setItem('env', JSON.stringify(data));
      cachedEnv = data;
    }
  }
  return cachedEnv;
};

// Fetch the environment variables on startup
fetchEnvironment().then((env) => {
  cachedEnv = env;
});

export const origin = async (): Promise<string> => {
  const env = await fetchEnvironment();
  return env.origin;
};

export const apiOrigin = async (): Promise<string> => {
  const env = await fetchEnvironment();
  return env.apiOrigin;
};

export const turnstileSiteKey = async (): Promise<string> => {
  const env = await fetchEnvironment();
  return env.turnstileSiteKey;
};

// export const urls = async (): Promise<Record<string, string>> => {
//  const env = await fetchEnvironment();
//  return env.urls;
//};

/**
 * A set of first-party origins, these are given special treatment in the
 * application, such as in OAuth2 redirection & opening links in a new tab.
 */
export const firstPartyOrigins = async (): Promise<Set<string>> => {
  const env = await fetchEnvironment();
  return new Set([env.origin]);
};

export const development = process.env.NODE_ENV === "development";

if (development) {
	process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";
}

export const urls = {
	discord: "https://discord.gg/7BQDHesck8",
	github: "https://github.com/v-sekai",
	twitter: "https://twitter.com/vsekaiofficial"
};
