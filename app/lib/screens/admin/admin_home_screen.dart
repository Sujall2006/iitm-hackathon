import "dart:convert";

import "package:evflutterapp/screens/profile_page.dart";
import "package:evflutterapp/services/functions/axios.dart";
import "package:evflutterapp/widgets/admin/operator_card.dart";
import "package:evflutterapp/widgets/custom_text_form_field.dart";
import "package:evflutterapp/widgets/loading_dialog.dart";
import "package:evflutterapp/widgets/nothing_to_show_here.dart";
import "package:flutter/material.dart";
import "package:form_validator/form_validator.dart";
import "package:google_fonts/google_fonts.dart";

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Axios axios = Axios();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mailId = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  Future<dynamic> getOperators() async {
    var response = await axios.get("/admin");
    var res = jsonDecode(response.body);
    return res;
  }

  Future<void> onRefresh() async {
    setState(() {});
  }

  Future<void> registerOperator() async {
    try {
      if (_formKey.currentState!.validate()) {
        LoadingDialog.show(context);
        var data = {
          "username": _username.text.trim(),
          "name": _name.text.trim(),
          "phoneNumber": _phoneNumber.text.trim(),
          "mailId": _mailId.text.trim(),
        };
        var response = await axios.post("/admin", data: jsonEncode(data));
        var res = jsonDecode(response.body);
        print(res);
        if (response.statusCode == 201) {
          LoadingDialog.hide(context);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res["message"],
              ),
            ),
          );
          setState(() {});
        } else {
          LoadingDialog.hide(context);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res["error"],
              ),
            ),
          );
          print("HELLO");
        }
      }
    } catch (e) {
      LoadingDialog.hide(context);
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _mailId.dispose();
    _phoneNumber.dispose();
    _username.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getOperators();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: const Text("Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder<dynamic>(
          future: getOperators(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              if (snapshot.data.length == 0) {
                return const NothingToShowHere();
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var operator = snapshot.data[index];
                    return OperatorCard(
                      operatorData: operator,
                      onOperatorDeleted: () => setState(() {}),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: IconButton(
        color: Colors.black,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Register a New Operator",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextFormField(
                                controller: _username,
                                hintText: "Username",
                                labelText: "Enter Operator Username",
                                icon: Icons.person,
                                validator:
                                    ValidationBuilder().required().build(),
                              ),
                              const SizedBox(height: 16),
                              CustomTextFormField(
                                controller: _name,
                                hintText: "Name",
                                labelText: "Enter Operator Name",
                                icon: Icons.person_outline,
                                validator:
                                    ValidationBuilder().required().build(),
                              ),
                              const SizedBox(height: 16),
                              CustomTextFormField(
                                controller: _phoneNumber,
                                hintText: "Phonenumber",
                                labelText: "Enter Operator Phonenumber",
                                icon: Icons.phone,
                                validator: ValidationBuilder().phone().build(),
                                isNumber: true,
                              ),
                              const SizedBox(height: 16),
                              CustomTextFormField(
                                controller: _mailId,
                                hintText: "Mail ID",
                                labelText: "Enter Operator MailID",
                                icon: Icons.mail,
                                validator: ValidationBuilder().email().build(),
                              ),
                              const SizedBox(height: 16.0),
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: registerOperator,
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(
          Icons.add,
          size: 25,
        ),
      ),
    );
  }
}
