import type { MetaFunction } from "@remix-run/node";
import { Card, CardHeader, CardContent } from "~/components/ui/card";
import { Avatar, AvatarImage, AvatarFallback } from "~/components/ui/avatar";
import { useAuth } from "~/contexts/auth";
import { Authenticated } from "~/components/Authenticated";
import { SiGithub } from "@icons-pack/react-simple-icons";

export const meta: MetaFunction = () => {
  return [
    { title: "SurrealDB Auth Example" },
    { name: "description", content: "" },
  ];
};

export default function Settings() {
  const { me } = useAuth();

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

              <div className="flex items-center justify-center">
                {me?.connected_accounts?.map?.((account) => (
                  <a
                    href={account.url}
                    key={account.provider}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <SiGithub />
                  </a>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </Authenticated>
  );
}
