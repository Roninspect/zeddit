import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/Home/drawers/community_list_drawer.dart';
import 'package:reddit_clone/features/Home/drawers/profile_drawer.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/notifications/controller/notification_controller.dart';
import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';
import 'package:badges/badges.dart' as badges;
import '../../../core/common/loginBTN.dart';
import '../delegates/search_community_delegate.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _page = 0;

  void showDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void showEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPagechanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final user = ref.watch(userProvider)!;

    final isGuest = !user.isAuthenticated;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          leading: Builder(
            builder: (context) => IconButton(
                onPressed: () => showDrawer(context),
                icon: const Icon(Icons.menu)),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: SearchCommunity(ref));
                },
                icon: const Icon(Icons.search)),
            Builder(builder: (context) {
              return IconButton(
                  onPressed: () => showEndDrawer(context),
                  icon: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic)));
            })
          ],
        ),
        body: Constants.tabWidgets[_page],
        drawer: const CommunityListDrawer(),
        endDrawer: const ProfileDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => isGuest
              ? showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Create post',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SignInBTN(),
                      ),
                    ],
                  )),
                )
              : Routemaster.of(context).push('/create-post'),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _page,
          onDestinationSelected: onPagechanged,
          backgroundColor: currentTheme.backgroundColor,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "home",
            ),
            ref.watch(combinedStreamProvider(user.uid)).when(
                  data: (data) {
                    return NavigationDestination(
                        icon: data.isNotEmpty
                            ? badges.Badge(
                                key: const Key('notifications-badge'),
                                position: badges.BadgePosition.topStart(),
                                badgeContent: Text(data.length.toString()),
                                child: const Icon(Icons.notifications_on),
                              )
                            : const Icon(Icons.notifications_on),
                        label: "Notifications");
                  },
                  error: (error, stackTrace) {
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Icon(Icons.notifications_on),
                ),
          ],
        ),
      ),
    );
  }
}
