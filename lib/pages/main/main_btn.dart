import 'package:flutter/material.dart';
import 'package:vpn_client/design/colors.dart';


class MainBtn extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final String connectionTime;
  final String connectionStatus;
  const MainBtn({super.key, required this.title, required this.onPressed, required this.connectionTime, required this.connectionStatus});

  @override
  State<MainBtn> createState() => MainBtnState();
}

class MainBtnState extends State<MainBtn> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _sizeAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );
        _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.connectionTime,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color:
                widget.connectionStatus == 'Connected'
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 70),
        GestureDetector(
          onTap: () {
            widget.onPressed();
             if (widget.connectionStatus == 'Connected') {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              AnimatedBuilder(
                animation: _sizeAnimation,
                builder: (context, child) {
                  return Container(
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      gradient: mainGradient,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                width: 150,
                height: 150,
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
         const SizedBox(height: 20),
        Text(
         widget.connectionStatus,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
// Remove this code
/*
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vpn_client/design/colors.dart';
import 'package:vpn_client/design/dimensions.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';


import 'package:flutter_v2ray/flutter_v2ray.dart';

final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
        // do something
    },
);


*/
