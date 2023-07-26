import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/common/error_text.dart';
import 'package:rflutter/core/common/loder.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/model/user_model.dart';
import 'package:rflutter/route.dart';
import 'package:rflutter/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getUserData(WidgetRef ref, User uid) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(uid.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: ((data) {
            return MaterialApp.router(
              title: 'Flutter Demo',
              theme: ref.watch(themeNotifyProvider),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: ((context) {
                  if (data != null) {
                    getUserData(ref, data);
                    if (userModel != null) {
                      return logInRoute;
                    }
                  }
                  return logOutRoute;
                }),
              ),
              routeInformationParser: RoutemasterParser(),
            );
          }),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loder(),
        );
  }
}
