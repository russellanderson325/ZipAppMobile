import 'package:flutter/material.dart';

class MessageOverlay {
  final String message;
  final Duration duration;
  final String color;
  final double opacity;

  static OverlayEntry? _currentOverlayEntry;

  MessageOverlay({required this.message, required this.duration, this.color = "#000000", this.opacity = 1});

  void show(BuildContext context) {
    if (_currentOverlayEntry != null) {
      // An overlay is already showing, so don't show another one.
      return;
    }

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(opacity),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    _currentOverlayEntry = overlayEntry;
    Overlay.of(context)?.insert(overlayEntry);

    // Automatically remove the overlay after the duration
    Future.delayed(duration, () {
      overlayEntry.remove();
      _currentOverlayEntry = null; // Reset the static variable
    });
  }
}

