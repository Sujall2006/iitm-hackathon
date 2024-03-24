import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet<void>(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                context: context,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 27),
                            ),
                            TextFormField(
                              autofocus: true,
                              initialValue: widget.value,
                              decoration:
                                  InputDecoration(labelText: widget.label),
                            ),
                            TextButton(
                                onPressed: () {
                                  // set provider
                                },
                                child: const Text("Save"))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.aBeeZee(color: Colors.grey),
                    ),
                    Text(
                      widget.value,
                      style: GoogleFonts.aBeeZee(),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.green,
                  size: 20,
                )
              ],
            ),
          ),
        ),
        const Divider(
          thickness: 0.3,
          indent: 20,
          endIndent: 20,
        )
      ],
    );
  }
}
