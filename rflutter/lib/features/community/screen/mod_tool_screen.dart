// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ModTool extends ConsumerWidget {
  String name;
  ModTool({
    required this.name,
  });

  void navigateToEditScreen(BuildContext context) {
    Routemaster.of(context).push('/edit-community-screen/$name');
  }

  void navigateToModtools(BuildContext context) {
    Routemaster.of(context).push('/add-mod-screen/$name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mod Tools'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.add_moderator),
            title: Text('Add Moderators'),
            onTap: () {
              navigateToModtools(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Community'),
            onTap: () {
              navigateToEditScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
