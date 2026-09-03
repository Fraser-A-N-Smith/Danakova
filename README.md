# Danakova — shared campaign vault

Shared D&D notes for six people. Everyone edits in a browser at the same time and
sees each other's cursors, like a Google Doc but for a wiki of linked notes. Runs
on your own PC, costs nothing, no accounts for anyone to create.

Built on [CollabMD](https://github.com/andes90/collabmd) with a Cloudflare tunnel
for the share link.

---

# Part 1 — Setting it up from scratch

Written for someone who can follow instructions but doesn't live in a terminal.
You do this once. It takes about 20 minutes, most of which is waiting for
downloads.

If it's already set up on this machine, skip to [Part 2](#part-2--everyday-use).

## What you'll end up with

A folder on your PC holding the notes, and two small background programs that
serve them to your friends over the internet. You run one script to start it and
one to stop it.

## Step 0 — Things to know first

**Your PC is the server.** Your friends can only reach the notes while your
computer is awake and the vault is running. If you shut the lid, they're locked
out until you start it again. That's the main trade-off of the free setup.

**You'll be typing commands into PowerShell.** That's the blue terminal window.
Nothing here is dangerous, and every command is written out for you to copy.

**How to open PowerShell in the right folder:** open the folder in File Explorer,
click the address bar at the top so the path highlights, type `powershell` over
it, and press Enter. A terminal opens already pointed at that folder. You'll do
this a lot — it's much easier than navigating with `cd`.

## Step 1 — Install Docker Desktop

Docker runs the note-server for you, so you don't have to install and configure
it by hand.

1. Go to <https://www.docker.com/products/docker-desktop/> and download it for
   Windows.
2. Run the installer. Leave every option at its default — in particular **leave
   "Use WSL 2" ticked**. CollabMD doesn't run natively on Windows and needs this.
3. Restart your PC when it asks. It genuinely does need the restart.
4. Open Docker Desktop from the Start menu. First launch takes a couple of
   minutes. Wait until the bottom-left corner says **"Engine running"** with a
   green dot.

You can close the Docker Desktop window afterwards — it keeps running in the
system tray. It needs to be running whenever you want to host the vault.

> If the installer complains about virtualization, you need to enable it in your
> PC's BIOS. Search for your PC model plus "enable virtualization" — it's a
> one-time toggle, usually called VT-x, SVM, or "Intel Virtualization Technology".

## Step 2 — Install Git

Git downloads the campaign files and, later, backs up your notes.

1. Go to <https://git-scm.com/download/win> and run the installer.
2. Click Next through every screen. The defaults are all fine.

## Step 3 — Download the campaign files

Open PowerShell (Step 0 tells you how) in whichever folder you want the campaign
to live in — `Documents` is a sensible choice — and run:

```powershell
git clone https://github.com/Fraser-A-N-Smith/Danakova.git
cd Danakova
```

The first time, a GitHub login window pops up. Sign in and it'll remember you.

> Prefer downloading the ZIP from GitHub instead? Then Windows marks the scripts
> as "from the internet" and refuses to run them. Fix it once by running
> `Get-ChildItem *.ps1 | Unblock-File` in that folder. Cloning avoids this
> entirely, which is why it's the recommended route.

## Step 4 — Run the setup script

Still in PowerShell, in the `Danakova` folder:

```powershell
.\first-time-setup.ps1
```

This checks Docker is running, invents a password for your group, and downloads
the server (a few hundred MB — this is the slow part). It prints your password
when it's done.

**Write that password down.** It's stored in a file called `.env` which is
deliberately never uploaded to GitHub, so it exists only on this PC.

The script is safe to run again if something goes wrong; it won't overwrite a
password you already have.

## Step 5 — Start it

```powershell
.\start-campaign.ps1
```

After about ten seconds it prints something like:

```
=== Send this to your players ===
  Link:     https://wealth-soil-becomes-improvement.trycloudflare.com
  Password: marrow-cairn-hearth-221
```

It also copies both to your clipboard, so you can paste straight into Discord.

## Step 6 — Get your players in

Send them the link and the password. On their end there's nothing to install:

1. Click the link.
2. Type the password and click **Join session**.
3. Start editing.

They stay signed in for 30 days, so this is a once-a-month annoyance at worst.

Point them at the **Start Here** note in the vault — it explains the folders and
how `[[links]]` work.

## Step 7 — Check it actually works

Open the link yourself in a second browser window, sign in, and type into a note
while watching the first window. Text should appear in both, live. If it does,
you're finished.

---

# Part 2 — Everyday use

## Before a session

1. Make sure Docker Desktop is running (green "Engine running").
2. `.\start-campaign.ps1`
3. Paste the link and password into Discord.

**The link changes every single time you start it.** The password never does.
This is the one genuinely annoying part of the free setup — a permanent web
address would need a Cloudflare account and a domain name you pay for.

## After a session — back up

```powershell
git add -A
git commit -m "Session 4"
git push
```

Do this every session. It's your undo button — see [Backups](#backups).

## When you're done

```powershell
.\stop-campaign.ps1
```

Stopping loses nothing. Your notes are plain files sitting in the `vault` folder
either way.

## The scripts, in one table

| Script | What it does |
| --- | --- |
| `first-time-setup.ps1` | One-time. Creates your password, downloads the server. |
| `start-campaign.ps1` | Starts the vault, prints and copies the share link. |
| `stop-campaign.ps1` | Shuts it down. Notes untouched. |
| `sync-obsidian-edits.ps1` | Only if you edited in Obsidian — see Part 3. |

## Troubleshooting

| What you see | What to do |
| --- | --- |
| "Docker is not installed" | Do Step 1. |
| "Docker is installed but not running" | Open Docker Desktop, wait for "Engine running", retry. |
| "No .env found" | You skipped Step 4. Run `.\first-time-setup.ps1`. |
| "running scripts is disabled on this system" | You downloaded the ZIP. Run `Get-ChildItem *.ps1 \| Unblock-File`. |
| Tunnel URL didn't appear | `.\stop-campaign.ps1` then `.\start-campaign.ps1`. |
| Players see an old version of a note | You edited in Obsidian. Run `.\sync-obsidian-edits.ps1`. |
| Players can't connect at all | Your PC is asleep, Docker stopped, or you sent them a link from a previous run. |

---

# Part 3 — Reference

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
for this vault, and use Obsidian for reading, Graph View, and plugins. Your
personal `Notes Vault` is unaffected — this only concerns the campaign vault.

The browser editor is not a downgrade for note-taking: wiki-links, backlinks,
outline, quick switcher, global search, live preview, diagrams, anchored comments,
presence and chat are all there.

## Other things to know

- **Your PC is the server.** Players can only reach the vault while this machine
  is awake and the containers are running.
- **The share link changes every restart of the tunnel.** The password does not.
  `sync-obsidian-edits.ps1` restarts only CollabMD, so it leaves the link intact.
- **There is no per-user permission model.** Anyone with the link and password can
  read and edit every file in `vault/`. Keep DM-only material in a different vault.
- **Git history is your undo.** CRDT merging stops people clobbering each other's
  typing; it does not stop someone deleting a note. Commit regularly.

## Does shutting down lose data? No — tested

`docker compose down` was run with both containers fully removed. All notes and
CollabMD's CRDT state were still on disk afterwards, unchanged.

Nothing lives inside the containers. `docker compose config --volumes` returns
empty — there are no named volumes. The only mount is a bind mount of `.\vault`
to `/data`, so every write goes straight to your Windows disk:

- `vault/**/*.md` — the notes themselves
- `vault/.collabmd/yjs/` — per-file CRDT state, so in-progress collaborative
  edits are restored rather than reset
- `vault/.collabmd/comments/` — anchored comment threads (tracked in git)

The containers are disposable; `docker compose down` then `up` rebuilds them from
the image and re-reads everything from disk.

Two things that *are* lost on shutdown, neither of them content:

- **The tunnel URL.** `down` kills cloudflared, so the next start gets a new
  random `trycloudflare.com` address.
- **The last instant of unsaved typing**, if you kill the server mid-keystroke.
  Same exposure as any editor.

Player logins survive, because `AUTH_SESSION_SECRET` is pinned in `.env`.

## Backups

The vault is pushed to `https://github.com/Fraser-A-N-Smith/Danakova.git`
(private) on branch `main`. This is the campaign's undo button: CRDT merging stops
players clobbering each other's typing, but it does not protect against someone
deleting a note.

What is and isn't backed up:

- **Backed up** — every note, plus `vault/.collabmd/comments/` (anchored comment
  threads are things people wrote, so they belong in history)
- **Not backed up** — `.env`, and CollabMD's regenerable runtime state
  (`yjs/` binary CRDT blobs, sqlite metadata, pull-backups)

`.env` is gitignored deliberately: it holds the shared password and the session
signing key. If you ever set this up on a second machine, copy that file across by
hand rather than committing it — otherwise the new machine invents a different
password and everyone gets signed out.

## A note on the scripts

None of the `.ps1` files set `$ErrorActionPreference = "Stop"`. That's deliberate,
not an oversight. In Windows PowerShell 5.1, redirecting a native program's stderr
turns every line into an error record, so `docker compose` writing routine progress
to stderr would abort the script. The scripts check `$LASTEXITCODE` instead, and
route stderr through `cmd /c` where it needs capturing.

## Verified working on this machine

- CollabMD v0.1.49 healthy, vault mounted, backlinks index resolving
- Password auth: correct password `200`, wrong password `401`, unauthenticated API `401`
- Cloudflare Quick Tunnel reachable from the public internet and gated by that password
- All four scripts run start to finish: setup on a clean copy, then start, sync, stop
- `first-time-setup.ps1` generates a BOM-free `.env` that `docker compose` parses,
  and refuses to overwrite an existing one
- `start-campaign.ps1` exits cleanly with a clear message when `.env` is missing
- `sync-obsidian-edits.ps1` picks up externally-created files and preserves the
  share link
