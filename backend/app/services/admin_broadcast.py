from sqlalchemy.orm import Session

from ..models import AdminBroadcast, User, UserNotification


def broadcast_notification_to_all_users(
    db: Session,
    *,
    admin: User,
    title: str,
    body: str,
    image_url: str = "",
) -> AdminBroadcast:
    title = title.strip()
    body = body.strip()
    image_url = (image_url or "").strip()
    broadcast = AdminBroadcast(
        title=title,
        body=body,
        image_url=image_url,
        created_by_user_id=admin.id,
        recipient_count=0,
    )
    db.add(broadcast)
    db.flush()

    users = db.query(User).filter(User.is_active.is_(True)).all()
    if users:
        db.add_all(
            [
                UserNotification(
                    user_id=user.id,
                    type="admin_broadcast",
                    title=title,
                    body=body,
                    image_url=image_url,
                    broadcast_id=broadcast.id,
                )
                for user in users
            ]
        )
    broadcast.recipient_count = len(users)
    db.commit()
    db.refresh(broadcast)
    return broadcast
