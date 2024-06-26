import 'dart:async';

import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final Function(String) onSearch;

  const SearchTextField({required this.onSearch});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  Timer? _debounceTimer;

  void _onTextChanged(String newText) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(Duration(seconds: 1), () {
      widget.onSearch(newText);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: TextField(
        onChanged: _onTextChanged,
        decoration: InputDecoration(
          labelText: 'Rechercher',
          floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          prefixIcon: Icon(Icons.search,color: Theme.of(context).colorScheme.primary,),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.background,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
