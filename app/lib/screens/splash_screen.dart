import "dart:convert";

import "package:evflutterapp/screens/admin/admin_home_screen.dart";
import "package:evflutterapp/screens/home_screen.dart";
import "package:evflutterapp/screens/login_page.dart";
import "package:evflutterapp/screens/operator/operator_home_screen.dart";
import "package:evflutterapp/services/functions/axios.dart";
import "package:evflutterapp/services/provider/user_info.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:provider/provider.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late UserInfoProvider userInfoProvider =
      Provider.of<UserInfoProvider>(context, listen: false);
  final Axios axios = Axios();

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await axios.get("/auth");
    var res = await jsonDecode(response.body);
    print(res);
    String? token = prefs.getString("token");
    String? role = prefs.getString("role");
    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } else {
      UserInfo userInfo = UserInfo(
        username: res["username"],
        mailId: res["mailId"],
        name: res["name"],
        phoneNumber: res["phoneNumber"],
      );
      userInfoProvider.setUserInfo(userInfo);
      switch (role) {
        case "admin":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
          break;
        case "operator":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OperatorHomeScreen()),
          );
          break;
        case "driver":
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
          break;
        default:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
      }
    }
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 30),
            Text(
              "Wait While We Fetch\nYour Data . . .",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
