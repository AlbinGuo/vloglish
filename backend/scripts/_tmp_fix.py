p = 'app/routers/membership.py'
s = open(p, encoding='utf-8').read()
old = '''        "test": True,
    }

    body: AppleVerifyIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """校验 Apple 内购收据/交易并开通、续期会员。"""
'''
new = '''        "test": True,
    }


@router.post("/apple/verify/")
def verify_apple_purchase(
    body: AppleVerifyIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """校验 Apple 内购收据/交易并开通、续期会员。"""
'''
assert old in s, "needle not found"
s = s.replace(old, new, 1)
open(p, 'w', encoding='utf-8').write(s)
print("done")
'''
