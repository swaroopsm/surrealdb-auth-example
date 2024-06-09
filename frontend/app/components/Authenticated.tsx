import { Redirect } from "./Redirect";
import { useOutletContext } from "@remix-run/react";
import { OutletContext } from "~/types";

export function Authenticated({ children }: { children: React.ReactNode }) {
  const ctx = useOutletContext<OutletContext>();
  const isLoggedIn = Boolean(ctx?.me);

  return isLoggedIn ? children : <Redirect to="/login" />;
}
