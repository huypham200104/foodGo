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
            menu_ref = db.collection("menu_items")
            docs = menu_ref.stream()

            menu_items = []
            for doc in docs:
                data = doc.to_dict()
                print(f"[DEBUG] Document ID: {doc.id}, Data: {data}")
                
                # 👈 Kiểm tra isAvailable trước khi thêm vào menu
                if data.get("isAvailable", True):
                    menu_items.append({
                        "id": doc.id,
                        "name": data.get("name", "Không rõ"),
                        "price": data.get("price", 0)  # 👈 Chỉ lấy name và price
                    })

            print(f"[DEBUG] Total menu items found: {len(menu_items)}")

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
                    "status": "success",
                    "message": "Menu hôm nay nè!",
                    "total_items": len(menu_items),
                    "items": menu_items  # 👈 Chỉ có id, name, price
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi tải menu: {e}")
            import traceback
            traceback.print_exc()
            
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tải menu.",
                    "error": str(e)
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

        try:
            docs = db.collection("menu_items").where("isAvailable", "==", True).stream()
            found = None
            
            for doc in docs:
                data = doc.to_dict()
                name = data.get("name", "")
                price = data.get("price", 0)
                
                if (food.lower() in name.lower() or 
                    name.lower() in food.lower()):
                    found = {
                        "id": doc.id,
                        "name": name, 
                        "price": price  # 👈 Chỉ lấy name và price
                    }
                    break

            if not found:
                dispatcher.utter_message(
                    json_message={
                        "type": "not_found",
                        "food": food,
                        "message": f"Xin lỗi, quán không có món '{food}'. Bạn có thể xem menu để chọn món khác nhé!"
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "price",
                    "food": found["name"],
                    "price": found["price"],
                    "message": f"Món {found['name']} có giá {found['price']:,} VND."
                }
            )
            
        except Exception as e:
            print(f"[ERROR] Lỗi khi tìm giá món: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tìm thông tin món ăn."
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

        if not food:
            dispatcher.utter_message(
                json_message={
                    "type": "missing_info",
                    "message": "Vui lòng cho biết món bạn muốn đặt."
                }
            )
            return []

        try:
            docs = db.collection("menu_items").where("isAvailable", "==", True).stream()
            found = None
            
            for doc in docs:
                data = doc.to_dict()
                name = data.get("name", "")
                price = data.get("price", 0)
                
                if (food.lower() in name.lower() or 
                    name.lower() in food.lower()):
                    found = {
                        "id": doc.id,
                        "name": name, 
                        "price": price  # 👈 Chỉ lấy name và price
                    }
                    break

            if not found:
                dispatcher.utter_message(
                    json_message={
                        "type": "not_found",
                        "food": food,
                        "message": f"Xin lỗi, quán không có món '{food}'. Bạn có thể xem menu để chọn món khác nhé!"
                    }
                )
                return []

            # 👈 Parse quantity với default = 1
            qty = parse_quantity(quantity) if quantity else 1
            total = qty * int(found["price"])

            dispatcher.utter_message(
                json_message={
                    "type": "order",
                    "item": {
                        "id": found["id"],
                        "name": found["name"],
                        "price": found["price"]  # 👈 Chỉ có id, name, price
                    },
                    "quantity": qty,
                    "unit_price": found["price"],
                    "total_price": total,
                    "message": f"Đã thêm {qty} phần {found['name']} vào giỏ hàng. Tổng giá: {total:,} VND."
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi đặt món: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể đặt món."
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
                "message": "Xin lỗi, tôi chưa hiểu ý bạn. Bạn có thể:\n• Xem menu\n• Hỏi giá món\n• Đặt món ăn\n\nVui lòng thử lại nhé!"
            }
        )
        return []


# ============================================================
# 5️⃣ THÊM ACTION TÌM KIẾM MÓN THEO CATEGORY
# ============================================================
class ActionSearchByCategory(Action):
    def name(self) -> Text:
        return "action_search_by_category"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        category = tracker.get_slot("category")
        
        if not category:
            dispatcher.utter_message(
                json_message={
                    "type": "ask_category",
                    "message": "Bạn muốn xem món thuộc loại nào? (burger, pizza, drink, v.v.)"
                }
            )
            return []

        try:
            docs = db.collection("menu_items").where("category", "==", category).where("isAvailable", "==", True).stream()
            items = []
            
            for doc in docs:
                data = doc.to_dict()
                items.append({
                    "id": doc.id,
                    "name": data.get("name", ""),
                    "price": data.get("price", 0)  # 👈 Chỉ lấy name và price
                })

            if not items:
                dispatcher.utter_message(
                    json_message={
                        "type": "category_empty",
                        "category": category,
                        "message": f"Hiện tại quán không có món {category}. Bạn có thể xem toàn bộ menu nhé!"
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "category_items",
                    "category": category,
                    "items": items,
                    "total_items": len(items),
                    "message": f"Các món {category} hiện có ({len(items)} món):"
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi tìm món theo category: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tìm món theo loại."
                }
            )

        return []


# ============================================================
# 6️⃣ THÊM ACTION RECOMMEND MÓN PHỔ BIẾN
# ============================================================
class ActionRecommendPopular(Action):
    def name(self) -> Text:
        return "action_recommend_popular"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        try:
            docs = db.collection("menu_items").where("isAvailable", "==", True).limit(5).stream()
            items = []
            
            for doc in docs:
                data = doc.to_dict()
                items.append({
                    "id": doc.id,
                    "name": data.get("name", ""),
                    "price": data.get("price", 0)  # 👈 Chỉ lấy name và price
                })

            if not items:
                dispatcher.utter_message(
                    json_message={
                        "type": "no_recommendations",
                        "message": "Hiện tại chưa có gợi ý món ăn. Bạn có thể xem menu để chọn nhé!"
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "recommendations",
                    "items": items,
                    "total_items": len(items),
                    "message": f"Đây là những món được yêu thích nhất ({len(items)} món):"
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi recommend món: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể gợi ý món ăn."
                }
            )

        return []
