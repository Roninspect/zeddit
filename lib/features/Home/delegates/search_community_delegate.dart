import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../models/community_model.dart';

class SearchCommunity extends SearchDelegate {
  final WidgetRef ref;

  SearchCommunity(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
          data: (communities) {
            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final CommunityModel community = communities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                  ),
                  title: Text("r/${community.name}"),
                  subtitle: Text(community.members.length.toString()),
                  onTap: () => navigateToCommunity(context, community.name),
                );
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const CircularProgressIndicator(),
        );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
          data: (communities) {
            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final CommunityModel community = communities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                  ),
                  title: Text("r/${community.name}"),
                  subtitle: Text(community.members.length.toString()),
                  onTap: () => navigateToCommunity(context, community.name),
                );
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const CircularProgressIndicator(),
        );
  }

  void navigateToCommunity(BuildContext context, String name) {
    Routemaster.of(context).push('/r/$name');
  }
}
