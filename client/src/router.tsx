import { createBrowserRouter } from "react-router";
import { ProtectedRoute } from "@/auth/ProtectedRoute";
import { AppLayout } from "@/layout/AppLayout";
import LoginPage from "@/routes/login";
import DashboardPage from "@/routes/dashboard";
import PeoplePage from "@/routes/people";
import PersonPage from "@/routes/person";

export const router = createBrowserRouter([
  {
    path: "/login",
    element: <LoginPage />,
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <AppLayout />,
        children: [
          { index: true, element: <DashboardPage /> },
          { path: "people", element: <PeoplePage /> },
          { path: "people/:id", element: <PersonPage /> },
        ],
      },
    ],
  },
]);
