import { Authenticated } from "~/components/Authenticated";
import { Outlet } from "@remix-run/react";

export default function Dashboard() {
  return (
    <Authenticated>
      <Outlet />
    </Authenticated>
  );
}
