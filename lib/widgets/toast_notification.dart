import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ToastType { success, error, info, warning }

class ToastMessage {
  final String message;
  final ToastType type;
  final String id;

  ToastMessage({required this.message, required this.type, String? id})
    : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class ToastState extends Notifier<List<ToastMessage>> {
  final Map<String, Timer> _timers = {};

  @override
  List<ToastMessage> build() => [];

  void show(
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final toast = ToastMessage(message: message, type: type);
    state = [...state, toast];

    _timers[toast.id] = Timer(duration, () {
      dismiss(toast.id);
    });
  }

  void dismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    state = state.where((t) => t.id != id).toList();
  }

  void disposeTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

final toastProvider = NotifierProvider<ToastState, List<ToastMessage>>(
  () => ToastState(),
);

class ToastOverlay extends ConsumerWidget {
  final Widget child;
  const ToastOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);

    return Stack(
      children: [
        child,
        if (toasts.isNotEmpty)
          Positioned(
            top: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: toasts
                  .map((toast) => _ToastItem(toast: toast))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ToastItem extends StatefulWidget {
  final ToastMessage toast;
  const _ToastItem({required this.toast});

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.toast.type) {
      case ToastType.success:
        return const Color(0xFF065F46);
      case ToastType.error:
        return const Color(0xFF7F1D1D);
      case ToastType.info:
        return const Color(0xFF1E3A5F);
      case ToastType.warning:
        return const Color(0xFF78350F);
    }
  }

  Color get _iconColor {
    switch (widget.toast.type) {
      case ToastType.success:
        return const Color(0xFF34D399);
      case ToastType.error:
        return const Color(0xFFFCA5A5);
      case ToastType.info:
        return const Color(0xFF93C5FD);
      case ToastType.warning:
        return const Color(0xFFFCD34D);
    }
  }

  IconData get _icon {
    switch (widget.toast.type) {
      case ToastType.success:
        return LucideIcons.checkCircle2;
      case ToastType.error:
        return LucideIcons.xCircle;
      case ToastType.info:
        return LucideIcons.info;
      case ToastType.warning:
        return LucideIcons.alertTriangle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 16, color: _iconColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.toast.message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
