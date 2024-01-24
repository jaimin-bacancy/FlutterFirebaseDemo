import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequest {
  final DocumentReference? requestedBy;
  final DocumentReference user1;
  final DocumentReference user2;
  final bool? requestAccepted;

  FollowRequest({
    required this.user1,
    required this.user2,
    required this.requestedBy,
    required this.requestAccepted,
  });

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      requestedBy: json['requestedBy'] as DocumentReference,
      requestAccepted: json['requestAccepted'] as bool,
      user1: json['user1'] as DocumentReference,
      user2: json['user2'] as DocumentReference,
    );
  }
}
