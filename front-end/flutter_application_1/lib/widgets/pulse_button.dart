import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/newContact.dart';

class PulseButton extends StatefulWidget {
  final VoidCallback? onContactCreated;
  const PulseButton({super.key, this.onContactCreated});

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async{
    _controller.forward();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (context) => NewContact(
        categoryId: null,
        isFavorite: false,
        name: null,
        phones: null,
        photoUrl: null,
        )),
    );
    if(widget.onContactCreated != null){
      widget.onContactCreated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: CircleAvatar(
          radius: 19,
          backgroundColor: const Color.fromRGBO(43, 108, 238, 0.2),
          child: const Icon(
            Icons.add,
            color: Color.fromRGBO(43, 108, 238, 1),
            size: 30.0,
          ),
        ),
      ),
    );
  }
}
