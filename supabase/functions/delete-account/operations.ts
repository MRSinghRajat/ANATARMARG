import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { loadAppleConfig, revokeAppleRefreshToken } from "../_shared/apple.ts";
import type { DeletionJob, DeletionOperations } from "./worker.ts";

export function deletionOperations(admin: SupabaseClient): DeletionOperations {
  return {
    async claim(userId) {
      const { data, error } = await admin.rpc("claim_account_deletion_job", {
        p_user_id: userId ?? null,
      });
      if (error) throw new Error("deletion_claim_failed");
      return (data?.[0] as DeletionJob | undefined) ?? null;
    },
    async revoke(token) {
      const config = loadAppleConfig();
      return config ? await revokeAppleRefreshToken(config, token) : false;
    },
    async removeStorage(job) {
      // Bounded batches; remaining objects retain the job for another run.
      for (let batch = 0; batch < 10; batch++) {
        const { data, error } = await admin.rpc(
          "list_account_deletion_objects",
          {
            p_user_id: job.user_id,
            p_lease_token: job.lease_token,
          },
        );
        if (error) throw new Error("storage_inventory_failed");
        if (!data?.length) return;
        const buckets = new Map<string, string[]>();
        for (const item of data as Array<{ bucket_id: string; name: string }>) {
          buckets.set(item.bucket_id, [
            ...(buckets.get(item.bucket_id) ?? []),
            item.name,
          ]);
        }
        for (const [bucket, paths] of buckets) {
          const { error: removeError } = await admin.storage.from(bucket)
            .remove(paths);
          if (removeError) throw new Error("storage_removal_failed");
        }
      }
      throw new Error("storage_more_batches_needed");
    },
    async deleteAuth(userId) {
      const { error } = await admin.auth.admin.deleteUser(userId);
      // Lost responses are safe: the next worker sees an already absent user.
      return !error || error.code === "user_not_found" || error.status === 404;
    },
    async finish(job, outcome) {
      const { data, error } = await admin.rpc("finish_account_deletion_job", {
        p_user_id: job.user_id,
        p_lease_token: job.lease_token,
        p_apple_revoked: outcome.appleRevoked,
        p_auth_removed: outcome.authRemoved,
        p_error: outcome.error,
      });
      if (error) throw new Error("deletion_commit_failed");
      return data === true;
    },
  };
}
