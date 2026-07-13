# Contributing

Thanks for taking the time to contribute to port-forward-manager!

## Getting started

`pfm` is a single Bash script. You need `bash`, `make`, `shellcheck`, and
`kubectl` (only for real use — tests stub it).

1. Fork and clone the repo.
1. Install hooks and tooling: `make setup`.
1. Create a branch: `git checkout -b feat/short-description`.

```sh
make lint    # shellcheck pfm test.sh
make test    # ./test.sh (kubectl is stubbed; no cluster needed)
```

## Making changes

- Keep changes focused; one logical change per PR, keeping the existing style.
- Add or update tests, and update `docs/` and `examples/` when behavior changes.
- Ensure CI (`code-quality` + `security`) passes.
- Don't edit `CHANGELOG.md` by hand — it's generated from commit messages by
  release-please (see [Releases](#releases)).

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`,
`fix:`, `docs:`, `chore:`, etc. This drives the version bump: `fix:` → patch,
`feat:` → minor, `feat!:` or a `BREAKING CHANGE:` footer → major.

## Releases

Releases are automated by [release-please](.github/workflows/release.yml); you
don't tag or edit the changelog manually.

1. Merge `feat:`/`fix:` PRs into `main` as normal — **no tag is created**.
1. release-please keeps an open **release PR** ("chore: release X.Y.Z"),
   recalculating the next version and changelog on every merge.
1. When you're ready to ship, **merge the release PR** — that (and only that)
   creates the `vX.Y.Z` tag, the GitHub Release, and attaches the `pfm` script
   plus its checksum for `curl` installs.

## Pull requests

Fill out the PR template, link related issues, and request review. By
participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md). Be kind.
