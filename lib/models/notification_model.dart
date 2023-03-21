// ignore_for_file: public_member_api_docs, sort_constructors_first

class NotificationModel {
  String triggerer;
  String triggererName;
  String type;
  String postId;
  String poster;
  String posterName;
  String communityName;
  NotificationModel({
    required this.triggerer,
    required this.triggererName,
    required this.type,
    required this.postId,
    required this.poster,
    required this.posterName,
    required this.communityName,
  });

  NotificationModel copyWith({
    String? triggerer,
    String? triggererName,
    String? type,
    String? postId,
    String? poster,
    String? posterName,
    String? communityName,
  }) {
    return NotificationModel(
      triggerer: triggerer ?? this.triggerer,
      triggererName: triggererName ?? this.triggererName,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      poster: poster ?? this.poster,
      posterName: posterName ?? this.posterName,
      communityName: communityName ?? this.communityName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'triggerer': triggerer,
      'triggererName': triggererName,
      'type': type,
      'postId': postId,
      'poster': poster,
      'posterName': posterName,
      'communityName': communityName,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      triggerer: map['triggerer'] as String,
      triggererName: map['triggererName'] as String,
      type: map['type'] as String,
      postId: map['postId'] as String,
      poster: map['poster'] as String,
      posterName: map['posterName'] as String,
      communityName: map['communityName'] as String,
    );
  }
}
