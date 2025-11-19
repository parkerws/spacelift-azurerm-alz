"""Initialize Database"""

import logging
from sqlalchemy.orm import Session

from app.core.database import Base, engine
from app.models.user import User, UserRole
from app.models.landing_zone import LandingZone
from app.core.auth import get_password_hash

logger = logging.getLogger(__name__)


def init_db(db: Session) -> None:
    """
    Initialize database with tables and seed data.
    """
    # Create all tables
    logger.info("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created successfully")

    # Check if admin user exists
    admin = db.query(User).filter(User.email == "admin@example.com").first()

    if not admin:
        logger.info("Creating default admin user...")
        admin = User(
            email="admin@example.com",
            username="admin",
            hashed_password=get_password_hash("admin123"),
            full_name="Administrator",
            department="Platform Team",
            role=UserRole.ADMIN,
            is_active=True,
            is_verified=True,
        )
        db.add(admin)
        db.commit()
        logger.info("Default admin user created: admin@example.com / admin123")

    # Check if approver user exists
    approver = db.query(User).filter(User.email == "approver@example.com").first()

    if not approver:
        logger.info("Creating default approver user...")
        approver = User(
            email="approver@example.com",
            username="approver",
            hashed_password=get_password_hash("approver123"),
            full_name="Approver User",
            department="Platform Team",
            role=UserRole.APPROVER,
            is_active=True,
            is_verified=True,
        )
        db.add(approver)
        db.commit()
        logger.info("Default approver user created: approver@example.com / approver123")

    # Check if regular user exists
    user = db.query(User).filter(User.email == "user@example.com").first()

    if not user:
        logger.info("Creating default regular user...")
        user = User(
            email="user@example.com",
            username="user",
            hashed_password=get_password_hash("user123"),
            full_name="Regular User",
            department="Application Team",
            role=UserRole.USER,
            is_active=True,
            is_verified=True,
        )
        db.add(user)
        db.commit()
        logger.info("Default regular user created: user@example.com / user123")

    logger.info("Database initialization completed")


if __name__ == "__main__":
    from app.core.database import SessionLocal

    logging.basicConfig(level=logging.INFO)

    db = SessionLocal()
    try:
        init_db(db)
    finally:
        db.close()
