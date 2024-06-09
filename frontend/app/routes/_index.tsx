import React from "react";
import type { MetaFunction } from "@remix-run/node";
import { Card, CardFooter, CardContent } from "~/components/ui/card";
import { Avatar, AvatarImage, AvatarFallback } from "~/components/ui/avatar";
import { Authenticated } from "~/components/Authenticated";
import { Button } from "~/components/ui/button";
import { SiGithub, SiGoogle } from "@icons-pack/react-simple-icons";
import {
  ClientActionFunctionArgs,
  useFetcher,
  useOutletContext,
} from "@remix-run/react";
import { useEffect } from "react";
import { OutletContext } from "~/types";

export const meta: MetaFunction = () => {
  return [
    { title: "SurrealDB Auth Example" },
    { name: "description", content: "" },
  ];
};

export async function clientAction({ request }: ClientActionFunctionArgs) {
  const { action, ...rest } = await request.json();

  const actions = {
    logout: async () => {
      try {
        await fetch("/api/auth/signout", { method: "DELETE" });
      } catch {
        /* empty */
      }
    },
  };

  const data = await actions?.[action]?.(rest);

  return { success: true, action };
}

export default function Index() {
  const ctx = useOutletContext<OutletContext>();
  const { submit, data, state } = useFetcher({ key: "auth.logout" });
  const me = ctx?.me;

  useEffect(() => {
    if (data?.action === "logout" && data?.success) {
      window.location.href = "/";
    }
  }, [data]);

  return (
    <Authenticated>
      <div className="min-h-screen flex items-center justify-center">
        <Card className="mx-auto max-w-md w-full relative">
          <CardContent className="flex items-center justify-center flex-col gap-8">
            <Avatar className="size-20 absolute -top-10">
              <AvatarImage src={me?.avatar || undefined} />
              <AvatarFallback className="text-3xl">
                {me?.initials}
              </AvatarFallback>
            </Avatar>
            <div className="flex flex-col gap-8 pt-10">
              <div className="flex flex-col gap-1 items-center">
                <h1 className="text-2xl">{me?.name}</h1>
                <a
                  className="text-lg text-surrealdb-pink underline"
                  href={`mailto:${me?.email}`}
                >
                  {me?.email}
                </a>
              </div>

              <div className="flex items-center gap-2 justify-center">
                {me?.connected_accounts?.map?.((account) => (
                  <React.Fragment key={account.provider}>
                    {account.provider === "github" && (
                      <a
                        href={account.url}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <SiGithub className="size-4" />
                      </a>
                    )}

                    {account.provider === "google" && (
                      <SiGoogle className="size-4" />
                    )}
                  </React.Fragment>
                ))}
              </div>
            </div>
          </CardContent>
          <CardFooter>
            <Button
              className="w-full"
              loading={state === "loading"}
              onClick={() => {
                submit(
                  { action: "logout" },
                  {
                    method: "post",
                    action: "/?index",
                    encType: "application/json",
                    navigate: false,
                    fetcherKey: "auth.logout",
                  }
                );
              }}
            >
              Logout
            </Button>
          </CardFooter>
        </Card>
      </div>
    </Authenticated>
  );
}
