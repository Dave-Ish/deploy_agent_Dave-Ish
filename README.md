# deploy_agent_Dave-Ish

A shell script (`deploy_agent.sh`) that deploys, runs, and archives the logs of the Student Attendance Tracker, a Python application. It also handles Ctrl+C and Ctrl+Z cleanly while a deployment is in progress.

> **Note:** This is an example README. Edit every section so it matches what *your* script actually does (menu wording, validation rules, copy vs move, and so on).

## Requirements

- Linux or macOS with Bash
- `python3`
- `zip`

## Repository Structure

```
deploy_agent_YourUsername/
├── deploy_agent.sh
├── README.md
├── .gitignore
└── templates/
    ├── attendance_checker.py
    ├── assets.csv
    └── config.json
```

`templates/` holds the three original source files. They are never modified. The script copies them into each new project.

## How to Run

1. Make the script executable:
   ```
   chmod +x deploy_agent.sh
   ```
2. Start it:
   ```
   ./deploy_agent.sh
   ```
3. Choose a feature from the menu:
   ```
   1) Deploy the application
   2) Run the application
   3) Archive the logs
   4) Quit
   ```

## Features

### 1. Deploy

Choosing option 1 does the following, in order:

1. **Pre-flight checks:** confirms `python3` and `zip` are installed (and prints `python3 --version`). If either is missing, the script stops with a clear message before creating anything.
2. **Project name:** asks for a name and creates `attendance_tracker_<name>/`. Empty names and names with spaces or slashes are rejected. If the directory already exists, the script asks whether to overwrite it or abort.
3. **Structure:** creates `Helpers/` and `reports/` inside the project.
4. **Files:** copies `attendance_checker.py` into the project root and `config.json` into `Helpers/`.
5. **Roster:** asks how to build `Helpers/assets.csv`:
   - **Option A (copy):** asks how many students (1 to 10) and copies that many rows plus the header from `templates/assets.csv`.
   - **Option B (generate):** asks how many students and builds that many rows from sample name and email arrays in the script, with both counts starting at 0.
6. **Permissions:** makes `attendance_checker.py` executable (`chmod +x`) and restricts `Helpers/config.json` to owner read/write (`chmod 600`), then prints the result.
7. **Thresholds:** offers to update the alert thresholds (see below).
8. **Verification:** finishes by launching the application (Feature 2) to confirm everything works together.

### 2. Run

Choosing option 2 asks which project to run, checks that it exists, then runs `python3 attendance_checker.py` from inside the project folder. The app is interactive: the instructor marks each student present or absent. The app updates `Helpers/assets.csv` and writes its logs into `reports/`.

### 3. Archive Logs

Choosing option 3 archives the logs created by the last run:

- `reports/attendance.log` goes to `archives/attendance/attendance_YYYYMMDD_HHMMSS.log`
- `reports/absent.log` goes to `archives/absent/absent_YYYYMMDD_HHMMSS.log`

Details:

- A single timestamp is generated per archive run, so both files from the same run share the same timestamp and every archive is unique.
- The archive folders are created if they do not exist.
- If a log file does not exist (for example, nobody was absent so there is no `absent.log`), the script prints a note and continues without crashing.
- The script prints which logs were archived and their final paths.
- Logs are **copied** (or **moved**; state which one you chose and why).

## Threshold Update

During deployment the script asks whether to update the alert thresholds in `Helpers/config.json`.

- If you answer yes, it asks for a **warning** value (default 75) and a **failure** value (default 50). Pressing Enter keeps the default.
- Each value is validated before use: it must be numeric and between 0 and 100. Invalid input is rejected and asked again.
- `sed -i` then edits only the `"warning": <number>` and `"failure": <number>` lines. The rest of the file is not reformatted or reordered.
- The changed lines are printed so you can see the result.

## total_sessions and the Roster

`total_sessions` in `config.json` is the total number of sessions **including today's**, so it must always be one more than the prior sessions recorded in the roster.

| Roster option | Prior sessions per student | `total_sessions` |
|---|---|---|
| A (copied from template) | 4 | 5 |
| B (generated fresh) | 0 | 1 |

The script sets this automatically, so no extra prompt is needed.

## Interrupt Handling (Ctrl+C and Ctrl+Z)

While a deployment is in progress, the script traps `SIGINT` (Ctrl+C) and `SIGTSTP` (Ctrl+Z). When either is received, it:

1. Prints a message that the deployment was interrupted.
2. Zips whatever exists of `attendance_tracker_<name>/` into `attendance_tracker_<name>_archive.zip`.
3. Deletes the incomplete project directory, so no half-made folder is left behind.
4. Exits cleanly.

The trap is removed before the verification run and after deployment finishes, so it never affects the marking session in `attendance_checker.py`.

### How to test it

1. Start a deployment (option 1).
2. Press **Ctrl+C** (or **Ctrl+Z**) partway through, for example at a prompt.
3. Check that:
   - `attendance_tracker_<name>_archive.zip` exists
   - `unzip -l attendance_tracker_<name>_archive.zip` lists the files that had been created so far
   - the `attendance_tracker_<name>/` directory is gone

The zip contains the partial project: whatever folders and files existed at the moment of the interrupt (for example `Helpers/`, `reports/`, and any files already copied).

## How I Tested the Deployed Structure

- Ran `ls -R attendance_tracker_<name>` and compared it with the required structure (`attendance_checker.py`, `Helpers/assets.csv`, `Helpers/config.json`, `reports/`).
- Ran `ls -l` to confirm `attendance_checker.py` is executable and `config.json` shows `-rw-------`.
- Checked the number of rows in `assets.csv` against the number of students entered, for both Option A and Option B.
- Checked `total_sessions` in `config.json` (5 for Option A, 1 for Option B).
- Tried invalid threshold input (empty, letters, values over 100) to confirm validation works.
- Ran a marking session, then archived and confirmed the timestamped files appeared in the right folders, with and without an `absent.log`.

## Video Walkthrough

[Link to your video here]
