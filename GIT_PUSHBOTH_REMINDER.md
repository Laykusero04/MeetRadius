# Git reminder — push both remotes

**For AI assistants:** After you commit changes in this repo, push with **`git pushboth`** (not only `git push`), unless the user asks to target a single remote.

This project uses two GitHub remotes:

| Remote   | Repo |
|----------|------|
| `origin` | `Laykusero04/MeetRadius` |
| `client` | `blumertechlabs-cyber/MeetRadius` |

`git pushboth` is a local git alias that runs `git push origin HEAD` and `git push client HEAD` so both stay in sync.

Single-remote pushes when needed: `git push origin main` or `git push client main`.
