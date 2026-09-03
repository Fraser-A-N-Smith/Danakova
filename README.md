# Campaign vault — operator notes

Shared D&D notes for six people, served by [CollabMD](https://github.com/andes90/collabmd)
over a Cloudflare Quick Tunnel. No subscriptions.

## Running it

```powershell
.\start-campaign.ps1        # prints + copies the share link and password
.\stop-campaign.ps1
.\sync-obsidian-edits.ps1   # only needed if you edited in Obsidian (see below)
```

## How it fits together

- `vault/` is the notes — plain markdown on your disk.
- `docker-compose.yml` runs two containers: CollabMD (the editor) and cloudflared
  (the public link).
- `.env` holds the shared password and session key. Gitignored. Change and restart
  to rotate.

## Read this before you rely on it

**Edit in the browser, not in Obsidian.** This is the important one. Docker on
Windows does not forward filesystem events into containers — this was tested
directly on this machine: `fs.watch` fires correctly on the container's own
filesystem and fires *nothing at all* on the `./vault` bind mount. CollabMD uses
exactly that API to detect external edits, so:

- Notes you edit in Obsidian will **not** appear for your players until CollabMD
  rescans the vault.
- Worse, CollabMD's in-memory copy is then stale, so a later browser edit to the
  same note can overwrite what you wrote in Obsidian.

CollabMD rescans on startup, so `.\sync-obsidian-edits.ps1` makes your Obsidian
changes live. But the safe habit is to treat the browser as the editing surface
for this vault and use Obsidian for reading, Graph View, and plugins. Your personal
`Notes Vault` is unaffected — this only concerns the campaign vault.

The browser editor is not a downgrade for note-taking: wiki-links, backlinks,
outline, quick switcher, global search, live preview, diagrams, anchored comments,
presence and chat are all there.

## Other things to know

- **Your PC is the server.** Players can only reach the vault while this machine is
  awake and the containers are running.
- **The share link changes every restart of the tunnel.** The password does not.
  Post the new link in Discord when you start up. A permanent hostname needs a
  Cloudflare account plus a domain you own. `sync-obsidian-edits.ps1` restarts only
  CollabMD, so it leaves the link intact.
- **There is no per-user permission model.** Anyone with the link and password can
  read and edit every file in `vault/`. Keep DM-only material in a different vault.
- **Git history is your undo.** CRDT merging stops people clobbering each other's
  typing; it does not stop someone deleting a note. Commit regularly.

## Verified working on this machine

- CollabMD v0.1.49 healthy, vault mounted, backlinks index resolving
- Password auth: correct password `200`, wrong password `401`, unauthenticated API `401`
- Cloudflare Quick Tunnel reachable from the public internet and gated by that password
- Vault rescan on restart picks up files created outside the container

## Does shutting down lose data? No — tested

`docker compose down` was run with both containers fully removed. All notes and
CollabMD's CRDT state were still on disk afterwards, unchanged.

Nothing lives inside the containers. `docker compose config --volumes` returns
empty — there are no named volumes. The only mount is a bind mount of
`.\vault` to `/data`, so every write goes straight to your Windows disk:

- `vault/**/*.md` — the notes themselves
- `vault/.collabmd/yjs/` — per-file CRDT state, so in-progress collaborative
  edits are restored rather than reset
- `vault/.collabmd/comments/` — anchored comment threads (tracked in git)

The containers are disposable; `docker compose down` then `up` rebuilds them
from the image and re-reads everything from disk.

Two things that *are* lost on shutdown, neither of them content:

- **The tunnel URL.** `down` kills cloudflared, so the next start gets a new
  random `trycloudflare.com` address. Use `sync-obsidian-edits.ps1` rather than a
  full restart when you only need a vault rescan — it leaves the tunnel alone.
- **The last instant of unsaved typing**, if you kill the server mid-keystroke.
  Same exposure as any editor.

Player logins survive, because `AUTH_SESSION_SECRET` is pinned in `.env`.

## Backups

The vault is pushed to `https://github.com/Fraser-A-N-Smith/Danakova.git`
(private) on branch `main`. This is the campaign's undo button: CRDT merging stops
players clobbering each other's typing, but it does not protect against someone
deleting a note.

```powershell
git add -A
git commit -m "Session 4"
git push
```

Worth doing after each session. What is and isn't backed up:

- **Backed up** — every note, plus `vault/.collabmd/comments/` (anchored comment
  threads are things people wrote, so they belong in history)
- **Not backed up** — `.env`, and CollabMD's regenerable runtime state
  (`yjs/` binary CRDT blobs, sqlite metadata, pull-backups)

`.env` is gitignored deliberately: it holds the shared password and the session
signing key. If you ever need those on another machine, copy the file by hand
rather than committing it.
