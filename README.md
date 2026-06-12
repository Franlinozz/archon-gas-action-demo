# Archon Gas Action — live demo

This repository demonstrates [Archon](https://archonaudit.xyz)'s CI surface on a real pull-request workflow, against Archon's production API:

1. **`gas-diff`** — the [Archon Gas Action](https://github.com/Franlinozz/Archon/blob/main/action.yml) (`uses: Franlinozz/Archon@main`) runs Archon's Mantle gas optimizer on `contracts/RewardsVault.sol` and posts/updates a PR comment with the real gas report: L2 execution vs L1/DA columns, per-optimization deltas, and annualized savings under stated traffic assumptions.
2. **`security-gate`** — the [`archon-scan` CLI](https://archonaudit.xyz/docs/platform-api/cli) (`npx github:Franlinozz/archon-cli`) audits the same contract and **fails the build** when any finding is at or above `high`.

## See it live

- ✅ **Green run + gas comment:** [PR #1](https://github.com/Franlinozz/archon-gas-action-demo/pull/1) — a safe storage-caching optimization; the Action comments the L2/DA diff and the security gate passes.
- ❌ **Red run on a regression:** [PR #2](https://github.com/Franlinozz/archon-gas-action-demo/pull/2) — introduces a reentrancy regression; the `archon-scan --fail-on high` gate exits `2` and the check goes red.

Both PRs are kept open as living evidence.

## Use it in your repo

```yaml
permissions: { contents: read, pull-requests: write }
steps:
  - uses: actions/checkout@v4
  - uses: Franlinozz/Archon@main
    with:
      source-file: contracts/YourContract.sol
      github-token: ${{ secrets.GITHUB_TOKEN }}
  - uses: actions/setup-node@v4
    with: { node-version: 22 }
  - run: npx --yes github:Franlinozz/archon-cli scan contracts/ --fail-on high
```

Docs: [CI GitHub Action](https://archonaudit.xyz/docs/gas-optimizer/ci-github-action) · [CLI](https://archonaudit.xyz/docs/platform-api/cli) · [How Mantle gas works](https://archonaudit.xyz/docs/gas-optimizer/how-mantle-gas-works)
