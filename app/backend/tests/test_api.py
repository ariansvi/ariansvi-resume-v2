import os

os.environ["DATABASE_URL"] = "sqlite:///./test.db"

from fastapi.testclient import TestClient

from app.database import Base, engine
from app.main import app

client = TestClient(app)


def setup_module():
    Base.metadata.create_all(bind=engine)


def teardown_module():
    Base.metadata.drop_all(bind=engine)
    if os.path.exists("./test.db"):
        os.remove("./test.db")


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


class TestAnalytics:
    def test_record_visit(self):
        r = client.post(
            "/api/analytics/visit",
            json={"path": "/", "referrer": "https://google.com"},
        )
        assert r.status_code == 201
        assert r.json()["status"] == "recorded"

    def test_get_stats(self):
        client.post("/api/analytics/visit", json={"path": "/"})
        client.post("/api/analytics/visit", json={"path": "/about"})

        r = client.get("/api/analytics/stats")
        assert r.status_code == 200
        data = r.json()
        assert data["total_visits"] >= 2
        assert data["unique_paths"] >= 1
        assert isinstance(data["top_pages"], list)


class TestContact:
    def test_submit_contact(self):
        r = client.post(
            "/api/contact/",
            json={
                "name": "Test User",
                "email": "test@example.com",
                "message": "Hello, this is a test message!",
            },
        )
        assert r.status_code == 200
        assert r.json()["status"] == "success"

    def test_short_message_rejected(self):
        r = client.post(
            "/api/contact/",
            json={
                "name": "Test",
                "email": "test@example.com",
                "message": "short",
            },
        )
        assert r.status_code == 400

    def test_invalid_email_rejected(self):
        r = client.post(
            "/api/contact/",
            json={
                "name": "Test",
                "email": "not-an-email",
                "message": "This is a valid length message",
            },
        )
        assert r.status_code == 422
