import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';

class UserListScreen extends StatefulWidget {
  static const String routeName = '/user-list';
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  Future<List<User>>? usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = _loadUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<List<User>> _loadUsers() async {
    final fetchedUsers = LocalStorage.getAllUsers();
    setState(() {
      users = fetchedUsers;
    });

    return fetchedUsers;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: "Users",
        body: getUserListScreen(context),
      ),
    );
  }

  Widget getUserListScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AppFutureBuilder(
        future: usersFuture,
        builder: (context, snapshot) => users.isEmpty
            ? const Center(
                child: Text(
                  "No users found",
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: fontFamily,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          color: user.isLogged
                              ? Colors.green.shade100
                              : Colors.white,
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                for (int i = 0; i < users.length; i++) {
                                  users[i].isLogged = false;
                                }
                                user.isLogged = true;
                                users[index] = user;
                              });
                            },
                            leading: Icon(
                              Icons.person,
                              color: user.isLogged ? Colors.green : Colors.grey,
                            ),
                            title: Text(user.name,
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                )),
                            subtitle: Text(
                              user.username,
                              textScaler: const TextScaler.linear(1.0),
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: fontFamily,
                              ),
                            ),
                            trailing: user.isLogged
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  AppButton(
                    text: "Confirm",
                    onPressed: (_) {
                      User user =
                          users.firstWhere((element) => element.isLogged);
                      LocalStorage.updateUserStatus(user);
                      Phoenix.rebirth(context);
                    },
                  )
                ],
              ),
      ),
    );
  }
}
