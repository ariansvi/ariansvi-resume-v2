from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, String, Text

from app.database import Base


class PageVisit(Base):
    __tablename__ = "page_visits"

    id = Column(Integer, primary_key=True, index=True)
    path = Column(String(512), nullable=False, index=True)
    referrer = Column(String(1024), nullable=True)
    user_agent = Column(String(512), nullable=True)
    ip_address = Column(String(45), nullable=True)
    country = Column(String(2), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)


class ContactMessage(Base):
    __tablename__ = "contact_messages"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
