import 'package:flutter/material.dart';
import 'package:rakhi_app/core/constants/app_colors.dart';
import 'package:rakhi_app/core/api/api_client.dart';
import 'package:rakhi_app/screens/rakhi/rakhi_voice_screen.dart';
import 'package:rakhi_app/screens/reports/my_reports_screen.dart';
import 'package:image_picker/image_picker.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class RakhiChatScreen extends StatefulWidget {
  const RakhiChatScreen({super.key});

  @override
  State<RakhiChatScreen> createState() => _RakhiChatScreenState();
}

class _RakhiChatScreenState extends State<RakhiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _isLoading = true);
        
        final uploadResponse = await ApiClient.uploadImage(image.path);
        if (uploadResponse.statusCode == 200) {
          final imageId = uploadResponse.data['image_id'];
          await _sendMessage(imageId: imageId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${uploadResponse.data['error']}')),
          );
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _sendMessage({int? imageId}) async {
    final message = _messageController.text.trim();
    if (message.isEmpty && imageId == null) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message.isEmpty ? 'Image sent' : message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    
    _messageController.clear();

    try {
      print('DEBUG: Sending message: "$message"');
      final response = await ApiClient.sendChatMessage(message, imageId: imageId);
      
      print('DEBUG: Chat response status: ${response.statusCode}');
      print('DEBUG: Chat response data: ${response.data}');
      print('DEBUG: Response keys: ${response.data.keys.toList()}');
      
      String replyText;
      
      if (response.statusCode == 200) {
        if (response.data.containsKey('data') && response.data['data'].containsKey('reply')) {
          replyText = response.data['data']['reply'];
          print('DEBUG: Found reply: "$replyText"');
        } else {
          replyText = 'API Response: ${response.data.toString()}';
          print('DEBUG: No reply field found, showing raw response');
        }
      } else {
        replyText = 'API Error (${response.statusCode}): ${response.data['error'] ?? 'Unknown error'}';
        print('DEBUG: API error response');
      }
      
      setState(() {
        _messages.add(ChatMessage(
          text: replyText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      
    } catch (e) {
      print('DEBUG: Exception caught: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Exception: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakhi AI Coach', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RakhiVoiceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.call, color: AppColors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onSelected: (value) {
              if (value == 'reports') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyReportsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reports',
                child: Row(
                  children: [
                    Icon(Icons.description, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('My Reports'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? AppColors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () => _sendMessage(),
            backgroundColor: AppColors.primary,
            mini: true,
            child: const Icon(Icons.send, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}