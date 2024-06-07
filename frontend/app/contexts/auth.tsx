import { createContext, useContext } from "react";

interface IAuthContext {
  me?: {
    name: string;
    email: string;
  };
  isLoggedIn: boolean;
}

interface AuthContextProps extends Pick<IAuthContext, "me"> {
  children: React.ReactNode;
}

export const AuthContext = createContext<IAuthContext>({
  isLoggedIn: false,
});

export function AuthContextProvider({ me, children }: AuthContextProps) {
  const value = { me, isLoggedIn: Boolean(me) };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export const useAuth = () => useContext(AuthContext);