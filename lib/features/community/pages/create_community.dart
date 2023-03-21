import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

class CreateCummunityPage extends ConsumerStatefulWidget {
  const CreateCummunityPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCummunityPageState();
}

class _CreateCummunityPageState extends ConsumerState<CreateCummunityPage> {
  final TextEditingController createCommunityController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    createCommunityController.dispose();
  }

  void createCommunity(String name) {
    ref
        .read(communityControllerProvider.notifier)
        .createCommunity(name: name, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Community"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            color: Pallete.drawerColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Community Name",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: createCommunityController,
                    maxLength: 21,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Example: r/Community",
                        filled: true,
                        contentPadding: EdgeInsets.all(20)),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            minimumSize: const Size(330, 60)),
                        onPressed: () async {
                          createCommunity(createCommunityController.text);
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Create Community")),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
