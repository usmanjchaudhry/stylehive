import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html; // Add this import for web URL manipulation
import 'package:flutter/foundation.dart' show kIsWeb;

import 'home_page.dart';
import 'profile_page.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'login_page.dart';

AppBar buildAppBar(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  void _trimUrl() {
    if (kIsWeb) {
      var url = html.window.location.href;
      var idx = url.lastIndexOf('/');
      if (idx > 0) {
        var newUrl = url.substring(0, idx);
        html.window.history.pushState(null, '', newUrl);
      }
    }
  }

  return AppBar(
    backgroundColor: Colors.black,
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    elevation: 0,
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _AnimatedHoverTextButton(
            label: 'StyleHive',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ).then((_) {
                _trimUrl();
              });
            },
            hoverColor: Colors.deepOrangeAccent,
            defaultColor: Colors.white,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          const Spacer(),
          Row(
            children: [
              _AnimatedHoverIconButton(
                icon: FontAwesomeIcons.search,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShopPage(appBarBuilder: buildAppBar),
                    ),
                  ).then((_) {
                    _trimUrl();
                  });
                },
              ),
              const SizedBox(width: 8),
              if (user != null) ...[
                _AnimatedHoverIconButton(
                  icon: FontAwesomeIcons.shoppingCart,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CartPage(appBarBuilder: buildAppBar),
                      ),
                    ).then((_) {
                      _trimUrl();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _AnimatedHoverIconButton(
                  icon: FontAwesomeIcons.user,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(appBarBuilder: buildAppBar),
                      ),
                    ).then((_) {
                      _trimUrl();
                    });
                  },
                ),
              ] else
                _AnimatedHoverTextButton(
                  label: 'Login',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    ).then((_) {
                      _trimUrl();
                    });
                  },
                  hoverColor: Colors.deepOrangeAccent,
                  defaultColor: Colors.white,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 16.0,
                      ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _AnimatedHoverTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color hoverColor;
  final Color defaultColor;
  final TextStyle? style;

  const _AnimatedHoverTextButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.hoverColor,
    required this.defaultColor,
    this.style,
  }) : super(key: key);

  @override
  State<_AnimatedHoverTextButton> createState() =>
      _AnimatedHoverTextButtonState();
}

class _AnimatedHoverTextButtonState extends State<_AnimatedHoverTextButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final displayColor = _hovering ? widget.hoverColor : widget.defaultColor;
    final scale = _hovering ? 1.05 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Text(
            widget.label,
            style: widget.style?.copyWith(color: displayColor) ??
                TextStyle(color: displayColor),
          ),
        ),
      ),
    );
  }
}

class _AnimatedHoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedHoverIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<_AnimatedHoverIconButton> createState() =>
      _AnimatedHoverIconButtonState();
}

class _AnimatedHoverIconButtonState extends State<_AnimatedHoverIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovering ? Colors.deepOrangeAccent : Colors.white;
    final scale = _hovering ? 1.2 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: FaIcon(
            widget.icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
