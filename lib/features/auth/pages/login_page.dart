import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/login_button.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  void guestSignIn(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).guestSignIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          "https://logodownload.org/wp-content/uploads/2018/02/reddit-logo-16.png",
          height: 40,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () => guestSignIn(ref, context),
                child: const Text("Login as Guest"),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: LoginButton(),
      ),
    );
  }
}
