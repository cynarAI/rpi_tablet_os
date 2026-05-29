# RPi Tablet OS — Sprint Board

Lightweight, version-controlled board (GitHub Project board requires a token
scope we don't have). Move issues between columns by editing this file in the
PR that does the work. One sprint ≈ one focused PR.

**Workflow**
1. Pick the top item from **To Do** of the active sprint.
2. Branch off `master`: `git checkout -b fix/<issue>-<slug>`.
3. Implement + verify; reference `Closes #<n>` in the PR description.
4. Move the card here from **To Do** → **In Progress** → **Review** → **Done**.
5. Work happens on the `cynarAI/rpi_tablet_os` fork; PRs target `tobykurien:master`.

---

## Board

| Backlog | To Do (Sprint 1) | In Progress | Review | Done |
|---|---|---|---|---|
| #3 #4 (Sprint 2) | — | — | #8 #9 #10 #11 #12 | — |
| #6 #7 (Sprint 3) | | | | |
| #5 (Sprint 4) | | | | |

---

## Sprints

### Sprint 1 — Harden the installer (bugs) — *IN REVIEW*
**Goal:** the one-shot installer and helper scripts run without obvious footguns.
- [x] #8 — `rm -rf rpi_tablet_os` → clone into a `mktemp -d` workdir
- [x] #9 — `dpkg -i install …` → `dpkg -i …` (stray `install` word)
- [x] #10 — Firefox: drop obsolete Ubuntu FTP URL, install from RPi OS repos
- [x] #11 — Firefox: remove hardcoded `18.04.2_armhf.deb` version
- [x] #12 — Firefox: fix inverted `if [ -e ]` "not found" check (now apt-based)

### Sprint 2 — Debian trixie compatibility + docs
**Goal:** clean install on current Raspberry Pi OS (Debian trixie/bookworm).
- [ ] #3 — Replace removed packages (`libgles2-mesa`, `libqt4-dev`) with current
      equivalents; handle touchegg multiarch; make apt step resilient.
- [ ] #4 — README: troubleshooting section (touchegg multiarch, force-install).

### Sprint 3 — Tablet UX enhancements
**Goal:** nicer out-of-the-box tablet experience.
- [ ] #6 — Improve onboard on-screen keyboard config for tablet UI.
- [ ] #7 — Software screen-brightness control.

### Sprint 4 — Quality & testing
**Goal:** prevent regressions in the gesture/install setup.
- [ ] #5 — Automated tests for touch-gesture configuration.

---

## Definition of Done
- Code/script change committed on a feature branch and merged via PR.
- PR references and closes the issue.
- Scripts pass `sh -n` (syntax) and a manual smoke check where feasible.
- Board updated (card moved to **Done**).
