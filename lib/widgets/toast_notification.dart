import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        child,
        if (toasts.isNotEmpty)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: toasts
                    .map((toast) => _ToastItem(toast: toast, isDark: isDark))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastItem extends ConsumerStatefulWidget {
  final ToastMessage toast;
  final bool isDark;
  const _ToastItem({required this.toast, required this.isDark});

  @override
  ConsumerState<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends ConsumerState<_ToastItem>
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
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        ref.read(toastProvider.notifier).dismiss(widget.toast.id);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _iconColor {
    final isDark = widget.isDark;
    switch (widget.toast.type) {
      case ToastType.success:
        return isDark ? AppTheme.successDark : AppTheme.successLight;
      case ToastType.error:
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      case ToastType.info:
        return isDark ? AppTheme.infoDark : AppTheme.infoLight;
      case ToastType.warning:
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
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
    final isDark = widget.isDark;
    final bgColor = isDark ? const Color(0xFF2F2F2F) : const Color(0xFFFFFFFF);
    final textColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF37352F);
    final borderColor = isDark
        ? const Color(0xFF3D3D3D)
        : const Color(0xFFE9E9E7);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: borderColor, width: 1),
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
                        fontSize: 13,
                        color: textColor,
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
      ),
    );
  }
}
