import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatService {
  static const String webhookPath = '/webhooks/rest/webhook';
  static const String collectionName = 'messages';
  
  // Phát hiện platform và trả về URL phù hợp
  static String get baseUrl {
    if (kIsWeb) {
      // Web: sử dụng localhost
      return 'http://localhost:5005';
    } else if (Platform.isAndroid) {
      // Android Emulator: sử dụng 10.0.2.2
      return 'http://10.0.2.2:5005';
    } else {
      // iOS Simulator hoặc thiết bị khác: sử dụng localhost
      return 'http://localhost:5005';
    }
  }

  static Future<void> saveMessage(ChatMessage message, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(message.id)
          .set({
            ...message.toMap(),
            'userId': userId, // Add userId to filter messages
          });
      print('✅ Saved message to Firestore: ${message.id}');
    } catch (e) {
      print('❌ Error saving message to Firestore: $e');
    }
  }

  static Future<void> deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(messageId)
          .delete();
      print('✅ Deleted message from Firestore: $messageId');
    } catch (e) {
      print('❌ Error deleting message from Firestore: $e');
    }
  }

  static Future<void> clearChat(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ Cleared all messages for user: $userId');
    } catch (e) {
      print('❌ Error clearing chat: $e');
    }
  }

  static Stream<List<ChatMessage>> getMessagesStream(String userId) {
    return FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: false) // Show oldest first (top) to newest (bottom)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Ensure ID matches doc ID
            data['id'] = doc.id;
            return ChatMessage.fromMap(data);
          }).toList();
        });
  }
  
  static Future<List<ChatMessage>> sendMessage({
    required String userId,
    required String message,
  }) async {
    try {
      print('🚀 Sending request to: $baseUrl$webhookPath');
      print('📤 Payload: {"sender": "$userId", "message": "$message"}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$webhookPath'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sender': userId,
          'message': message,
        }),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        print('📋 Parsed data: $responseData');
        
        final List<ChatMessage> messages = [];
        
        for (final data in responseData) {
          print('🔍 Processing response item: $data');
          final chatMessage = ChatMessage.fromJson(data);
          messages.add(chatMessage);
          print('✅ Created ChatMessage: ${chatMessage.message}, cartAction: ${chatMessage.cartAction?.type}');
        }
        
        return messages;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  static ChatMessage getWelcomeMessage() {
    return ChatMessage.bot(
      '👋 Xin chào! Tôi là FoodGo Assistant. Tôi có thể giúp bạn:\n\n'
      '🍔 Tư vấn món ăn phù hợp\n'
      '📦 Hỗ trợ đặt hàng\n'
      '🚚 Theo dõi đơn hàng\n'
      '💬 Giải đáp thắc mắc\n'
      '🎁 Tìm khuyến mãi\n\n'
      'Hãy nhập tin nhắn để bắt đầu nhé! 😊'
    );
  }

  static List<String> getQuickReplies() {
    return [
      '🍔 Gợi ý món ăn',
      '🎁 Xem khuyến mãi',
      '📦 Đặt hàng nhanh',
      '🚚 Kiểm tra đơn hàng',
      '📞 Hỗ trợ',
    ];
  }
}