import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInBTN extends ConsumerWidget {
  const SignInBTN({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
      },
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.grey,
        ),
        child: const Center(
          child: Text(
            'Sign in to use this feature',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
