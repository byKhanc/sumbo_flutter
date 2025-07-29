import 'package:flutter/material.dart';
import 'dart:async';

class ScrollButtons extends StatefulWidget {
  final ScrollController scrollController;
  final bool enabled;

  const ScrollButtons({
    super.key,
    required this.scrollController,
    this.enabled = true,
  });

  @override
  State<ScrollButtons> createState() => _ScrollButtonsState();
}

class _ScrollButtonsState extends State<ScrollButtons> {
  bool _showUpButton = false;
  bool _showDownButton = false;
  bool _isVisible = false;
  Timer? _visibilityTimer;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    try {
      widget.scrollController.addListener(_onScroll);
    } catch (e) {
      // 스크롤 리스너 추가 실패 처리
    }
  }

  @override
  void dispose() {
    try {
      widget.scrollController.removeListener(_onScroll);
    } catch (e) {
      // 스크롤 리스너 제거 실패 처리
    }
    _visibilityTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScrollButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _removeScrollListener();
      _addScrollListener();
    }
  }

  void _addScrollListener() {
    try {
      widget.scrollController.addListener(_onScroll);
      // 초기 상태 체크
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateButtonVisibility();
      });
    } catch (e) {
      // 스크롤 리스너 추가 실패 처리
    }
  }

  void _removeScrollListener() {
    try {
      widget.scrollController.removeListener(_onScroll);
    } catch (e) {
      // 스크롤 리스너 제거 실패 처리
    }
  }

  void _onScroll() {
    if (!mounted) return;

    // 스크롤이 발생했음을 표시
    _isScrolling = true;

    _updateButtonVisibility();
    _resetVisibilityTimer();
  }

  void _updateButtonVisibility() {
    if (!mounted || !widget.scrollController.hasClients) return;

    try {
      final position = widget.scrollController.position;
      // position이 null이거나, 스크롤이 불가능하면 버튼 숨김
      if (position.maxScrollExtent <= 0) {
        if (mounted) {
          setState(() {
            _showUpButton = false;
            _showDownButton = false;
            _isVisible = false;
          });
        }
        return;
      }
      final canScrollUp = position.pixels > 20;
      final canScrollDown = position.pixels < position.maxScrollExtent - 20;

      if (mounted) {
        setState(() {
          _showUpButton = canScrollUp;
          _showDownButton = canScrollDown;
          _isVisible = (canScrollUp || canScrollDown) && _isScrolling;
        });
      }
    } catch (e) {
      // 버튼 상태 업데이트 실패 처리
      if (mounted) {
        setState(() {
          _showUpButton = false;
          _showDownButton = false;
          _isVisible = false;
        });
      }
    }
  }

  void _resetVisibilityTimer() {
    _visibilityTimer?.cancel();
    if (_isVisible && widget.enabled) {
      _visibilityTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
            _isScrolling = false;
          });
        }
      });
    }
  }

  void _scrollToTop() {
    if (!widget.scrollController.hasClients) return;

    try {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // 상단 스크롤 실패 처리
    }
  }

  void _scrollToBottom() {
    if (!widget.scrollController.hasClients) return;

    try {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // 하단 스크롤 실패 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showUpButton)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                heroTag: 'scroll_up_button',
                onPressed: _scrollToTop,
                backgroundColor: const Color(0xFF2563EB).withOpacity(0.2),
                foregroundColor: Colors.white,
                mini: false,
                child: const Icon(Icons.keyboard_arrow_up, size: 28),
              ),
            ),
          if (_showDownButton)
            FloatingActionButton(
              heroTag: 'scroll_down_button',
              onPressed: _scrollToBottom,
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.2),
              foregroundColor: Colors.white,
              mini: false,
              child: const Icon(Icons.keyboard_arrow_down, size: 28),
            ),
        ],
      ),
    );
  }
}
