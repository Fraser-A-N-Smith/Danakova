# Campaign vault — operator notes

Shared D&D notes for six people, served by [CollabMD](https://github.com/andes90/collabmd)
over a Cloudflare Quick Tunnel. No subscriptions.

## Running it

```powershell
.\start-campaign.ps1   # prints + copies the share link and password
.\stop-campaign.ps1
```

## How it fits together

- `vault/` is the notes. Plain markdown on your disk — **open this folder as a
  vault in Obsidian** and use Obsidian normally. Edits sync into the browser live.
- `docker-compose.yml` runs two containers: CollabMD (the editor) and cloudflared
  (the public link).
- `.env` holds the shared password. Gitignored. Change it and restart to rotate.

## Things to know

- **Your PC is the server.** Players can only reach the vault while this machine
  is awake and the containers are running.
- **The share link changes on every restart.** The password doesn't. Post the new
  link in Discord when you start up. (A permanent hostname needs a Cloudflare
  account plus a domain you own.)
- **There is no per-user permission model.** Anyone with the link and password can
  read and edit every file in `vault/`. Keep DM-only material in a separate vault
  that is not this folder.
- **Players use the browser, not Obsidian.** They get editing, wiki-links,
  backlinks, search, comments, presence and chat. They do not get plugins,
  Graph View, or the Obsidian mobile app.
- **Git history is your undo.** CRDT merging prevents clobbering; it does not
  protect against someone deleting a note. Commit regularly.
