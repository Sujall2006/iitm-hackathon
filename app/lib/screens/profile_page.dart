import 'package:evflutterapp/screens/login_page.dart';
import 'package:evflutterapp/services/provider/user_info.dart';
import 'package:evflutterapp/widgets/profile_cards.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import Provider package

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserInfoProvider _userInfoProvider;

  @override
  void initState() {
    super.initState();
    _userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
  }

  void _showFullScreenImage(BuildContext context) {
    // Show full-screen image
  }

  showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to Logout"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove("token");
                prefs.remove("role");
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (context) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserInfo? userInfo = _userInfoProvider.getUserInfo();
    print("NAME : ${userInfo?.username}\n");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showLogoutConfirmationDialog(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            "", // Display user's photo if available
                            scale: 1,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  userInfo?.name ?? "", // Display user's name if available
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  userInfo?.mailId ?? "", // Display user's email if available
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                height: 10,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  ProfileCard(label: "Name", value: userInfo?.name ?? ""),
                  ProfileCard(label: "Email", value: userInfo?.mailId ?? ""),
                  ProfileCard(label: "Mobile Number", value: "9384479532")
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
