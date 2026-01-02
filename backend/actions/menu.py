# actions/menu.py
from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet
from .database import db
import re
from google.cloud.firestore import FieldFilter

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
            menu_ref = db.collection("menu_items").where(filter=FieldFilter("isAvailable", "==", True))
            docs = menu_ref.stream()
            all_items = []
            for doc in docs:
                data = doc.to_dict()
                all_items.append({
                    "id": doc.id,
                    "name": data.get("name", "Không rõ"),
                    "price": data.get("price", 0)
                })

            if not all_items:
                dispatcher.utter_message(
                    json_message={
                        "type": "menu", "status": "empty",
                        "message": "Hiện tại quán chưa có món nào."
                    }
                )
                return [SlotSet("menu_offset", 0)]

            # Pagination: 5 items per page
            PAGE_SIZE = 5
            offset = 0
            items_to_show = all_items[offset:offset + PAGE_SIZE]
            has_more = len(all_items) > PAGE_SIZE
            
            message = f"Menu hôm nay nè! (Hiển thị {len(items_to_show)}/{len(all_items)} món)"
            
            quick_replies = []
            if has_more:
                message += "\n💡 Bấm nút bên dưới để xem thêm nhé!"
                quick_replies.append("Xem thêm")
            quick_replies.extend(["Đặt món ngay", "Gợi ý món hot"])

            dispatcher.utter_message(
                json_message={
                    "type": "menu", 
                    "status": "success",
                    "message": message,
                    "total_items": len(all_items),
                    "showing": len(items_to_show),
                    "has_more": has_more,
                    "items": items_to_show,
                    "quick_replies": quick_replies
                }
            )
            
            # Save offset for next request
            return [SlotSet("menu_offset", PAGE_SIZE)]
            
        except Exception as e:
            print(f"[ERROR] Lỗi khi tải menu: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tải menu.",
                    "error": str(e)
                }
            )
            return [SlotSet("menu_offset", 0)]


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
            docs = db.collection("menu_items").where(filter=FieldFilter("isAvailable", "==", True)).stream()
            found = None
            
            food_lower = food.lower().strip()
            food_unaccented = remove_accents(food_lower)
            pattern_str = r'\b' + re.escape(food_unaccented)

            for doc in docs:
                data = doc.to_dict()
                name = data.get("name", "")
                name_lower = name.lower()
                name_unaccented = remove_accents(name_lower)
                
                if food_lower == name_lower:
                    found = {
                        "id": doc.id,
                        "name": name, 
                        "price": data.get("price", 0)
                    }
                    break
                elif re.search(pattern_str, name_unaccented):
                    found = {
                        "id": doc.id,
                        "name": name, 
                        "price": data.get("price", 0)
                    }
                    break

            if not found:
                dispatcher.utter_message(
                    json_message={
                        "type": "not_found", "food": food,
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
                    "message": "Bạn muốn tìm món ăn thuộc loại nào ạ?"
                }
            )
            return []
        try:
            docs = db.collection("menu_items")\
                .where(filter=FieldFilter("category", "==", category))\
                .where(filter=FieldFilter("isAvailable", "==", True))\
                .stream()
                
            items = []
            for doc in docs:
                data = doc.to_dict()
                items.append({
                    "id": doc.id,
                    "name": data.get("name", "Không rõ"),
                    "price": data.get("price", 0)
                })

            if not items:
                dispatcher.utter_message(
                    json_message={
                        "type": "not_found_category",
                        "category": category,
                        "message": f"Xin lỗi, hiện tại không có món nào trong danh mục '{category}'."
                    }
                )
                return []

            dispatcher.utter_message(
                json_message={
                    "type": "category_items",
                    "category": category,
                    "total_items": len(items),
                    "items": items,
                    "message": f"Có {len(items)} món trong danh mục '{category}'"
                }
            )
        except Exception as e:
            print(f"[ERROR] Lỗi khi tìm kiếm theo category: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tìm kiếm món ăn."
                }
            )
        return []


class ActionAskIngredients(Action):
    def name(self) -> Text:
        return "action_ask_ingredients"

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
                    "type": "ask_ingredients",
                    "message": "Bạn muốn biết thành phần của món nào ạ?"
                }
            )
            return []

        try:
            docs = db.collection("menu_items").where(filter=FieldFilter("isAvailable", "==", True)).stream()
            found = None
            
            food_lower = food.lower().strip()
            food_unaccented = remove_accents(food_lower)
            pattern_str = r'\b' + re.escape(food_unaccented)

            for doc in docs:
                data = doc.to_dict()
                name = data.get("name", "")
                name_lower = name.lower()
                name_unaccented = remove_accents(name_lower)
                
                if food_lower == name_lower:
                    found = {
                        "name": name,
                        "ingredients": data.get("ingredients", [])
                    }
                    break
                elif re.search(pattern_str, name_unaccented):
                    found = {
                        "name": name,
                        "ingredients": data.get("ingredients", [])
                    }
                    break

            if not found:
                dispatcher.utter_message(
                    json_message={
                        "type": "not_found", 
                        "food": food,
                        "message": f"Xin lỗi, không tìm thấy món '{food}' trong menu."
                    }
                )
                return []

            ingredients_text = ", ".join(found["ingredients"]) if found["ingredients"] else "Chưa có thông tin thành phần"
            
            dispatcher.utter_message(
                json_message={
                    "type": "ingredients",
                    "food": found["name"],
                    "ingredients": found["ingredients"],
                    "message": f"Món {found['name']} có thành phần: {ingredients_text}."
                }
            )
                
        except Exception as e:
            print(f"[ERROR] Lỗi khi tìm thành phần món: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tìm thông tin thành phần."
                }
            )
            
        return []


class ActionSearchByPrice(Action):
    def name(self) -> Text:
        return "action_search_by_price"

    def extract_price(self, text: str) -> int:
        if not text:
            return 0
        multiplier = 1
        lower_text = text.lower().replace(".", "").replace(",", "")
        if 'k' in lower_text or 'ngàn' in lower_text or 'nghìn' in lower_text:
            multiplier = 1000
        elif 'triệu' in lower_text:
            multiplier = 1000000
        numbers = re.findall(r'\d+', lower_text)
        if numbers:
            return int(numbers[0]) * multiplier
        return 0

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        price_entity = next(tracker.get_latest_entity_values("price_value"), None)
        print(f"[DEBUG] User message: {tracker.latest_message.get('text')}")
        print(f"[DEBUG] Extracted price_entity: '{price_entity}'")
        
        if not price_entity:
            # Fallback: Try to find numbers in the text if entity extraction failed
            text = tracker.latest_message.get('text', '')
            numbers = re.findall(r'\d+(?:\s*[kK]|(?:\s*ngh[iì]n)|(?:\s*ng[aà]n))?', text)
            if numbers:
                price_entity = numbers[0]
                print(f"[DEBUG] Fallback regex found price: '{price_entity}'")
            else:
                dispatcher.utter_message(
                    json_message={
                        "type": "ask_price_range",
                        "message": "Bạn muốn tìm món trong khoảng giá nào? (VD: dưới 50k, từ 20k đến 100k)"
                    }
                )
                return []

        max_price = self.extract_price(price_entity)
        print(f"[DEBUG] Calculated max_price: {max_price}")
        
        try:
            docs = db.collection("menu_items").where(filter=FieldFilter("isAvailable", "==", True)).stream()
            matching_items = []
            
            for doc in docs:
                data = doc.to_dict()
                price = data.get("price", 0)
                if price <= max_price:
                    matching_items.append({
                        "id": doc.id,
                        "name": data.get("name", "Không rõ"),
                        "price": price,
                        "soldCount": data.get("soldCount", 0)
                    })
            
            if not matching_items:
                dispatcher.utter_message(
                    json_message={
                        "type": "no_items_in_range",
                        "max_price": max_price,
                        "message": f"Xin lỗi, không có món nào dưới {max_price:,} VND."
                    }
                )
                return []
            
            # Sắp xếp theo soldCount giảm dần (bán chạy nhất)
            matching_items.sort(key=lambda x: x.get("soldCount", 0), reverse=True)
            
            # Lấy 3 món đầu tiên
            top_items = matching_items[:3]
            
            # Prepare message
            msg = f"Dưới {max_price:,} VND thì đây là 3 món bán chạy nhất nè:\n"
            for item in top_items:
                msg += f"- {item['name']} ({item['price']:,}đ)\n"
            
            has_more = len(matching_items) > 3
            
            # Response JSON
            response = {
                "type": "price_range_items",
                "max_price": max_price,
                "total_items": len(matching_items),
                "items": top_items,
                "message": msg
            }
            
            if has_more:
                response["quick_replies"] = ["Xem thêm", "Đặt món ngay"]
                response["message"] += "\nBạn có muốn xem thêm không?"

            dispatcher.utter_message(json_message=response)
            
            # Save state for pagination
            return [SlotSet("search_max_price", float(max_price)), SlotSet("search_offset", 3.0)]

        except Exception as e:
            print(f"[ERROR] Lỗi khi tìm kiếm theo giá: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi hệ thống: không thể tìm kiếm theo giá."
                }
            )
        
        return []


class ActionShowMoreItems(Action):
    def name(self) -> Text:
        return "action_show_more_items"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        
        max_price = tracker.get_slot("search_max_price")
        offset = tracker.get_slot("search_offset")
        
        if max_price is None or offset is None:
            dispatcher.utter_message(text="Bạn muốn tìm món gì nhỉ? Hãy thử hỏi giá hoặc loại món ăn nhé!")
            return []
            
        try:
            offset = int(offset)
            docs = db.collection("menu_items").where(filter=FieldFilter("isAvailable", "==", True)).stream()
            matching_items = []
            
            for doc in docs:
                data = doc.to_dict()
                price = data.get("price", 0)
                if price <= max_price:
                    matching_items.append({
                        "id": doc.id,
                        "name": data.get("name", "Không rõ"),
                        "price": price,
                        "soldCount": data.get("soldCount", 0)
                    })
            
            # Sort by soldCount desc
            matching_items.sort(key=lambda x: x.get("soldCount", 0), reverse=True)
            
            # Slice items
            next_items = matching_items[offset : offset + 3]
            
            if not next_items:
                dispatcher.utter_message(text="Hết món để gợi ý rồi ạ! Bạn chọn món nào chưa?")
                return [SlotSet("search_max_price", None), SlotSet("search_offset", None)]
                
            # Prepare message
            msg = "Gợi ý tiếp cho bạn nè:\n"
            for item in next_items:
                msg += f"- {item['name']} ({item['price']:,}đ)\n"
            
            has_more = len(matching_items) > (offset + 3)
            
            response = {
                "type": "price_range_items",
                "max_price": max_price,
                "items": next_items,
                "message": msg
            }
            
            if has_more:
                response["quick_replies"] = ["Xem thêm", "Đặt món ngay"]
                response["message"] += "\nVẫn còn món đó, xem tiếp không?"
            else:
                 response["message"] += "\nĐó là tất cả các món trong tầm giá này rồi ạ."

            dispatcher.utter_message(json_message=response)
            
            return [SlotSet("search_offset", float(offset + 3))]
            
        except Exception as e:
            print(f"[ERROR] Lỗi khi xem thêm: {e}")
            dispatcher.utter_message(text="Có lỗi xảy ra, bạn thử lại sau nhé.")
            return []


class ActionShowMoreMenu(Action):
    """Show more menu items with pagination"""
    def name(self) -> Text:
        return "action_show_more_menu"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        try:
            # Get current offset
            current_offset = tracker.get_slot("menu_offset")
            if current_offset is None:
                current_offset = 0
            offset = int(current_offset)
            
            # Fetch all available items
            menu_ref = db.collection("menu_items").where(filter=FieldFilter("isAvailable", "==", True))
            docs = menu_ref.stream()
            all_items = []
            for doc in docs:
                data = doc.to_dict()
                all_items.append({
                    "id": doc.id,
                    "name": data.get("name", "Không rõ"),
                    "price": data.get("price", 0)
                })

            total_items = len(all_items)
            
            # Check if already at end
            if offset >= total_items:
                dispatcher.utter_message(
                    json_message={
                        "type": "menu",
                        "status": "end",
                        "message": "🎉 Đã hết món trong menu rồi ạ! Bạn muốn đặt món nào không?",
                        "total_items": total_items,
                        "showing": 0,
                        "has_more": False,
                        "items": []
                    }
                )
                return [SlotSet("menu_offset", offset)]
            
            # Get next 5 items
            PAGE_SIZE = 5
            items_to_show = all_items[offset:offset + PAGE_SIZE]
            new_offset = offset + len(items_to_show)
            has_more = new_offset < total_items
            
            message = f"Thêm {len(items_to_show)} món nữa đây! (Đã xem {new_offset}/{total_items} món)"
            
            quick_replies = []
            if has_more:
                message += "\n💡 Còn nữa, bấm để xem tiếp!"
                quick_replies.append("Xem thêm")
            else:
                message += "\n🎉 Hết menu rồi ạ!"
            quick_replies.extend(["Đặt món ngay", "Xem voucher"])

            dispatcher.utter_message(
                json_message={
                    "type": "menu",
                    "status": "success",
                    "message": message,
                    "total_items": total_items,
                    "showing": len(items_to_show),
                    "has_more": has_more,
                    "items": items_to_show,
                    "quick_replies": quick_replies
                }
            )
            
            return [SlotSet("menu_offset", new_offset)]
            
        except Exception as e:
            print(f"[ERROR] Lỗi khi xem thêm menu: {e}")
            dispatcher.utter_message(
                json_message={
                    "type": "error",
                    "message": "Lỗi khi tải thêm menu. Vui lòng thử lại!",
                    "error": str(e)
                }
            )
            return []


class ActionCustomFallback(Action):
    def name(self) -> Text:
        return "action_custom_fallback"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any],
    ) -> List[Dict[Text, Any]]:
        
        # Default fallback message
        dispatcher.utter_message(
            json_message={
                "type": "fallback",
                "message": "Xin lỗi, mình chưa hiểu ý bạn lắm. Bạn có thể nói rõ hơn hoặc chọn các chức năng bên dưới nhé!",
                "quick_replies": ["Xem menu", "Gợi ý món ngon", "Kiểm tra đơn hàng"]
            }
        )
        return []