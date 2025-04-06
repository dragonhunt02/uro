interface Env {
  origin?: string;
  apiOrigin?: string;
  turnstileSiteKey?: string;
}

let cachedEnv: Env = {};

//let cachedEnv: Record<string, any> | null = null;

function initializeEnvironment() {
  if (!cachedEnv) {
    const localStorageEnv = localStorage.getItem('env');
    if (localStorageEnv) {
      cachedEnv = JSON.parse(localStorageEnv);
    } else {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', '/api/env', false); // Synchronous XMLHttpRequest
      xhr.send();

      if (xhr.status === 200) {
        cachedEnv = JSON.parse(xhr.responseText);
        localStorage.setItem('env', JSON.stringify(cachedEnv));
      } else {
        throw new Error('Failed to fetch environment variables');
      }
    }
  }
}

// Initialize environment variables on module load
initializeEnvironment();

export const origin = '';
export const apiOrigin = '';
export const turnstileSiteKey = '';
//export const urls = cachedEnv?.urls || {};

/**
 * A set of first-party origins, these are given special treatment in the
 * application, such as in OAuth2 redirection & opening links in a new tab.
 */
export const firstPartyOrigins = new Set(['']);

//function environment<T>(value: unknown, name: string): T {
//	if (!value) throw new Error(`Missing environment variable: ${name}.`);
//	return value as T;
//}

export const development = process.env.NODE_ENV === "development";

if (development) {
	process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = "0";
}

export const urls = {
	discord: "https://discord.gg/7BQDHesck8",
	github: "https://github.com/v-sekai",
	twitter: "https://twitter.com/vsekaiofficial"
};
