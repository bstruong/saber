import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ApiError } from "@/api/client";
import { fetchCurrentUser, signIn, signOut, type User } from "@/api/users";

const CURRENT_USER_KEY = ["currentUser"] as const;

export function useCurrentUser() {
  return useQuery<User | null>({
    queryKey: CURRENT_USER_KEY,
    queryFn: async () => {
      try {
        return await fetchCurrentUser();
      } catch (err) {
        if (err instanceof ApiError && err.status === 401) {
          return null;
        }
        throw err;
      }
    },
  });
}

export function useSignIn() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      signIn(email, password),
    onSuccess: (user) => {
      queryClient.setQueryData(CURRENT_USER_KEY, user);
    },
  });
}

export function useSignOut() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: signOut,
    onSuccess: () => {
      queryClient.setQueryData(CURRENT_USER_KEY, null);
      queryClient.removeQueries();
      queryClient.setQueryData(CURRENT_USER_KEY, null);
    },
  });
}
