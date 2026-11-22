#!/usr/bin/env python3
"""Tests for bin/ccs. Run: python3 tests/test_ccs.py"""
import importlib.machinery
import importlib.util
import json
import os
import sys
import tempfile
import types
import unittest

sys.dont_write_bytecode = True  # keep bin/ free of __pycache__
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(claude_dir, state_dir):
    os.environ["CCS_CLAUDE_DIR"] = claude_dir
    os.environ["CCS_STATE_DIR"] = state_dir
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
            f.write("home\n")
        self.ccs = load(self.claude, self.state)

    def tearDown(self):
        self.tmp.cleanup()

    def session(self, pid, sid, cwd, name="n", kind="interactive"):
        with open(os.path.join(self.claude, "sessions", "%d.json" % pid), "w") as f:
            json.dump({"pid": pid, "sessionId": sid, "cwd": cwd, "name": name, "kind": kind}, f)

    def save(self, **kw):
        args = types.SimpleNamespace(label=None, quiet=True)
        args.__dict__.update(kw)
        self.ccs.cmd_save(args)

    def test_names(self):
        self.assertEqual(self.ccs.expected_name("/w/rtw-progress"), "rtw-progress_home")
        self.assertEqual(self.ccs.expected_name("/w/rtw-progress", True), "rtw-progress_home_rev")
        self.assertEqual(self.ccs.expected_name("/w/rtw-progress-wt-review/"), "rtw-progress_home_rev")

    def test_extra_flags(self):
        f = self.ccs.extra_flags
        self.assertEqual(f("claude --resume"), [])
        self.assertEqual(f("claude -r abc -n name --add-dir '/x y'"), ["--add-dir", "/x y"])
        self.assertEqual(f("claude --continue --model opus"), ["--model", "opus"])
        self.assertEqual(f("claude --resume --model opus"), ["--model", "opus"])

    def test_only_live_interactive_sessions_are_saved(self):
        me = os.getpid()
        self.session(me, "live", self.tmp.name)
        self.session(999999, "dead", self.tmp.name)
        self.session(os.getppid(), "headless", self.tmp.name, kind="sdk")
        self.save()
        files = self.ccs.snapshot_files()
        self.assertEqual(len(files), 1)
        self.assertEqual([s["sessionId"] for s in self.ccs.load_snapshot(files[0])["sessions"]], ["live"])

    def test_unchanged_sessions_are_not_saved_twice_unless_labelled(self):
        self.session(os.getpid(), "live", self.tmp.name)
        self.save()
        self.save()
        self.assertEqual(len(self.ccs.snapshot_files()), 1)

    def test_nothing_running_saves_nothing(self):
        self.save()
        self.assertEqual(self.ccs.snapshot_files(), [])

    def test_restore_prefers_the_newest_snapshot_before_the_last_restart(self):
        os.makedirs(self.ccs.SNAP_DIR)
        for name, taken in (("a", 100), ("b", 200), ("c", 300)):
            with open(os.path.join(self.ccs.SNAP_DIR, name + ".json"), "w") as f:
                json.dump({"taken": taken, "sessions": []}, f)
        self.ccs.boot_time = lambda: 250
        self.assertTrue(self.ccs.pick_snapshot(None).endswith("b.json"))
        self.ccs.boot_time = lambda: 50
        self.assertTrue(self.ccs.pick_snapshot(None).endswith("c.json"))
        self.assertTrue(self.ccs.pick_snapshot("3").endswith("a.json"))


if __name__ == "__main__":
    unittest.main()
