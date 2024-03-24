import "dart:convert";

import "package:evflutterapp/screens/admin/admin_home_screen.dart";
import "package:evflutterapp/screens/home_screen.dart";
import "package:evflutterapp/screens/operator/operator_home_screen.dart";
import "package:evflutterapp/screens/signup_page.dart";
import "package:evflutterapp/services/functions/axios.dart";
import "package:evflutterapp/services/provider/user_info.dart";
import "package:evflutterapp/utils/images.dart";
import "package:evflutterapp/widgets/custom_text_form_field.dart";
import "package:evflutterapp/widgets/loading_dialog.dart";
import "package:flutter/material.dart";
import "package:form_validator/form_validator.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:provider/provider.dart";


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late UserInfoProvider userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);

  final Axios axios = Axios();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      LoadingDialog.show(context);
      final Map<String, String> data = {
        "username": _username.text.trim(),
        "password": _password.text.trim(),
      };
      var response = await axios.post("/auth/login", data: jsonEncode(data));
      var res = await jsonDecode(response.body);
      print(res);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", res["token"]);
        await prefs.setString("role", res["userInfo"]["role"]);
        UserInfo userInfo = UserInfo(
          username: res["userInfo"]["username"],
          mailId: res["userInfo"]["mailId"],
          name: res["userInfo"]["name"],
          phoneNumber: res["userInfo"]["phoneNumber"],
        );
        userInfoProvider.setUserInfo(userInfo);
        LoadingDialog.hide(context);
        if(res["userInfo"]["role"] == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminHomeScreen(),
            ),
          );
        } else if (res["userInfo"]["role"] == "operator") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OperatorHomeScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }

      } else {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res["error"])));
      }
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  loginImage,
                  width: 250,
                ),
                Text(
                  "Welcome Back",
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "One App For Hustle Free journey!",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 25,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: _username,
                        hintText: "Enter Your username",
                        labelText: "Username",
                        icon: Icons.mail,
                        validator: ValidationBuilder().required().build(),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _password,
                        hintText: "Enter Your Password",
                        labelText: "Password",
                        icon: Icons.fingerprint,
                        validator: ValidationBuilder().required().build(),
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: login,
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New here?",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen())),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          "Register Now",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
