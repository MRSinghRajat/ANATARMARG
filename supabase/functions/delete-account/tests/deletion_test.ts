import {
  type DeletionJob,
  type DeletionOperations,
  type DeletionOutcome,
  processDeletionJob,
} from "../worker.ts";
function assert(value: unknown, message = "assertion failed"): asserts value {
  if (!value) throw new Error(message);
}
function fake(overrides: Partial<DeletionOperations> = {}) {
  const job: DeletionJob = {
    user_id: "synthetic-user",
    lease_token: "synthetic-lease",
    apple_refresh_token: "synthetic-token",
    apple_status: "pending",
    auth_removed: false,
  };
  const calls: string[] = [];
  const outcomes: DeletionOutcome[] = [];
  const operations: DeletionOperations = {
    claim: async () => job,
    revoke: async (token) => {
      assert(token === "synthetic-token");
      calls.push("revoke");
      return true;
    },
    removeStorage: async () => {
      calls.push("storage");
    },
    deleteAuth: async () => {
      calls.push("auth");
      return true;
    },
    finish: async (_, outcome) => {
      outcomes.push(outcome);
      return true;
    },
    ...overrides,
  };
  return { job, calls, outcomes, operations };
}
Deno.test("stored Apple credential is revoked and storage removed before Auth deletion", async () => {
  const f = fake();
  assert(await processDeletionJob(f.operations) === "complete");
  assert(f.calls.join(",") === "revoke,storage,auth");
  assert(f.outcomes[0].appleRevoked);
});
Deno.test("Apple outage does not block Auth deletion and remains pending", async () => {
  const f = fake({
    revoke: async () => {
      throw new Error("outage");
    },
  });
  assert(await processDeletionJob(f.operations) === "pending");
  assert(f.outcomes[0].authRemoved && !f.outcomes[0].appleRevoked);
});
Deno.test("missing Apple configuration remains pending instead of falsely revoked", async () => {
  const f = fake({ revoke: async () => false });
  assert(await processDeletionJob(f.operations) === "pending");
  assert(f.outcomes[0].error === "apple_revocation_pending");
});
Deno.test("worker retries revocation after Auth account already removed", async () => {
  const f = fake();
  f.job.auth_removed = true;
  assert(await processDeletionJob(f.operations) === "complete");
  assert(f.calls.join(",") === "revoke");
});
Deno.test("storage failure defers Auth deletion and preserves retry outcome", async () => {
  const f = fake({
    removeStorage: async () => {
      throw new Error("outage");
    },
  });
  assert(await processDeletionJob(f.operations) === "pending");
  assert(!f.calls.includes("auth"));
  assert(f.outcomes[0].appleRevoked && !f.outcomes[0].authRemoved);
});
Deno.test("expired job lease never claims completion", async () => {
  const f = fake({ finish: async () => false });
  assert(await processDeletionJob(f.operations) === "pending");
});
Deno.test("no runnable job is busy and performs no side effects", async () => {
  const f = fake({ claim: async () => null });
  assert(await processDeletionJob(f.operations) === "busy");
  assert(!f.calls.length);
});
Deno.test("non-Apple account completes without a revocation attempt", async () => {
  const f = fake();
  f.job.apple_status = "not_applicable";
  f.job.apple_refresh_token = null;
  assert(await processDeletionJob(f.operations) === "complete");
  assert(!f.calls.includes("revoke"));
});
