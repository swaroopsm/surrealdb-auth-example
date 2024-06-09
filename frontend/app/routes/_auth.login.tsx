import {
  Link,
  Form,
  ClientActionFunctionArgs,
  useActionData,
  useNavigation,
} from "@remix-run/react";
import { useEffect } from "react";
import { SiGithub, SiGoogle } from "@icons-pack/react-simple-icons";

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
  const response = await fetch("/api/auth/signin", {
    method: "POST",
    body: JSON.stringify({
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

export default function Login() {
  const actionData = useActionData();
  const navigation = useNavigation();

  useEffect(() => {
    if (actionData?.data?.success) {
      window.location.href = "/";
    }
  }, [actionData]);

  return (
    <Card className="mx-auto max-w-sm">
      <CardHeader>
        <CardTitle className="text-2xl">Login</CardTitle>
        <CardDescription>
          Enter your email below to login to your account
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form className="grid gap-4" action="/login" method="post">
          <div className="grid gap-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              name="email"
              type="email"
              placeholder="m@example.com"
              required
            />
          </div>
          <div className="grid gap-2">
            <div className="flex items-center">
              <Label htmlFor="password">Password</Label>
              <Link to="#" className="ml-auto inline-block text-sm underline">
                Forgot your password?
              </Link>
            </div>
            <Input id="password" name="password" type="password" required />
          </div>
          <Button
            type="submit"
            className="w-full"
            loading={navigation.state === "submitting"}
          >
            Login
          </Button>
          <Button variant="outline" className="w-full" asChild>
            <a href="/api/oauth/github" className="flex gap-2">
              <SiGithub className="size-4" /> Login with GitHub
            </a>
          </Button>

          <Button variant="outline" className="w-full" asChild>
            <a href="/api/oauth/google" className="flex gap-2">
              <SiGoogle className="size-4" /> Login with Google
            </a>
          </Button>
        </Form>
        <div className="mt-4 text-center text-sm">
          Don&apos;t have an account?{" "}
          <Link to="/signup" className="underline">
            Sign up
          </Link>
        </div>
      </CardContent>
    </Card>
  );
}
