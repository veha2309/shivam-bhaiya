import 'package:flutter/material.dart';

class LeftFloatingActionMenu extends StatefulWidget {
  final List<FloatingActionTile> tiles;
  final IconData mainIcon;
  final IconData closeIcon;
  final Color? primaryColor;
  final Color? secondaryColor;

  const LeftFloatingActionMenu({
    Key? key,
    required this.tiles,
    this.mainIcon = Icons.menu,
    this.closeIcon = Icons.close,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  State<LeftFloatingActionMenu> createState() => _LeftFloatingActionMenuState();
}

class _LeftFloatingActionMenuState extends State<LeftFloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildTiles(),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: null, // to prevent issue with multiple FABs
          onPressed: _toggleMenu,
          backgroundColor: widget.primaryColor ?? Theme.of(context).primaryColor,
          child: AnimatedIconBuilder(
            isExpanded: _isExpanded,
            mainIcon: widget.mainIcon,
            closeIcon: widget.closeIcon,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTiles() {
    List<Widget> children = [];
    // We reverse the list when building so that the first item is closest to the FAB
    for (int i = 0; i < widget.tiles.length; i++) {
      children.add(
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: 1.0, // Expand from bottom up
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: widget.tiles[i],
          ),
        ),
      );
    }
    return children.reversed.toList();
  }
}

class FloatingActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const FloatingActionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FloatingActionButton.small(
          heroTag: null,
          onPressed: onTap,
          backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
          child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedIconBuilder extends StatelessWidget {
  final bool isExpanded;
  final IconData mainIcon;
  final IconData closeIcon;

  const AnimatedIconBuilder({
    Key? key,
    required this.isExpanded,
    required this.mainIcon,
    required this.closeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationTransition(
          turns: child.key == const ValueKey('close')
              ? Tween<double>(begin: 0.75, end: 1.0).animate(animation)
              : Tween<double>(begin: 0.75, end: 1.0).animate(animation),
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: isExpanded
          ? Icon(closeIcon, key: const ValueKey('close'))
          : Icon(mainIcon, key: const ValueKey('menu')),
    );
  }
}
