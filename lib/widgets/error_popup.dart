import 'package:flutter/material.dart';

class ErrorPopup extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  const ErrorPopup({required this.message, required this.onClose});
  @override
  _ErrorPopupState createState() => _ErrorPopupState();
}

class _ErrorPopupState extends State<ErrorPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween(
      begin: Offset(0, 1),
      end: Offset(0, 0.5),
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _controller.reverse().then((_) => widget.onClose());
              },
              child: Text("Закрыть"),
            ),
          ],
        ),
      ),
    );
  }
}
