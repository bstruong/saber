import { useState } from "react";
import { Navigate, useLocation } from "react-router";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ApiError } from "@/api/client";
import { useCurrentUser, useSignIn } from "@/auth/hooks";

export default function LoginPage() {
  const { data: user, isLoading } = useCurrentUser();
  const signInMutation = useSignIn();
  const location = useLocation();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  if (isLoading) return null;

  if (user) {
    const redirectTo =
      (location.state as { from?: string } | null)?.from ?? "/";
    return <Navigate to={redirectTo} replace />;
  }

  const errorMessage = formatError(signInMutation.error);

  return (
    <div className="min-h-screen grid place-items-center bg-background p-4">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>Sign in to SABER</CardTitle>
        </CardHeader>
        <CardContent>
          <form
            className="space-y-4"
            onSubmit={(e) => {
              e.preventDefault();
              signInMutation.mutate({ email, password });
            }}
          >
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            {errorMessage && (
              <p className="text-sm text-destructive">{errorMessage}</p>
            )}
            <Button
              type="submit"
              className="w-full"
              disabled={signInMutation.isPending}
            >
              {signInMutation.isPending ? "Signing in…" : "Sign in"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

function formatError(error: unknown): string | null {
  if (!error) return null;
  if (error instanceof ApiError && error.status === 401) {
    return "Invalid email or password.";
  }
  return "Something went wrong. Try again.";
}
