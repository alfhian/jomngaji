import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String hint;

  const SearchField({super.key, this.hint = "Cari kelas mengaji..."});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
