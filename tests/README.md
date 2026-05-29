# Tests

Static checks that run without touch hardware. Run them all with:

```sh
sh tests/run.sh
```

To run them automatically on every push and pull request, add a GitHub Actions
workflow at `.github/workflows/tests.yml`:

```yaml
name: tests
on: [push, pull_request]
jobs:
  static-checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.x"
      - run: sh tests/run.sh
```

## What is covered

- **`test_gesture_config.py`** — parses the shipped
  `fs/home/pi/.config/touchegg/touchegg.conf` and asserts it is well-formed XML
  and that every gesture documented in the README is present and mapped to the
  expected action (right-click, maximize/minimize, fullscreen, tab/app
  switching, close window). This keeps the gesture config and the docs from
  drifting apart. Uses only the Python standard library.
- **shell syntax** — `sh -n` on the shipped shell scripts (`install.sh`,
  `touchegg.sh`, `firefox_install.sh`, `brightness.sh`).

## What is *not* covered, and why

Actually *simulating* multi-touch gestures (e.g. via `xdotool` or
`libinput test`) needs a running X session and a real (or emulated) touch
device, which isn't reproducible in CI. Those end-to-end checks remain a manual,
on-device step. The static suite catches the failure mode that actually occurs
in practice: a malformed or incomplete `touchegg.conf`.
