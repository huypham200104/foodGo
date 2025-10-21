import firebase_admin
from firebase_admin import credentials, firestore
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher

# 🔹 Khởi tạo kết nối Firebase (chỉ cần 1 lần)
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

class ActionShowMenu(Action):
    def name(self):
        return "action_show_menu"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: dict):

        # 🔹 Lấy dữ liệu từ Firestore
        menu_ref = db.collection("menu")  # collection tên "menu"
        docs = menu_ref.stream()

        menu_items = []
        for doc in docs:
            data = doc.to_dict()
            name = data.get("name", "Không rõ")
            price = data.get("price", "N/A")
            menu_items.append(f"{name} - {price} VND")

        if not menu_items:
            dispatcher.utter_message(text="Hiện chưa có món nào trong menu.")
        else:
            dispatcher.utter_message(text="🧾 Menu hôm nay:\n" + "\n".join(menu_items))

        return []
