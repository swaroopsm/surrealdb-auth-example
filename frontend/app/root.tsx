import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  ShouldRevalidateFunction,
  useLoaderData,
} from "@remix-run/react";
import type { LinksFunction } from "@remix-run/node";
import { LoaderCircle } from "lucide-react";
import { Me } from "./types";

import stylesheet from "~/globals.css?url";

export const links: LinksFunction = () => [
  { rel: "stylesheet", href: stylesheet },
];

export async function clientLoader() {
  const response = await fetch("/api/me", {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });
  const me = await response.json();

  if (!response.ok) {
    return {
      error: me,
    };
  }

  return {
    data: {
      me,
    },
  };
}

export const shouldRevalidate: ShouldRevalidateFunction = () => {
  return false;
};

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

export default function App() {
  const { data } = useLoaderData<{
    data?: { me: Me };
    error?: any;
  }>();

  return <Outlet context={data} />;
}

export function HydrateFallback() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <LoaderCircle className="animate-spin size-24" />;
    </div>
  );
}
