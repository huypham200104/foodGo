# actions/users.py
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from .database import db

class ActionCheckMembership(Action):
    def name(self) -> Text:
        return "action_check_membership"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        
        try:
            user_id = tracker.sender_id
            if not user_id:
                dispatcher.utter_message(
                    json_message={
                        "type": "error",
                        "message": "Không thể xác định tài khoản người dùng."
                    }
                )
                return []

            user_doc = db.collection("users").document(user_id).get()
            if not user_doc.exists:
                dispatcher.utter_message(
                    json_message={
                        "type": "no_membership",
                        "message": "Bạn chưa có thông tin thành viên. Hãy đăng ký để được hưởng ưu đãi nhé!"
                    }
                )
                return []

            user_data = user_doc.to_dict()
            membership_type = user_data.get("membershipType", "basic")
            points = user_data.get("points", 0)
            
            dispatcher.utter_message(
                json_message={
                    "type": "membership_info",
                    "membershipType": membership_type,
                    "points": points,
                    "message": f"Bạn đang là thành viên {membership_type.upper()} với {points} điểm tích lũy."
                }
            )

        except Exception as e:
            print(f"[ERROR] Lỗi khi kiểm tra thành viên: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể kiểm tra thông tin thành viên."
                }
            )
            
        return []


class ActionFallback(Action):
    def name(self) -> Text:
        return "action_default_fallback"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        
        dispatcher.utter_message(
            json_message={
                "type": "fallback",
                "message": "Xin lỗi, tôi không hiểu yêu cầu của bạn. Bạn có thể nói rõ hơn hoặc xem menu để chọn món nhé! 😊",
                "quick_replies": [
                    "Xem menu",
                    "Gợi ý món ngon", 
                    "Hỗ trợ"
                ]
            }
        )
        
        return []