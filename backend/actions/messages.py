# actions/messages.py
from typing import Dict, Any, List, Optional
from datetime import datetime
from .database import db

class Message:
    def __init__(self, 
                 id: str, 
                 sender_id: str, 
                 text: str, 
                 is_bot: bool, 
                 timestamp: Any = None,
                 metadata: Dict[str, Any] = None):
        self.id = id
        self.sender_id = sender_id
        self.text = text
        self.is_bot = is_bot
        self.timestamp = timestamp or datetime.now()
        self.metadata = metadata or {}

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "sender_id": self.sender_id,
            "text": self.text,
            "is_bot": self.is_bot,
            "timestamp": self.timestamp,
            "metadata": self.metadata
        }

    @staticmethod
    def from_dict(data: Dict[str, Any]) -> 'Message':
        return Message(
            id=data.get("id"),
            sender_id=data.get("sender_id"),
            text=data.get("text"),
            is_bot=data.get("is_bot", False),
            timestamp=data.get("timestamp"),
            metadata=data.get("metadata", {})
        )

class MessageService:
    collection_name = "messages"

    @staticmethod
    def save_message(message: Message) -> bool:
        try:
            # Use message ID as document ID if provided, otherwise auto-generate
            doc_ref = db.collection(MessageService.collection_name).document(message.id)
            doc_ref.set(message.to_dict())
            return True
        except Exception as e:
            print(f"[ERROR] Failed to save message: {e}")
            return False

    @staticmethod
    def get_messages(user_id: str, limit: int = 50) -> List[Message]:
        try:
            # Query messages for a specific user (either sender or receiver context)
            # Note: In a real app, we might want a 'conversation_id'. 
            # Here we assume simple user-bot chat.
            query = db.collection(MessageService.collection_name)\
                .where("sender_id", "==", user_id)\
                .order_by("timestamp", direction="DESCENDING")\
                .limit(limit)
            
            docs = query.stream()
            messages = [Message.from_dict(doc.to_dict()) for doc in docs]
            return messages
        except Exception as e:
            print(f"[ERROR] Failed to get messages: {e}")
            return []

    @staticmethod
    def delete_message(message_id: str) -> bool:
        try:
            db.collection(MessageService.collection_name).document(message_id).delete()
            return True
        except Exception as e:
            print(f"[ERROR] Failed to delete message: {e}")
            return False
