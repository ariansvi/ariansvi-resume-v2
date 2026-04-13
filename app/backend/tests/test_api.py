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
        r = client.get("/api/health")
        assert r.status_code == 200
        assert r.json()["status"] == "healthy"

    def test_ready(self):
        r = client.get("/api/ready")
        assert r.status_code == 200
        assert r.json()["status"] == "ready"

    def test_info(self):
        r = client.get("/api/info")
        assert r.status_code == 200
        data = r.json()
        assert "uptime_seconds" in data
        assert "python_version" in data
