#!/usr/bin/env python3
"""Static validation of the shipped touchegg gesture configuration.

Real multi-touch gestures can only be exercised on hardware with a running X
session (the issue's xdotool / libinput-test idea), which is not reproducible in
CI. This suite instead guards the part that actually breaks in practice: the
`touchegg.conf` that ships in this repo. It checks that the file is well-formed
XML and that every gesture documented in the README is present and mapped to the
expected action, so the config and the docs can't silently drift apart.

Run via `tests/run.sh` or directly: `python3 tests/test_gesture_config.py`.
Exit code is non-zero if any check fails.
"""

import os
import sys
import xml.etree.ElementTree as ET

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONF = os.path.join(
    REPO_ROOT, "fs", "home", "pi", ".config", "touchegg", "touchegg.conf"
)

# (type, fingers, direction, action_type, {child_tag: expected_text})
# Mirrors the gestures documented in README.md "Usage".
EXPECTED = [
    ("TAP", "2", None, "MOUSE_CLICK", {"button": "3"}),
    ("SWIPE", "3", "UP", "MAXIMIZE_RESTORE_WINDOW", {}),
    ("SWIPE", "3", "DOWN", "MINIMIZE_WINDOW", {}),
    ("SWIPE", "3", "LEFT", "SEND_KEYS", {"modifiers": "Control_L", "keys": "Tab"}),
    ("SWIPE", "3", "RIGHT", "SEND_KEYS", {"modifiers": "Control_L+Shift_L", "keys": "Tab"}),
    ("PINCH", "3", "IN", "CLOSE_WINDOW", {}),
    ("TAP", "3", None, "SEND_KEYS", {"keys": "F11"}),
    ("SWIPE", "4", "LEFT", "SEND_KEYS", {"modifiers": "Alt_L+Shift_L", "keys": "Tab"}),
    ("SWIPE", "4", "RIGHT", "SEND_KEYS", {"modifiers": "Alt_L", "keys": "Tab"}),
]

passed = 0
failed = 0


def check(ok, msg):
    global passed, failed
    if ok:
        passed += 1
        print(f"  ok   - {msg}")
    else:
        failed += 1
        print(f"  FAIL - {msg}")


def describe(gtype, fingers, direction):
    d = f" {direction}" if direction else ""
    return f"{fingers}-finger {gtype}{d}"


def find_gesture(root, gtype, fingers, direction):
    for g in root.iter("gesture"):
        if g.get("type") != gtype or g.get("fingers") != fingers:
            continue
        if direction is not None and g.get("direction") != direction:
            continue
        if direction is None and g.get("direction") is not None:
            continue
        return g
    return None


def main():
    print(f"touchegg config: {CONF}")
    if not os.path.isfile(CONF):
        print(f"  FAIL - config file not found")
        return 1

    try:
        tree = ET.parse(CONF)
    except ET.ParseError as exc:
        print(f"  FAIL - config is not well-formed XML: {exc}")
        return 1
    print("  ok   - config is well-formed XML")

    root = tree.getroot()

    for gtype, fingers, direction, action_type, children in EXPECTED:
        label = describe(gtype, fingers, direction)
        g = find_gesture(root, gtype, fingers, direction)
        if g is None:
            check(False, f"{label}: gesture is defined")
            continue
        check(True, f"{label}: gesture is defined")

        action = g.find("action")
        check(
            action is not None and action.get("type") == action_type,
            f"{label}: action is {action_type}",
        )
        if action is None:
            continue
        for tag, want in children.items():
            el = action.find(tag)
            got = el.text if el is not None else None
            check(got == want, f"{label}: <{tag}> is {want!r} (got {got!r})")

    print(f"\n{passed} passed, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
