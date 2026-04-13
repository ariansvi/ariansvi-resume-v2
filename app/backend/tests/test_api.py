"""Smoke tests that don't require Firestore.

Analytics/contact tests were removed because they need a running Firestore
emulator. Bring them back by starting the emulator in CI and setting
FIRESTORE_EMULATOR_HOST; see README for details.
"""
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


class TestHealth:
    def test_health(self):
        # /api/health is intentionally minimal — used by Cloud Run probes,
        # exposed without the internal-token gate. Must not leak version
        # or environment.
        r = client.get("/api/health")
        assert r.status_code == 200
        assert r.json() == {"status": "ok"}

    def test_ready(self):
        r = client.get("/api/ready")
        assert r.status_code == 200
        assert r.json()["status"] == "ready"

    def test_info_removed(self):
        # /api/info was removed because it leaked Python and OS versions.
        r = client.get("/api/info")
        assert r.status_code == 404
