# actions/database.py
import re
import firebase_admin
from firebase_admin import credentials, firestore

# --- Khởi tạo Firebase ---
try:
    firebase_admin.get_app()
except ValueError:
    # Đảm bảo file json nằm đúng chỗ (thường là thư mục gốc của dự án)
    cred = credentials.Certificate("firebase-key.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

# --- Hàm tiện ích dùng chung ---
def parse_quantity(value: str) -> int:
    if not value:
        return 1
    text = str(value).lower().strip()
    m = re.search(r"\d+", text)
    if m:
        return int(m.group())
    mapping = {
        "một": 1, "mot": 1, "hai": 2, "ba": 3, "bốn": 4, "bon": 4,
        "năm": 5, "lam": 5, "lăm": 5, "sáu": 6, "sau": 6,
        "bảy": 7, "bay": 7, "tám": 8, "tam": 8,
        "chín": 9, "chin": 9, "mười": 10, "mấy": 2,
    }
    for word, num in mapping.items():
        if word in text:
            return num
    return 1