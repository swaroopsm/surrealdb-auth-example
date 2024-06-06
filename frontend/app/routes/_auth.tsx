import { Outlet } from "@remix-run/react";

export default function Auth() {
  return (
    <div className="min-h-screen flex items-center py-20">
      <Outlet />
    </div>
  );
}
