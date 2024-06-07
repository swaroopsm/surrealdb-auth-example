import type { MetaFunction } from "@remix-run/node";
import { useAuth } from "~/contexts/auth";
import { Redirect } from "~/components/Redirect";

export const meta: MetaFunction = () => {
  return [
    { title: "SurrealDB Auth Example" },
    { name: "description", content: "" },
  ];
};

export default function Index() {
  const { isLoggedIn } = useAuth();
  const to = isLoggedIn ? "/settings" : "/login";

  return <Redirect to={to} />;

  return null;
}
