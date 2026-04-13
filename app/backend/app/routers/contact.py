import logging

from fastapi import APIRouter, HTTPException
from google.cloud import firestore
from pydantic import BaseModel, EmailStr

from app.database import get_client

router = APIRouter(prefix="/contact", tags=["contact"])
logger = logging.getLogger(__name__)

COLLECTION = "contact_messages"


class ContactCreate(BaseModel):
    name: str
    email: EmailStr
    message: str


class ContactResponse(BaseModel):
    status: str
    message: str


@router.post("/", response_model=ContactResponse)
def submit_contact(contact: ContactCreate):
    if len(contact.message) < 10:
        raise HTTPException(
            status_code=400,
            detail="Message must be at least 10 characters",
        )

    try:
        get_client().collection(COLLECTION).add(
            {
                "name": contact.name,
                "email": contact.email,
                "message": contact.message,
                "created_at": firestore.SERVER_TIMESTAMP,
            }
        )
    except Exception:
        logger.exception("Failed to store contact message")
        raise HTTPException(status_code=500, detail="Failed to send message")

    logger.info("Contact form submitted by %s <%s>", contact.name, contact.email)
    return ContactResponse(
        status="success",
        message="Thank you for reaching out! I'll get back to you soon.",
    )
