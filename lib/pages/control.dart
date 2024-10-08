// Control Page
import 'package:flutter/material.dart';
import 'package:passtrackdash/colors.dart';
import 'package:passtrackdash/pages/feed.dart';
import 'package:passtrackdash/pages/generatereport.dart';
import 'package:passtrackdash/pages/help.dart';
import 'package:passtrackdash/pages/notifications.dart';
import 'package:passtrackdash/pages/profile.dart';
//import 'package:passtrack/pages/settings.dart';
import 'package:passtrackdash/pages/tickethistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Page imports
import 'summary.dart';
import 'ticketmanagement.dart';
import 'qrcode.dart';
import 'settings.dart';
import '../components/auth.dart';
import 'promotions.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});
  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  String imgSample = "assets/images/volicon.png";
  String _title = "Home";
  static int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
  }

  final PageController _pageController =
      PageController(initialPage: _pageIndex);

  List<Widget> _fourPageViewChildren() {
    return <Widget>[
      const SummaryPage(),
      const TicketManagementPage(),
      const QRcodePage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mcgpalette0[50],
        title: Text(_title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FeedPage()));
              },
              icon: const Icon(Icons.bookmark_add_outlined)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PromotionsPage()));
              },
              icon: const Icon(Icons.discount_outlined)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsPage()));
              },
              icon: const Icon(Icons.notifications)),
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.close_outlined,
                                color: Colors.redAccent,
                              )),
                        ),
                        ListTile(
                          leading: SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset(imgSample),
                          ),
                          title: StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                // User is logged in
                                return SizedBox(
                                  width: 70,
                                  child: Text(
                                    snapshot.data!.email ?? "User",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: mcgpalette0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              } else {
                                // User is not logged in
                                return const Text(
                                  "Guest User",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: mcgpalette0,
                                  ),
                                );
                              }
                            },
                          ),
                          subtitle: StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.hasData ? "Active Now" : "Logged Out",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10),
                              );
                            },
                          ),
                          onTap: () {
                            // Your onTap logic here
                          },
                        ),
                      ]),
                ),
              ),
              ListTile(
                onTap: () {
                  
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GenerateReportPage()));
                },
                leading: const Icon(Icons.download_outlined),
                title: const Text("Generate Reports"), // Order History
              ),
              const Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TicketHistoryPage()));
                },
                leading: const Icon(Icons.history_rounded),
                title: const Text("Ticket History"), // Order History
              ),
              const Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HelpPage()));
                },
                leading: const Icon(Icons.help_outline),
                title: const Text("Help"), // Order History
              ),
              const Divider(
                thickness: 1,
                endIndent: 20,
                indent: 20,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Settings"),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text("Log Out"),
                onTap: () {
                  AuthService().signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            _pageIndex = index;
            switch (_pageIndex) {
              case 0:
                {
                  _title = 'Home';
                }
                break;
              case 1:
                {
                  _title = 'Ticket Management';
                }
                break;
              case 2:
                {
                  _title = 'QR Code';
                }
                break;
              case 3:
                {
                  _title = 'Profile';
                }
                break;
            }
          });
        },
        children: _fourPageViewChildren(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "QR Code"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
        onTap: (int index) {
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        },
        unselectedItemColor: Colors.black,
        currentIndex: _pageIndex,
        selectedItemColor: Colors.green,
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(
          color: Colors.black45,
        ),
      ),
    );
  }
}
