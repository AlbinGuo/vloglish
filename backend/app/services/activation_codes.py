import secrets

from sqlalchemy.orm import Session

from ..models import ActivationCode

CODE_LENGTH = 4
CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def generate_code() -> str:
    return "".join(secrets.choice(CODE_ALPHABET) for _ in range(CODE_LENGTH))


def generate_unique_codes(db: Session, count: int) -> list[str]:
    created: list[str] = []
    for _ in range(count):
        for _attempt in range(50):
            code = generate_code()
            exists = db.query(ActivationCode.id).filter(ActivationCode.code == code).first()
            if not exists and code not in created:
                db.add(ActivationCode(code=code))
                created.append(code)
                break
        else:
            raise RuntimeError("无法生成唯一激活码")
    db.commit()
    return created
