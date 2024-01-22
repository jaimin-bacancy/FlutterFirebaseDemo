class FollowRequest {
  final String name;
  final bool isApproved;

  FollowRequest({
    required this.name,
    required this.isApproved,
  });

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      name: json['name'] as String,
      isApproved: json['isApproved'] as bool,
    );
  }
}
