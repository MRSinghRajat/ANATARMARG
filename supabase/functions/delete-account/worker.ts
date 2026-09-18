// Testable job lifecycle; production adapter lives in operations.ts.
export interface DeletionJob {
  user_id: string;
  lease_token: string;
  apple_refresh_token: string | null;
  apple_status: 'pending' | 'revoked' | 'not_applicable';
  auth_removed: boolean;
}
export interface DeletionOutcome {
  appleRevoked: boolean;
  authRemoved: boolean;
  error: string | null;
}
export interface DeletionOperations {
  claim(userId?: string): Promise<DeletionJob | null>;
  revoke(token: string): Promise<boolean>;
  removeStorage(job: DeletionJob): Promise<void>;
  deleteAuth(userId: string): Promise<boolean>;
  finish(job: DeletionJob, outcome: DeletionOutcome): Promise<boolean>;
}

export async function processDeletionJob(
  operations: DeletionOperations,
  userId?: string,
): Promise<'complete' | 'pending' | 'busy'> {
  const job = await operations.claim(userId);
  if (!job) return 'busy';
  const outcome: DeletionOutcome = {
    appleRevoked: job.apple_status === 'revoked',
    authRemoved: job.auth_removed,
    error: null,
  };
  if (job.apple_status === 'pending') {
    try {
      outcome.appleRevoked = !!job.apple_refresh_token && await operations.revoke(job.apple_refresh_token);
    } catch { outcome.appleRevoked = false; }
    if (!outcome.appleRevoked) outcome.error = 'apple_revocation_pending';
  }
  // Apple outages never prevent removal of the Auth account. Its credential
  // remains in the independent job, so future retries do not need a user JWT.
  if (!outcome.authRemoved) {
    try {
      await operations.removeStorage(job);
      outcome.authRemoved = await operations.deleteAuth(job.user_id);
      if (!outcome.authRemoved) outcome.error = 'auth_deletion_pending';
    } catch { outcome.error = 'storage_or_auth_deletion_pending'; }
  }
  const committed = await operations.finish(job, outcome);
  if (!committed) return 'pending'; // Success under an expired lease is retried.
  return outcome.authRemoved && (outcome.appleRevoked || job.apple_status === 'not_applicable')
    ? 'complete' : 'pending';
}
