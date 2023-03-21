import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class CommentModel {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String userId;
  final String profilePic;
  final String username;
  final String communityName;
  CommentModel({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.userId,
    required this.profilePic,
    required this.username,
    required this.communityName,
  });

  CommentModel copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? userId,
    String? profilePic,
    String? username,
    String? communityName,
  }) {
    return CommentModel(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      profilePic: profilePic ?? this.profilePic,
      username: username ?? this.username,
      communityName: communityName ?? this.communityName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'userId': userId,
      'profilePic': profilePic,
      'username': username,
      'communityName': communityName,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      text: map['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      profilePic: map['profilePic'] as String,
      username: map['username'] as String,
      communityName: map['communityName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommentModel(id: $id, text: $text, createdAt: $createdAt, postId: $postId, userId: $userId, profilePic: $profilePic, username: $username, communityName: $communityName)';
  }

  @override
  bool operator ==(covariant CommentModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.userId == userId &&
        other.profilePic == profilePic &&
        other.username == username &&
        other.communityName == communityName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        postId.hashCode ^
        userId.hashCode ^
        profilePic.hashCode ^
        username.hashCode ^
        communityName.hashCode;
  }
}
