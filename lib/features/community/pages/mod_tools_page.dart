import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsPage extends StatelessWidget {
  String name;
  ModToolsPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () => Routemaster.of(context).push('/add-mod/$name'),
            leading: const Icon(Icons.people),
            title: const Text("Add Moderators"),
            shape: Border.all(color: Colors.white, width: 0.3),
          ),
          ListTile(
            onTap: () => Routemaster.of(context).push('/edit_Community/$name'),
            leading: const Icon(Icons.edit),
            title: const Text("Change Subreddit info"),
            shape: Border.all(color: Colors.white, width: 0.3),
          ),
        ],
      ),
    );
  }
}
