# actions/recommendations.py
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from firebase_admin import firestore
from .database import db

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
            # Sắp xếp theo "soldCount" giảm dần
            docs = db.collection("menu_items") \
                     .where("isAvailable", "==", True) \
                     .order_by("soldCount", direction=firestore.Query.DESCENDING) \
                     .limit(5) \
                     .stream()
            
            items = []
            for doc in docs:
                data = doc.to_dict()
                items.append({
                    "id": doc.id,
                    "name": data.get("name", ""),
                    "price": data.get("price", 0)
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
                    "type": "recommendation",
                    "items": items,
                    "total_items": len(items),
                    "message": f"Đây là {len(items)} món được yêu thích nhất tại quán:",
                    "quick_replies": ["Đặt món ngay", "Xem menu đầy đủ", "Món mới"]
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi recommend món: {e}")
            
            # Báo lỗi nếu thiếu Index
            if "FAILED_PRECONDITION" in str(e) or "index" in str(e).lower():
                 print("\n[LỖI FIREBASE] Bạn cần tạo một Composite Index!")
                 print("Hãy truy cập link trong thông báo lỗi (bên trên) để tạo index cho collection 'menu_items', GỒM 2 TRƯỜNG:")
                 print("1. isAvailable (Ascending)")
                 print("2. soldCount (Descending)\n")
                 dispatcher.utter_message(
                    json_message={
                        "type": "error",
                        "message": "Lỗi hệ thống: Cần tạo index trên Firestore để gợi ý. Vui lòng kiểm tra log trên terminal."
                    }
                 )
            else:
                dispatcher.utter_message(
                    json_message={
                        "type": "error",
                        "message": "Lỗi hệ thống: không thể gợi ý món ăn."
                    }
                )

        return []


class ActionRecommendNew(Action):
    def name(self) -> Text:
        return "action_recommend_new"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        
        try:
            # Truy vấn các món có isNew == True
            docs = db.collection("menu_items") \
                     .where("isAvailable", "==", True) \
                     .where("isNew", "==", True) \
                     .limit(5) \
                     .stream()
            
            items = []
            for doc in docs:
                data = doc.to_dict()
                items.append({
                    "id": doc.id,
                    "name": data.get("name", ""),
                    "price": data.get("price", 0),
                    "description": data.get("description", "")
                })

            if not items:
                dispatcher.utter_message(
                    json_message={
                        "type": "no_new_items",
                        "message": "Hiện tại quán chưa có món mới. Bạn có thể xem menu hoặc gợi ý món phổ biến nhé!"
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "new_items",
                    "items": items,
                    "total_items": len(items),
                    "message": f"Đây là {len(items)} món mới tại quán:",
                    "quick_replies": ["Đặt món ngay", "Xem menu đầy đủ", "Món phổ biến"]
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi lấy món mới: {e}")
            
            if "FAILED_PRECONDITION" in str(e) or "index" in str(e).lower():
                print("\n[LỖI FIREBASE] Cần tạo composite index cho truy vấn món mới!")
                print("Tạo index cho collection 'menu_items' với 2 trường:")
                print("1. isAvailable (Ascending)")  
                print("2. isNew (Ascending)\n")
                dispatcher.utter_message(
                    json_message={
                        "type": "error",
                        "message": "Lỗi hệ thống: Cần tạo index. Vui lòng kiểm tra log."
                    }
                )
            else:
                dispatcher.utter_message(
                    json_message={
                        "type": "error",
                        "message": "Lỗi hệ thống: không thể lấy danh sách món mới."
                    }
                )
        
        return []


class ActionShowVouchers(Action):
    def name(self) -> Text:
        return "action_show_vouchers"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        try:
            docs = db.collection("vouchers").where("isActive", "==", True).limit(5).stream()
            vouchers = []
            for doc in docs:
                data = doc.to_dict()
                vouchers.append({
                    "id": doc.id,
                    "title": data.get("title", ""),
                    "discount": data.get("discount", 0),
                    "code": data.get("code", ""),
                    "description": data.get("description", "")
                })

            if not vouchers:
                dispatcher.utter_message(
                    json_message={
                        "type": "no_vouchers",
                        "message": "Hiện tại không có voucher nào khả dụng. Hãy quay lại sau nhé!"
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "vouchers",
                    "vouchers": vouchers,
                    "total_vouchers": len(vouchers),
                    "message": f"Có {len(vouchers)} voucher đang có sẵn:"
                }
            )
        except Exception as e:
            print(f"[ERROR] Lỗi khi lấy vouchers: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error", 
                    "message": "Lỗi hệ thống: không thể lấy thông tin voucher."
                }
            )
            
        return []