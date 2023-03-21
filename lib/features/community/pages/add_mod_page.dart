// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class AddModPage extends ConsumerStatefulWidget {
  String name;
  AddModPage({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModState();
}

class _AddModState extends ConsumerState<AddModPage> {
  Set<String> mods = {};

  Set<String> addedMods = {};

  void removeMod(String uid) {
    setState(() {
      mods.remove(uid);
    });
  }

  void addMod(String uid) {
    setState(() {
      mods.add(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                onPressed: () async {
                  ref
                      .watch(communityControllerProvider.notifier)
                      .saveMods(mods.toList(), widget.name, context);
                },
                icon: const Icon(Icons.done),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Moderators"),
            ),
            ref.watch(getCommunityByNameProvider(widget.name)).when(
                  data: (community) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: community.mods.length,
                          itemBuilder: (context, index) {
                            final moderators = community.mods[index];
                            return ref
                                .watch(getUserDataProvider(moderators))
                                .when(
                                  data: (user) {
                                    if (community.mods.contains(moderators) &&
                                        !addedMods.contains(moderators)) {
                                      mods.add(moderators);
                                      addedMods.add(moderators);
                                    }

                                    return CheckboxListTile(
                                      title: Text(user.name),
                                      value: mods.contains(moderators),
                                      onChanged: (val) {
                                        if (val!) {
                                          addMod(user.uid);
                                        } else {
                                          removeMod(user.uid);
                                        }
                                      },
                                    );
                                  },
                                  error: (error, stackTrace) =>
                                      ErrorText(error: error.toString()),
                                  loading: () =>
                                      const CircularProgressIndicator(),
                                );
                          }),
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const CircularProgressIndicator(),
                ),
            const Text("All members"),
            ref.watch(getCommunityByNameProvider(widget.name)).when(
                  data: (community) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: community.members.length,
                          itemBuilder: (context, index) {
                            final member = community.members[index];
                            return ref.watch(getUserDataProvider(member)).when(
                                  data: (user) {
                                    if (community.mods.contains(member) &&
                                        !addedMods.contains(member)) {
                                      mods.add(member); //
                                      addedMods.add(member);
                                    }

                                    return CheckboxListTile(
                                      title: Text(user.name),
                                      value: mods.contains(member),
                                      onChanged: (val) {
                                        if (val!) {
                                          addMod(user.uid);
                                        } else {
                                          removeMod(user.uid);
                                        }
                                      },
                                    );
                                  },
                                  error: (error, stackTrace) =>
                                      ErrorText(error: error.toString()),
                                  loading: () =>
                                      const CircularProgressIndicator(),
                                );
                          }),
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const CircularProgressIndicator(),
                ),
          ],
        ));
  }
}
