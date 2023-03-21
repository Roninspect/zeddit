// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Post {
  final String postId;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityProfile;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String userName;
  final String uid;
  final String type;
  final DateTime createdAt;
  final List<String> awards;

  Post({
    required this.postId,
    required this.title,
    this.link,
    this.description,
    required this.communityName,
    required this.communityProfile,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.userName,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.awards,
  });

  Post copyWith({
    String? postId,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityProfile,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? userName,
    String? uid,
    String? type,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return Post(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityProfile: communityProfile ?? this.communityProfile,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      userName: userName ?? this.userName,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'title': title,
      'link': link,
      'description': description,
      'communityName': communityName,
      'communityProfile': communityProfile,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'userName': userName,
      'uid': uid,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'awards': awards,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'] as String,
      title: map['title'] as String,
      link: map['link'] != null ? map['link'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      communityName: map['communityName'] as String,
      communityProfile: map['communityProfile'] as String,
      upvotes: List<String>.from(
          (map['upvotes'] as List<dynamic>).map((e) => e as String).toList()),
      downvotes: List<String>.from(
          (map['downvotes'] as List<dynamic>).map((e) => e as String).toList()),
      commentCount: map['commentCount'] as int,
      userName: map['userName'] as String,
      uid: map['uid'] as String,
      type: map['type'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      awards: List<String>.from(
          (map['awards'] as List<dynamic>).map((e) => e as String).toList()),
    );
  }

  // @override
  // String toString() {
  //   return 'Post(postId: $postId, title: $title, link: $link, description: $description, communityName: $communityName, communityProfile: $communityProfile, upvotes: $upvotes, downvotes: $downvotes, commentCount: $commentCount, userName: $userName, uid: $uid, type: $type, createdAt: $createdAt, awards: $awards)';
  // }
}
