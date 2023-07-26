import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logout(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push("/profile-screen/$uid");
  }

  void troggleTheme(WidgetRef ref) {
    ref.read(themeNotifyProvider.notifier).togglrTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "u/${user.name}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            ListTile(
              title: Text('My Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                navigateToUserProfile(context, user.uid);
              },
            ),
            ListTile(
              title: Text('LogOut'),
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              onTap: () {
                logout(ref);
              },
            ),
            Switch.adaptive(
                value:
                    ref.watch(themeNotifyProvider.notifier).mod == Themes.dark,
                onChanged: (val) {
                  troggleTheme(ref);
                }),
          ],
        ),
      ),
    );
  }
}
