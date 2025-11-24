# actions/orders.py
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet
from .database import db, parse_quantity
import re

def remove_accents(input_str):
    import unicodedata
    s1 = u'ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳỴỵỶỷỸỹ'
    s0 = u'AAAAEEEIIOOOOUUYaaaaeeeiioooouuyAaDdIiUuOoUuAaAaAaAaAaAaAaAaAaAaEeEeEeEeEeEeEeEeIiIiOoOoOoOoOoOoOoOoOoOoOoOoUuUuUuUuUuUuUuYyYyYyYy'
    s = ''
    for c in input_str:
        if c in s1:
            s += s0[s1.index(c)]
        else:
            s += c
    return s

class ActionOrderFood(Action):
    def name(self) -> Text:
        return "action_order_food"

    def _validate_item(self, item_data: Dict[Text, Any]) -> bool:
        """Kiểm tra dữ liệu món ăn có hợp lệ không"""
        if not item_data:
            return False
        if "name" not in item_data or not item_data["name"]:
            return False
        # Price có thể là 0 (miễn phí/topping) nhưng phải là số
        if "price" not in item_data or not isinstance(item_data["price"], (int, float)):
            return False
        return True

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        food = tracker.get_slot("food")
        quantity = tracker.get_slot("quantity")
        
        # --- FALLBACK: Nếu slot food chưa có, thử tìm trong entities ---
        if not food:
            for entity in tracker.latest_message.get("entities", []):
                if entity.get("entity") == "food":
                    food = entity.get("value")
                    break
        
        # --- FALLBACK MẠNH MẼ: Nếu vẫn chưa có, quét text tin nhắn với toàn bộ menu ---
        if not food:
            message_text = tracker.latest_message.get("text", "")
            if message_text:
                message_text_lower = message_text.lower()
                message_text_unaccented = remove_accents(message_text_lower)
                
                try:
                    docs = db.collection("menu_items").where("isAvailable", "==", True).stream()
                    longest_match = ""
                    
                    for doc in docs:
                        data = doc.to_dict()
                        name = data.get("name", "")
                        if not name: continue
                        
                        name_lower = name.lower()
                        name_unaccented = remove_accents(name_lower)
                        
                        # Check xem tên món có nằm trong tin nhắn không
                        if (name_lower in message_text_lower) or (name_unaccented in message_text_unaccented):
                            if len(name) > len(longest_match):
                                longest_match = name
                    
                    if longest_match:
                        print(f"✅ [FALLBACK] Tìm thấy món '{longest_match}' trong tin nhắn: '{message_text}'")
                        food = longest_match
                        
                except Exception as e:
                    print(f"[WARNING] Lỗi khi fallback tìm món trong text: {e}")

        if not food:
            dispatcher.utter_message(
                json_message={
                    "type": "missing_info",
                    "message": "Vui lòng cho biết món bạn muốn đặt."
                }
            )
            return []
            
        try:
            # 1. Lấy tất cả món ăn đang có sẵn
            docs = db.collection("menu_items").where("isAvailable", "==", True).stream()
            
            # 2. Tìm kiếm các món phù hợp (chứa từ khóa)
            matches = []
            food_lower = food.lower().strip()
            food_unaccented = remove_accents(food_lower)
            
            # Tạo pattern regex để tìm kiếm từ nguyên vẹn (word boundary)
            pattern_str = r'\b' + re.escape(food_unaccented)
            
            for doc in docs:
                data = doc.to_dict()
                
                # Validate data integrity
                if not self._validate_item(data):
                    continue
                    
                name = data.get("name", "")
                name_lower = name.lower()
                name_unaccented = remove_accents(name_lower)
                
                # Logic tìm kiếm:
                # 1. Check chính xác (exact match)
                # 2. Check regex word boundary trên chuỗi không dấu
                if food_lower == name_lower:
                     matches.append({
                        "id": doc.id,
                        "name": name,
                        "price": data.get("price", 0),
                        "imageUrl": data.get("imageUrl", ""),
                        "description": data.get("description", "")
                    })
                elif re.search(pattern_str, name_unaccented):
                    matches.append({
                        "id": doc.id,
                        "name": name,
                        "price": data.get("price", 0),
                        "imageUrl": data.get("imageUrl", ""),
                        "description": data.get("description", "")
                    })
            
            # 3. Xử lý kết quả tìm kiếm
            if not matches:
                dispatcher.utter_message(
                    json_message={
                        "type": "not_found", 
                        "food": food,
                        "message": f"Tiếc quá, mình không tìm thấy món '{food}' nào cả. Bạn thử xem menu hoặc hỏi món khác nhé!"
                    }
                )
                return []
                
            # Trường hợp tìm thấy quá nhiều món (ví dụ > 1) -> Hỏi người dùng chọn món nào
            if len(matches) > 1:
                # Tạo danh sách gợi ý (quick replies)
                quick_replies = [f"Đặt {m['name']}" for m in matches[:5]] # Giới hạn 5 món đầu tiên
                
                dispatcher.utter_message(
                    json_message={
                        "type": "ask_more", # Dùng type ask_more để hiện quick replies
                        "message": f"Mình tìm thấy {len(matches)} món liên quan đến '{food}'. Bạn muốn đặt món nào?",
                        "quick_replies": quick_replies
                    }
                )
                return []
            
            # Trường hợp tìm thấy đúng 1 món -> Đặt luôn
            found = matches[0]
            qty = parse_quantity(quantity) if quantity else 1
            total = qty * int(found["price"])
            
            dispatcher.utter_message(
                json_message={
                    "type": "order",
                    "item": {
                        "id": found["id"],
                        "name": found["name"],
                        "price": found["price"],
                        "imageUrl": found.get("imageUrl", ""),
                        "description": found.get("description", "")
                    },
                    "quantity": qty,
                    "unit_price": found["price"],
                    "total_price": total,
                    "message": f"Đã thêm {qty} phần {found['name']} vào giỏ hàng. Tổng giá: {total:,} VND."
                }
            )
            
            # Gửi tin nhắn hỏi tiếp
            dispatcher.utter_message(
                json_message={
                    "type": "ask_more",
                    "message": "Bạn có muốn đặt thêm món gì nữa không? 😊",
                    "quick_replies": [
                        "Xem menu",
                        "Không, thanh toán ngay"
                    ]
                }
            )
            
        except Exception as e:
            print(f"[ERROR] Lỗi khi đặt món: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Hệ thống đang gặp sự cố, vui lòng thử lại sau."
                }
            )
        
        # Reset slots after processing to prevent stale data
        return [SlotSet("food", None), SlotSet("quantity", None)]


class ActionCancelOrder(Action):
    def name(self) -> Text:
        return "action_cancel_order"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        
        # Xóa các slot liên quan đến đơn hàng để reset
        dispatcher.utter_message(
            json_message={
                "type": "cancel_order",
                "status": "success",
                "message": "Đã hủy thao tác đặt món. Bạn cần hỗ trợ gì khác không? 😊"
            }
        )
        
        # Reset slots
        return [SlotSet("food", None), SlotSet("quantity", None)]