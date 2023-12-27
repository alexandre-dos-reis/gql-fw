import Sdk from "casdoor-js-sdk";
import { SdkConfig } from "casdoor-js-sdk/lib/cjs/sdk";
import { AuthProvider } from "react-admin";
import { jwtDecode } from "jwt-decode";

const sdkConfig: SdkConfig & { clientSecret: string } = {
  serverUrl: import.meta.env.VITE_ADMIN_AUTH_SERVER_URL,
  clientId: import.meta.env.VITE_ADMIN_AUTH_CLIENT_ID,
  clientSecret: import.meta.env.VITE_ADMIN_AUTH_CLIENT_SECRET,
  appName: import.meta.env.VITE_ADMIN_AUTH_APP_NAME,
  organizationName: import.meta.env.VITE_ADMIN_AUTH_ORGANIZATION_NAME,
  redirectPath: "/#/auth-callback",
};

const initAuthProvider = (cfg: typeof sdkConfig): AuthProvider => {
  const casdoor = new Sdk(cfg);

  return {
    login: async () => {
      return Promise.resolve();
    },
    logout: async () => {
      localStorage.removeItem("token");
      return Promise.resolve();
    },
    checkAuth: async () => {
      if (localStorage.getItem("token")) {
        return Promise.resolve();
      } else {
        casdoor.clearState();
        const st = casdoor.getOrSaveState();
        console.log("token not found, new state ", st);
        return Promise.reject();
      }
    },
    checkError: async (error) => {
      const status = error.status;
      if (status === 401 || status === 403) {
        localStorage.removeItem("username");
        return Promise.reject();
      }
      // other error code (404, 500, etc): no need to log out
      return Promise.resolve();
    },
    getIdentity: async () => {
      // const token = localStorage.getItem("token");
      // if (token) {
      //   const decoded = jwtDecode(token);
      //   console.log(decoded);
      // }

      return Promise.resolve({
        id: "user",
        fullName: "John Doe",
      });
    },
    getPermissions: async () => Promise.resolve(1),
    handleCallback: async () => {
      const url = window.location.href.replace("#", "");
      const { searchParams } = new URL(url);
      const code = searchParams.get("code");
      const state = searchParams.get("state");
      const expectedState = casdoor.getOrSaveState();

      if (expectedState != state) {
        return Promise.reject();
      }

      await fetch(`${cfg.serverUrl}${"/api/login/oauth/access_token"}`, {
        method: "post",
        mode: "cors",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({
          grant_type: "authorization_code",
          client_id: cfg.clientId,
          client_secret: cfg.clientSecret,
          code: code,
        }),
      })
        .then((res) => {
          res.json().then((r) => {
            console.log(r);
            if (r.access_token != "") {
              localStorage.setItem("token", r.access_token);
              return { redirectTo: "/" };
            }
          });
        })
        .catch(() => {
          return Promise.reject();
        });
    },
    loginPage: () => {
      window.location.replace(casdoor.getSigninUrl());
      return null;
    },
  };
};

export const authProvider = initAuthProvider(sdkConfig);
