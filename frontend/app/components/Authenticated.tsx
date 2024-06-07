import { useAuth } from "~/contexts/auth";
import { Redirect } from "./Redirect";

export function Authenticated({ children }: { children: React.ReactNode }) {
  const { isLoggedIn } = useAuth();

  return isLoggedIn ? children : <Redirect to="/login" />;
}
