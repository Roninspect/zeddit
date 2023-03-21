// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';

import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

import 'package:reddit_clone/features/notifications/controller/notification_controller.dart';
import 'package:routemaster/routemaster.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Notifications",
            style: TextStyle(fontSize: 30),
          ),
        ),
        Expanded(
          child: ref.watch(combinedStreamProvider(user!.uid)).when(
                data: (notifications) {
                  return ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.white,
                      thickness: 2,
                    ),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];

                      return ListTile(
                        tileColor: Colors.indigo,
                        title: GestureDetector(
                            onTap: () => Routemaster.of(context).push(
                                '${notification.communityName}/post/${notification.postId}'),
                            child: notification.type == 'liked'
                                ? Text(
                                    '${notification.triggererName} has liked your post in r/${notification.communityName}')
                                : Text(
                                    '${notification.triggererName} has commented in your post in r/${notification.communityName}')),
                      );
                    },
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const CircularProgressIndicator(),
              ),
        ),
      ],
    ));
  }
}
