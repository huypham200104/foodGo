# Import all actions from modular files
from .database import db, parse_quantity
from .menu import (
    ActionShowMenu,
    ActionGetPrice, 
    ActionSearchByCategory,
    ActionAskIngredients,
    ActionSearchByPrice
)
from .orders import (
    ActionOrderFood,
    ActionCancelOrder
)
from .recommendations import (
    ActionRecommendPopular,
    ActionRecommendNew,
    ActionShowVouchers
)
from .users import (
    ActionCheckMembership,
    ActionFallback
)

# Legacy actions that can be removed later (keeping for compatibility)
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

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