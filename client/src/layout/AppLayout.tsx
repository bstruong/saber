import { Link, NavLink, Outlet } from "react-router";
import { Button } from "@/components/ui/button";
import { useCurrentUser, useSignOut } from "@/auth/hooks";

export function AppLayout() {
  const { data: user } = useCurrentUser();
  const signOutMutation = useSignOut();

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <header className="border-b">
        <div className="max-w-5xl mx-auto px-4 h-14 flex items-center justify-between gap-4">
          <Link to="/" className="font-semibold tracking-tight">
            SABER
          </Link>
          <nav className="flex items-center gap-1 text-sm">
            <NavItem to="/">Dashboard</NavItem>
            <NavItem to="/people">People</NavItem>
          </nav>
          <div className="flex items-center gap-3 text-sm">
            {user && (
              <span className="text-muted-foreground hidden sm:inline">
                {user.email}
              </span>
            )}
            <Button
              variant="ghost"
              size="sm"
              onClick={() => signOutMutation.mutate()}
              disabled={signOutMutation.isPending}
            >
              {signOutMutation.isPending ? "Signing out…" : "Sign out"}
            </Button>
          </div>
        </div>
      </header>
      <main className="flex-1">
        <div className="max-w-5xl mx-auto p-4">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

function NavItem({ to, children }: { to: string; children: React.ReactNode }) {
  return (
    <NavLink
      to={to}
      end={to === "/"}
      className={({ isActive }) =>
        `px-3 py-1.5 rounded-md transition-colors ${
          isActive
            ? "bg-accent text-accent-foreground"
            : "text-muted-foreground hover:text-foreground"
        }`
      }
    >
      {children}
    </NavLink>
  );
}
