import "dart:convert";

import "package:evflutterapp/screens/login_page.dart";
import "package:evflutterapp/services/functions/axios.dart";
import "package:evflutterapp/utils/images.dart";
import "package:evflutterapp/widgets/custom_text_form_field.dart";
import "package:evflutterapp/widgets/loading_dialog.dart";
import "package:flutter/material.dart";
import "package:form_validator/form_validator.dart";
import "package:google_fonts/google_fonts.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Axios axios = Axios();

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      LoadingDialog.show(context);
      final Map<String, String> data = {
        "username": _userName.text.trim(),
        "name": _name.text.trim(),
        "phoneNumber": _phoneNumber.text.trim(),
        "mailId": _email.text.trim(),
        "password": _password.text.trim()
      };
      var response = await axios.post("/auth", data: jsonEncode(data));
      var res = await jsonDecode(response.body);
      print(res);
      if (response.statusCode == 200) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res["message"])));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res["error"])));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _userName.dispose();
    _email.dispose();
    _confirmPassword.dispose();
    _phoneNumber.dispose();
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
                // Image.asset(
                //   signUpImage,
                //   width: 120,
                // ),
                Text(
                  "Welcome 😎",
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
                        controller: _userName,
                        hintText: "Enter Your Username",
                        labelText: "Username",
                        icon: Icons.person,
                        validator: ValidationBuilder().required().build(),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _name,
                        hintText: "Enter Your Name",
                        labelText: "Name",
                        icon: Icons.person_outline,
                        validator: ValidationBuilder().required().build(),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _phoneNumber,
                        hintText: "Enter Your Phone Number",
                        labelText: "Phone Number",
                        icon: Icons.phone,
                        validator: ValidationBuilder().phone().build(),
                        isNumber: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _email,
                        hintText: "Enter Your Email",
                        labelText: "Email",
                        icon: Icons.mail,
                        validator: ValidationBuilder().email().build(),
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
                      CustomTextFormField(
                        controller: _confirmPassword,
                        hintText: "Confirm Password",
                        labelText: "Confirm Password",
                        icon: Icons.fingerprint,
                        validator: ValidationBuilder()
                            .required()
                            .add((value) => value != _password.text.trim()
                                ? "Password does not match"
                                : null)
                            .build(),
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
                          onPressed: signUp,
                          child: Text(
                            "Register",
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
                      "Already a member?",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Login",
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
