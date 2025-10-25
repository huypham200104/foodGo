import re
import firebase_admin
from firebase_admin import credentials, firestore
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from typing import Any, Text, Dict, List

# --- Khởi tạo Firebase (chỉ một lần) ---
try:
    firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate("firebase-key.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()


# ============================================================
#  Hàm chuyển đổi chữ số tiếng Việt sang int
# ============================================================
def parse_quantity(value: str) -> int:
    if not value:
        return 1

    text = str(value).lower().strip()

    # Nếu có số trong chuỗi → dùng số
    m = re.search(r"\d+", text)
    if m:
        return int(m.group())

    # Bảng ánh xạ chữ số Việt
    mapping = {
        "một": 1, "mot": 1,
        "hai": 2, "ba": 3, "bốn": 4, "bon": 4,
        "năm": 5, "lam": 5, "lăm": 5,
        "sáu": 6, "sau": 6,
        "bảy": 7, "bay": 7,
        "tám": 8, "tam": 8,
        "chín": 9, "chin": 9,
        "mười": 10,
        "mấy": 2,  # fallback nhẹ
    }

    for word, num in mapping.items():
        if word in text:
            return num

    return 1  # mặc định 1 nếu không nhận diện được


# ============================================================
# 1️⃣ HIỂN THỊ MENU
# ============================================================
class ActionShowMenu(Action):
    def name(self) -> Text:
        return "action_show_menu"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        try:
            menu_ref = db.collection("menu")
            docs = menu_ref.stream()

            menu_items = []
            for doc in docs:
                data = doc.to_dict()
                name = data.get("name", "Không rõ")
                price = data.get("price", "N/A")

                menu_items.append({"name": name, "price": price})

            if not menu_items:
                dispatcher.utter_message(
                    json_message={
                        "type": "menu",
                        "status": "empty",
                        "message": "Hiện tại quán chưa có món nào."
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "menu",
                    "status": "ok",
                    "items": menu_items,
                    "message": "Menu hôm nay"
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi tải menu: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tải menu."
                }
            )

        return []


# ============================================================
# 2️⃣ HỎI GIÁ MÓN
# ============================================================
class ActionGetPrice(Action):
    def name(self) -> Text:
        return "action_get_price"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        food = tracker.get_slot("food")

        if not food:
            dispatcher.utter_message(
                json_message={
                    "type": "ask_price",
                    "message": "Bạn muốn hỏi giá món nào ạ?"
                }
            )
            return []

        docs = db.collection("menu").stream()
        found = None
        for doc in docs:
            data = doc.to_dict()
            name = data.get("name", "")
            price = data.get("price", "")
            if name.lower() in food.lower():
                found = {"name": name, "price": price}
                break

        if not found:
            dispatcher.utter_message(
                json_message={
                    "type": "not_found",
                    "food": food,
                    "message": f"Xin lỗi, quán không có món '{food}'."
                }
            )
            return []

        dispatcher.utter_message(
            json_message={
                "type": "price",
                "food": found["name"],
                "price": found["price"],
                "message": f"Món {found['name']} có giá {found['price']} VND."
            }
        )
        return []


# ============================================================
# 3️⃣ ĐẶT MÓN ĂN
# ============================================================
class ActionOrderFood(Action):
    def name(self) -> Text:
        return "action_order_food"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        food = tracker.get_slot("food")
        quantity = tracker.get_slot("quantity")

        if not food or not quantity:
            dispatcher.utter_message(
                json_message={
                    "type": "missing_info",
                    "message": "Vui lòng cho biết món và số lượng bạn muốn đặt."
                }
            )
            return []

        docs = db.collection("menu").stream()
        found = None
        for doc in docs:
            data = doc.to_dict()
            name = data.get("name", "")
            price = data.get("price", 0)
            if name.lower() in food.lower():
                found = {"name": name, "price": price}
                break

        if not found:
            dispatcher.utter_message(
                json_message={
                    "type": "not_found",
                    "food": food,
                    "message": f"Xin lỗi, quán không có món '{food}'."
                }
            )
            return []

        qty = parse_quantity(quantity)
        total = qty * int(found["price"])

        dispatcher.utter_message(
            json_message={
                "type": "order",
                "food": found["name"],
                "quantity": qty,
                "unit_price": found["price"],
                "total_price": total,
                "message": f"Đặt {qty} phần {found['name']} thành công. Tổng giá: {total:,} VND."
            }
        )

        return []


# ============================================================
# 4️⃣ XỬ LÝ NGOẠI LỆ / KHÔNG HIỂU
# ============================================================
class ActionOutOfScope(Action):
    def name(self) -> Text:
        return "action_out_of_scope"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        dispatcher.utter_message(
            json_message={
                "type": "unknown",
                "message": "Xin lỗi, tôi chưa hiểu ý bạn. Vui lòng nói lại về món ăn hoặc đặt món nhé."
            }
        )
        return []
