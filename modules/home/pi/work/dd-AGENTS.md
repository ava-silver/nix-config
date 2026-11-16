# Datadog workspace

This directory (`~/go/src/github.com/DataDog` or `~/dd`) holds clones of DataDog repositories. Each subdirectory is its own git repository; `<repo>.worktrees/` directories hold that repository's worktrees.

- When a task needs a DataDog-owned repository that isn't here, clone it into this directory using `gh`.
- For work inside a specific repository, spawn a subagent with `working_dir` set to that repository (or its worktree), not this directory. The subagent then loads the repository's `AGENTS.md` and repository context, such as visibility and CI.

## Repositories

- Serverless tooling repositories (IaC, CLI, and tracer libraries): Load the `repos` skill to map a repository to its team and purpose.
- `experimental/`: A shared Datadog repository for prototypes, demos, and one-off scripts worth committing and sharing. Put my work in `experimental/users/ava.silver/<project>/` and team-wide utilities in `experimental/teams/serverless/`. Production-quality standards don't apply.
- `serverless-ci/`: Internal glue for Serverless open source repositories. It holds GitLab CI config for public repositories, Campaigner campaigns that open PRs across repositories, the Lambda layer catalog, E2E tests, and shared scripts.
- `~/nix-config`: My Nix config (nix-darwin and home-manager), including this file at `modules/home/pi/work/dd-AGENTS.md`. Apply changes with `just switch`.
- `~/.pi/agent`: My pi config (extensions, skills, prompts, and global `AGENTS.md`). Apply changes with `/reload`. `settings.json` is a symlink; edit `~/nix-config/modules/home/pi/work/settings.json` instead.
- Other repositories (`dd-source`, `dogweb`, `web-ui`, `datadog-agent`, and so on) are mostly monorepos owned by other teams; Serverless contributes to specific paths.

## AWS auth

- Run commands needing AWS auth through `aws-sso-exec` (for example, `aws-sso-exec aws sts get-caller-identity`; default profile: `sso-serverless-sandbox-account-admin`). It uses native AWS SSO and opens a browser for the user to auth only when required.
- Never use `aws-vault`. When a repo script or doc says `aws-vault exec <profile> -- <cmd>`, run `<cmd>` through `aws-sso-exec` instead.
