import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

import 'package:reddit_clone/firebase_options.dart';

import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

import 'routes/router.dart';
import 'models/user_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

void getUserDatas(WidgetRef ref, User data) async {
  UserModel? usermodel;
  usermodel = await ref
      .watch(authControllerProvider.notifier)
      .getuserData(data.uid)
      .first;
  ref.watch(userProvider.notifier).update((state) => usermodel);
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
        data: (data) => MaterialApp.router(
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) {
                  if (data != null) {
                    //
                    final details = ref.watch(userProvider);

                    if (details != null) {
                      return loggedInRoutes;
                    } else {
                      getUserDatas(ref, data);
                    }
                  }

                  return loogedOutRoutes;
                },
              ),
              routeInformationParser: const RoutemasterParser(),
              title: 'Flutter Demo',
              theme: ref.watch(themeProvider),
              debugShowCheckedModeBanner: false,
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const CircularProgressIndicator());
  }
}
