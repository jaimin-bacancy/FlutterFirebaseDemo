abstract class FirebaseConfig {
  FirebaseConfig._();

  static const String db_users = 'users';
  static const String db_conversations = 'conversations';
  static const String db_chat = 'chat';
  static const String db_followers = 'followers';
  static const String db_following = 'following';
  static const String db_followRequests = 'followRequests';

  static const String field_text = 'text';
  static const String field_uid = 'uid';
  static const String field_createdAt = 'createdAt';
  static const String field_from = 'from';
  static const String field_name = 'name';
  static const String field_markAsRead = 'markAsRead';
  static const String field_isApproved = 'isApproved';
  static const String field_user1 = 'user1';
  static const String field_user2 = 'user2';
  static const String field_requestAccepted = 'requestAccepted';
  static const String field_requestedBy = 'requestedBy';
}
