import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import ContactMessage

router = APIRouter(prefix="/contact", tags=["contact"])
logger = logging.getLogger(__name__)


class ContactCreate(BaseModel):
    name: str
    email: EmailStr
    message: str


class ContactResponse(BaseModel):
    status: str
    message: str


@router.post("/", response_model=ContactResponse)
def submit_contact(
    contact: ContactCreate,
    db: Session = Depends(get_db),
):
    if len(contact.message) < 10:
        raise HTTPException(
            status_code=400,
            detail="Message must be at least 10 characters",
        )

    db_message = ContactMessage(
        name=contact.name,
        email=contact.email,
        message=contact.message,
    )
    db.add(db_message)
    db.commit()

    logger.info("Contact form submitted by %s <%s>", contact.name, contact.email)

    return ContactResponse(
        status="success",
        message="Thank you for reaching out! I'll get back to you soon.",
    )
