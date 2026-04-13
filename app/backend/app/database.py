"""Firestore client factory.

Firestore replaces the previous SQLAlchemy/SQLite setup. Collections:
  - page_visits: one doc per recorded pageview
  - contact_messages: one doc per contact form submission
"""

from functools import lru_cache

from google.cloud import firestore

from app.config import settings


@lru_cache(maxsize=1)
def get_client() -> firestore.Client:
    """Return a cached Firestore client.

    When GCP_PROJECT_ID is empty (local dev without GCP creds), the client
    will fall back to whatever ADC is configured or the emulator.
    """
    if settings.GCP_PROJECT_ID:
        return firestore.Client(project=settings.GCP_PROJECT_ID)
    return firestore.Client()


def init_db() -> None:
    """No-op for Firestore — kept for compatibility with startup hook."""
    return None
