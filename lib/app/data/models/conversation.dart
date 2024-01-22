List<Conversation> usersFromJson(dynamic str) =>
    List<Conversation>.from(str.map((x) => Conversation.fromJson(x)));

class Conversation {
  final String lastMessage;
  final String name;
  final String id;
  final String receiverId;
  final bool markAsRead;
  final bool isReceiver;

  const Conversation({
    required this.name,
    required this.id,
    required this.receiverId,
    required this.lastMessage,
    required this.markAsRead,
    required this.isReceiver,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      name: json['name'] as String,
      id: json['id'] as String,
      receiverId: json['receiverId'] as String,
      lastMessage: json['lastMessage'] as String,
      markAsRead: json['markAsRead'] as bool,
      isReceiver: json['isReceiver'] as bool,
    );
  }
}
