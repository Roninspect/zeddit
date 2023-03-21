import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({Key? key}) : super(key: key);

  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
    ref.watch(authControllerProvider.notifier).singInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 100)),
      onPressed: () => signInWithGoogle(context, ref),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text("Sign In with Google"),
    );
  }
}
