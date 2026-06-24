"""Quick smoke test for DeepSeek lookup. Run: python scripts/test_deepseek_lookup.py"""
from app.dict.config import DEEPSEEK_API_KEY, DEEPSEEK_MODEL
from app.dict.deepseek import lookup_with_deepseek

if __name__ == "__main__":
    print("key configured:", bool(DEEPSEEK_API_KEY), "model:", DEEPSEEK_MODEL)
    result = lookup_with_deepseek(
        "capable",
        1,
        "you need to become the person that's capable of doing the things.",
        123,
    )
    print("headword:", result["headword"])
    print("definitions:", len(result["definitions"]))
    print("note:", result["definitions"][0].get("note", "")[:120])
