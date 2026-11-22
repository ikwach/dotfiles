#!/usr/bin/env python3
"""Tests for bin/ccs. Run: python3 tests/test_ccs.py"""
import importlib.machinery
import importlib.util
import json
import os
import sys
import tempfile
import time
import types
import unittest

sys.dont_write_bytecode = True  # keep bin/ free of __pycache__
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(claude_dir, state_dir):
    os.environ["CCS_CLAUDE_DIR"] = claude_dir
    os.environ["CCS_STATE_DIR"] = state_dir
    os.environ.pop("CCS_TEST_COMMAND", None)
    loader = importlib.machinery.SourceFileLoader("ccs", os.path.join(ROOT, "bin", "ccs"))
    spec = importlib.util.spec_from_loader("ccs", loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class CcsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.claude = os.path.join(self.tmp.name, "claude")
        self.state = os.path.join(self.tmp.name, "state")
        os.makedirs(os.path.join(self.claude, "sessions"))
        with open(os.path.join(self.claude, "machine-tag"), "w") as f:
            f.write("desk\n")
        self.ccs = load(self.claude, self.state)
        self.ccs.boot_time = lambda: 1000  # long before any session below started

    def tearDown(self):
        self.tmp.cleanup()

    def session(self, pid, sid, cwd=None, name="n", kind="interactive", started=None):
        record = {
            "pid": pid,
            "sessionId": sid,
            "cwd": cwd or self.tmp.name,
            "name": name,
            "kind": kind,
            "startedAt": int(time.time() * 1000) if started is None else started,
        }
        with open(os.path.join(self.claude, "sessions", "%d.json" % pid), "w") as f:
            json.dump(record, f)

    def save(self, label=None):
        self.ccs.cmd_save(types.SimpleNamespace(label=label, quiet=True))

    def saved_ids(self):
        return [[s["sessionId"] for s in snap["sessions"]] for _, snap in self.ccs.good_snapshots()]

    def snapshot(self, name, taken, sessions=()):
        os.makedirs(self.ccs.SNAP_DIR, exist_ok=True)
        with open(os.path.join(self.ccs.SNAP_DIR, name + ".json"), "w") as f:
            json.dump({"taken": taken, "sessions": list(sessions)}, f)

    # --- names

    def test_names(self):
        self.assertEqual(self.ccs.expected_name("/w/project"), "project_desk")
        self.assertEqual(self.ccs.expected_name("/w/project", True), "project_desk_rev")
        self.assertEqual(self.ccs.expected_name("/w/project-wt-review/"), "project_desk_rev")

    # --- save

    def test_only_live_interactive_sessions_are_saved(self):
        self.session(os.getpid(), "live")
        self.session(999999, "dead")
        self.session(os.getppid(), "headless", kind="sdk")
        self.save()
        self.assertEqual(self.saved_ids(), [["live"]])

    def test_a_session_file_from_before_the_restart_is_ignored_even_if_its_pid_is_alive(self):
        self.ccs.boot_time = lambda: 2_000_000
        self.session(os.getpid(), "leftover", started=1_000_000 * 1000)
        self.save()
        self.assertEqual(self.saved_ids(), [])

    def test_unchanged_sessions_are_saved_once_but_a_label_always_saves(self):
        self.session(os.getpid(), "live")
        self.save()
        self.save()
        self.assertEqual(len(self.saved_ids()), 1)
        self.save(label="pre-update")
        self.assertEqual(len(self.saved_ids()), 2)

    def test_two_saves_in_the_same_second_get_different_files(self):
        self.session(os.getpid(), "live")
        self.save(label="a")
        self.save(label="a")
        self.assertEqual(len(self.ccs.snapshot_files()), 2)

    def test_nothing_running_saves_nothing(self):
        self.save()
        self.assertEqual(self.ccs.snapshot_files(), [])

    def test_a_snapshot_never_records_how_the_session_was_started(self):
        self.session(os.getpid(), "live")
        self.save()
        saved = self.ccs.good_snapshots()[0][1]["sessions"][0]
        self.assertEqual(sorted(saved), ["cwd", "name", "sessionId"])

    # --- choosing a snapshot

    def test_restore_prefers_the_newest_snapshot_before_the_last_restart(self):
        for name, taken in (("a", 100), ("b", 200), ("c", 300)):
            self.snapshot(name, taken)
        self.ccs.boot_time = lambda: 250
        self.assertTrue(self.ccs.pick_snapshot(None).endswith("b.json"))
        self.ccs.boot_time = lambda: 50
        self.assertTrue(self.ccs.pick_snapshot(None).endswith("c.json"))
        self.assertTrue(self.ccs.pick_snapshot("3").endswith("a.json"))

    def test_an_unreadable_snapshot_is_skipped(self):
        self.snapshot("a", 100)
        with open(os.path.join(self.ccs.SNAP_DIR, "b.json"), "w") as f:
            f.write('{"taken": 200, "sess')
        with open(os.path.join(self.ccs.SNAP_DIR, "c.json"), "w") as f:
            f.write("[]")
        self.ccs.boot_time = lambda: 50
        self.assertTrue(self.ccs.pick_snapshot(None).endswith("a.json"))
        self.assertEqual(len(self.ccs.good_snapshots()), 1)
        self.ccs.cmd_snapshots(None)  # must not raise

    # --- restore

    def test_restore_skips_running_sessions_missing_folders_and_backslashes(self):
        here = self.tmp.name
        odd = os.path.join(here, "a\\b")
        os.mkdir(odd)
        sessions = [
            {"name": "open-me", "sessionId": "1", "cwd": here},
            {"name": "running", "sessionId": "2", "cwd": here},
            {"name": "gone", "sessionId": "3", "cwd": os.path.join(here, "missing")},
            {"name": "odd", "sessionId": "4", "cwd": odd},
        ]
        todo, skipped = self.ccs.plan_restore(sessions, {"2"})
        self.assertEqual([s["name"] for s in todo], ["open-me"])
        self.assertEqual(len(skipped), 3)
        todo, _ = self.ccs.plan_restore(sessions, set(), only="runn")
        self.assertEqual([s["name"] for s in todo], ["running"])

    def test_the_restore_command_resumes_by_id_and_nothing_else(self):
        session = {"name": "x", "sessionId": "abc-123", "cwd": "/w/my project", "flags": ["fix", "the", "bug"]}
        self.assertEqual(self.ccs.session_command(session), "claude --resume abc-123")
        os.environ["SHELL"] = "/bin/zsh"
        shell, flag, inner = self.ccs.in_login_shell(session)
        self.assertEqual((shell, flag), ("/bin/zsh", "-lic"))
        self.assertEqual(inner, "cd '/w/my project' && claude --resume abc-123; exec /bin/zsh -l")


if __name__ == "__main__":
    unittest.main()
