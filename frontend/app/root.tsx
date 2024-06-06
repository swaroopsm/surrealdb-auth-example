import {
  ClientLoaderFunctionArgs,
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  useLoaderData,
} from "@remix-run/react";
import type { LinksFunction } from "@remix-run/node";
import { LoaderCircle } from "lucide-react";

import stylesheet from "~/globals.css?url";
import { defer } from "react-router";

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
  const data = await response.json();

  if (!response.ok) {
    return {
      error: data,
    };
  }

  return data;
}

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
  const { data, error } = useLoaderData<{ error?: any; data?: any }>();
  console.log({ data, error });

  return <Outlet />;
}

export function HydrateFallback() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <LoaderCircle className="animate-spin size-24" />;
    </div>
  );
}
