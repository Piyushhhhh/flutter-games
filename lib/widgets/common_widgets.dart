import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// Reusable animated button widget
class AnimatedGameButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final String? semanticLabel;

  const AnimatedGameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.semanticLabel,
  });

  @override
  State<AnimatedGameButton> createState() => _AnimatedGameButtonState();
}

class _AnimatedGameButtonState extends State<AnimatedGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      button: true,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width ?? AppConstants.buttonWidthLarge,
                height: widget.height ?? AppConstants.buttonHeightLarge,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: AppConstants.elevationMedium,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    onTap: widget.onPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                        vertical: AppConstants.spacingM,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading)
                            SizedBox(
                              width: AppConstants.iconM,
                              height: AppConstants.iconM,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.foregroundColor ?? Colors.white,
                                ),
                              ),
                            )
                          else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: AppConstants.iconM,
                              color: widget.foregroundColor ?? Colors.white,
                            ),
                            const SizedBox(width: AppConstants.spacingS),
                          ],
                          Flexible(
                            child: Text(
                              widget.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: widget.foregroundColor ?? Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Game card widget for the menu
class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? semanticLabel;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
    this.isEnabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? '$title game',
      button: true,
      enabled: isEnabled,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                gradient: isEnabled
                    ? LinearGradient(
                        colors: [color.withOpacity(0.8), color],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEnabled ? null : theme.colorScheme.surface,
                border: Border.all(
                  color: isEnabled ? Colors.transparent : theme.dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: AppConstants.elevationMedium,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: AppConstants.iconXL,
                    color: isEnabled ? Colors.white : theme.disabledColor,
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color:
                                isEnabled ? Colors.white : theme.disabledColor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: AppConstants.spacingXS),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isEnabled
                                ? Colors.white70
                                : theme.disabledColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingS),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isEnabled ? Colors.white : theme.disabledColor,
                    size: AppConstants.iconS,
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

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = AppConstants.iconXL,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? theme.colorScheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppConstants.spacingM),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Game status widget
class GameStatus extends StatelessWidget {
  final String message;
  final Color? color;
  final IconData? icon;

  const GameStatus({
    super.key,
    required this.message,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: (color ?? theme.colorScheme.primary).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color ?? theme.colorScheme.primary,
              size: AppConstants.iconM,
            ),
            const SizedBox(width: AppConstants.spacingS),
          ],
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color ?? theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game grid cell widget
class GameGridCell extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  const GameGridCell({
    super.key,
    required this.value,
    this.onTap,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.size = AppConstants.gameCellSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: value.isEmpty ? 'Empty game cell' : 'Game cell with $value',
      button: true,
      enabled: isEnabled && value.isEmpty,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.gameGridColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: isEnabled
                    ? Colors.transparent
                    : theme.gameGridDisabledColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.fontDisplay,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? _getTextColor(value, theme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(String value, ThemeData theme) {
    switch (value) {
      case 'X':
        return theme.playerXColor;
      case 'O':
        return theme.playerOColor;
      default:
        return theme.textTheme.bodyLarge?.color ?? Colors.black;
    }
  }
}

/// Custom app bar with consistent styling
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GameAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? horizontal;
  final double? vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal,
    this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust padding based on screen size
    double horizontalPadding = horizontal ?? AppConstants.spacingL;
    if (screenWidth > 600) {
      horizontalPadding = horizontalPadding * 2;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: vertical ?? AppConstants.spacingM,
      ),
      child: child,
    );
  }
}
