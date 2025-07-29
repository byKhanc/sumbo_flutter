import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scroll_buttons.dart';

class ScrollablePage extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final bool showScrollButtons;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? drawer;

  const ScrollablePage({
    super.key,
    required this.child,
    this.scrollController,
    this.showScrollButtons = true,
    this.padding,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.drawer,
  });

  @override
  State<ScrollablePage> createState() => _ScrollablePageState();
}

class _ScrollablePageState extends State<ScrollablePage> {
  late ScrollController _scrollController;
  bool _scrollButtonsEnabled = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _loadScrollButtonsSetting();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadScrollButtonsSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _scrollButtonsEnabled = prefs.getBool('scrollButtonsEnabled') ?? true;
        });
      }
    } catch (e) {
      // 설정 로드 실패 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title != null
          ? AppBar(
              title: Text(widget.title!),
              backgroundColor: const Color(0xFF2563eb),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              automaticallyImplyLeading: widget.automaticallyImplyLeading,
              actions: widget.actions,
            )
          : null,
      drawer: widget.drawer,
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
            if (widget.showScrollButtons)
              ScrollButtons(
                scrollController: _scrollController,
                enabled: _scrollButtonsEnabled,
              ),
          ],
        ),
      ),
    );
  }
}
