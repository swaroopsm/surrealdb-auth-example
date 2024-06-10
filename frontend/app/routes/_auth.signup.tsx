import {
  Link,
  Form,
  ClientActionFunctionArgs,
  useNavigation,
  useActionData,
} from "@remix-run/react";
import { useEffect } from "react";

import { Alert, AlertDescription, AlertTitle } from "~/components/ui/alert";
import { Button } from "~/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "~/components/ui/card";
import { Input } from "~/components/ui/input";
import { Label } from "~/components/ui/label";

export async function clientAction({ request }: ClientActionFunctionArgs) {
  const formData = await request.formData();
  const response = await fetch("/api/auth/signup", {
    method: "POST",
    body: JSON.stringify({
      name: formData.get("name"),
      email: formData.get("email"),
      password: formData.get("password"),
    }),
  });
  const data = await response.json();

  if (!response.ok) {
    return { error: data };
  }

  return { data };
}

export default function Signup() {
  const navigation = useNavigation();
  const action = useActionData<{ data?: any; error?: any }>();

  useEffect(() => {
    if (action?.data) {
      window.location.href = "/";
    }
  }, [action]);

  return (
    <Card className="mx-auto max-w-sm">
      <CardHeader>
        <div className="flex flex-col gap-4">
          <div>
            <CardTitle className="text-2xl">Sign up</CardTitle>
            <CardDescription>
              Enter the details below to sign up for an account
            </CardDescription>
          </div>

          {action?.error && (
            <Alert variant="destructive">
              <AlertTitle>Error</AlertTitle>
              <AlertDescription>
                Sign up failed. Please try to sign up with a different email.
              </AlertDescription>
            </Alert>
          )}
        </div>
      </CardHeader>
      <CardContent className="flex flex-col gap-8">
        <Form method="POST" action="/signup">
          <div className="grid gap-4">
            <div className="grid gap-2">
              <Label htmlFor="name">Name</Label>
              <Input
                id="name"
                name="name"
                type="text"
                placeholder="Max Mustermann"
                required
              />
            </div>

            <div className="grid gap-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                name="email"
                type="email"
                placeholder="max@example.org"
                required
              />
            </div>
            <div className="grid gap-2">
              <div className="flex items-center">
                <Label htmlFor="password">Password</Label>
              </div>
              <Input
                id="password"
                name="password"
                type="password"
                placeholder="********"
                required
              />
            </div>
            <Button
              type="submit"
              className="w-full"
              loading={navigation.state === "submitting"}
            >
              Signup
            </Button>
          </div>
          <div className="mt-4 text-center text-sm">
            Already have an account?{" "}
            <Link to="/login" className="underline">
              Login
            </Link>
          </div>
        </Form>
      </CardContent>
    </Card>
  );
}
