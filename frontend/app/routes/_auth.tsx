import { Outlet, useOutletContext } from "@remix-run/react";
import { Redirect } from "~/components/Redirect";
import { OutletContext } from "~/types";

export default function Auth() {
  const ctx = useOutletContext<OutletContext>();
  const isLoggedIn = Boolean(ctx?.me);

  return isLoggedIn ? (
    <Redirect to="/" />
  ) : (
    <div className="min-h-screen flex items-center py-20">
      <Outlet />
    </div>
  );
}
