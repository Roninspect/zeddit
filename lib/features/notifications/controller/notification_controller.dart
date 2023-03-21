import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/notifications/repository/notification_repository.dart';

import '../../../models/notification_model.dart';

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(
    ref: ref,
    notificationRepository: ref.read(notificationRepositoryProvider),
  );
});

final getLikeNotificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, uid) {
  final controller = ref.watch(notificationControllerProvider);
  return controller.getLikeNotifications(uid);
});

final getCommentNotificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, uid) {
  final controller = ref.watch(notificationControllerProvider);
  return controller.getCommentNotifications(uid);
});

final combinedStreamProvider = StreamProvider.family((ref, String uid) {
  final likeStream = ref.watch(getLikeNotificationsProvider(uid));
  final commentStream = ref.watch(getCommentNotificationsProvider(uid));

  final controller = StreamController<List<NotificationModel>>();

  likeStream.whenData((likes) {
    commentStream.whenData((comments) {
      final notifications = likes + comments;
      controller.add(notifications);
    });
  });

  return controller.stream;
});

class NotificationController {
  final NotificationRepository _notificationRepository;

  NotificationController(
      {required NotificationRepository notificationRepository,
      required Ref ref})
      : _notificationRepository = notificationRepository;

  Stream<List<NotificationModel>> getLikeNotifications(String uid) {
    return _notificationRepository.getLikeNotifications(uid);
  }

  Stream<List<NotificationModel>> getCommentNotifications(String uid) {
    return _notificationRepository.getCommentNotifications(uid);
  }
}
