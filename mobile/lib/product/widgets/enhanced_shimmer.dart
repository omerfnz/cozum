import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Enhanced shimmer widget with consistent theming and animations
class EnhancedShimmer extends StatelessWidget {
  const EnhancedShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration,
    this.animationType = ShimmerAnimationType.standard,
    this.intensity = ShimmerIntensity.medium,
  });

  final Widget child;
  final bool enabled;
  final Duration? duration;
  final ShimmerAnimationType animationType;
  final ShimmerIntensity intensity;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getShimmerColors(isDark, intensity);
    final animationDuration = _getAnimationDuration(animationType);

    return Shimmer.fromColors(
      baseColor: colors.baseColor,
      highlightColor: colors.highlightColor,
      period: duration ?? animationDuration,
      direction: _getShimmerDirection(animationType),
      child: child,
    );
  }

  ShimmerColors _getShimmerColors(bool isDark, ShimmerIntensity intensity) {
    switch (intensity) {
      case ShimmerIntensity.subtle:
        return isDark
            ? ShimmerColors(
                baseColor: Colors.grey.shade800,
                highlightColor: Colors.grey.shade700,
              )
            : ShimmerColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
              );
      case ShimmerIntensity.medium:
        return isDark
            ? ShimmerColors(
                baseColor: Colors.grey.shade800,
                highlightColor: Colors.grey.shade700,
              )
            : ShimmerColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
              );
      case ShimmerIntensity.strong:
        return isDark
            ? ShimmerColors(
                baseColor: Colors.grey.shade700,
                highlightColor: Colors.grey.shade600,
              )
            : ShimmerColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.white,
              );
    }
  }

  Duration _getAnimationDuration(ShimmerAnimationType type) {
    switch (type) {
      case ShimmerAnimationType.fast:
        return const Duration(milliseconds: 800);
      case ShimmerAnimationType.standard:
        return const Duration(milliseconds: 1200);
      case ShimmerAnimationType.slow:
        return const Duration(milliseconds: 1800);
      case ShimmerAnimationType.pulse:
        return const Duration(milliseconds: 1000);
    }
  }

  ShimmerDirection _getShimmerDirection(ShimmerAnimationType type) {
    switch (type) {
      case ShimmerAnimationType.fast:
      case ShimmerAnimationType.standard:
      case ShimmerAnimationType.slow:
        return ShimmerDirection.ltr;
      case ShimmerAnimationType.pulse:
        return ShimmerDirection.ttb;
    }
  }
}

class ShimmerColors {
  final Color baseColor;
  final Color highlightColor;

  ShimmerColors({
    required this.baseColor,
    required this.highlightColor,
  });
}

enum ShimmerAnimationType {
  fast,
  standard,
  slow,
  pulse,
}

enum ShimmerIntensity {
  subtle,
  medium,
  strong,
}

/// Shimmer skeleton components
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.margin,
    this.gradient,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? defaultColor : null,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12,
    this.widthFactor,
    this.alignment = Alignment.centerLeft,
    this.margin,
  });

  final double? width;
  final double height;
  final double? widthFactor;
  final Alignment alignment;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final line = ShimmerBox(
      height: height, 
      width: width,
      margin: margin,
    );
    
    if (widthFactor != null) {
      return Align(
        alignment: alignment,
        child: FractionallySizedBox(
          widthFactor: widthFactor!,
          child: line,
        ),
      );
    }
    
    return line;
  }
}

class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
    this.border,
  });

  final double size;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: defaultColor,
        shape: BoxShape.circle,
        border: border,
      ),
    );
  }
}

/// Advanced shimmer components
class ShimmerAvatar extends StatelessWidget {
  const ShimmerAvatar({
    super.key,
    this.size = 40,
    this.hasOnlineIndicator = false,
    this.hasBorder = false,
  });

  final double size;
  final bool hasOnlineIndicator;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShimmerCircle(
          size: size,
          border: hasBorder ? Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ) : null,
        ),
        if (hasOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: ShimmerCircle(
              size: size * 0.25,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }
}

class ShimmerButton extends StatelessWidget {
  const ShimmerButton({
    super.key,
    this.width = 120,
    this.height = 40,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }
}

class ShimmerBadge extends StatelessWidget {
  const ShimmerBadge({
    super.key,
    this.width = 60,
    this.height = 24,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
    );
  }
}

class ShimmerImage extends StatelessWidget {
  const ShimmerImage({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.aspectRatio,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? aspectRatio;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final child = ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: child,
      );
    }

    return child;
  }
}

/// Pre-built shimmer layouts
class CardShimmer extends StatelessWidget {
  const CardShimmer({
    super.key,
    this.hasAvatar = true,
    this.hasImage = false,
    this.linesCount = 3,
    this.animationType = ShimmerAnimationType.standard,
    this.intensity = ShimmerIntensity.medium,
  });

  final bool hasAvatar;
  final bool hasImage;
  final int linesCount;
  final ShimmerAnimationType animationType;
  final ShimmerIntensity intensity;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      animationType: animationType,
      intensity: intensity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAvatar)
                Row(
                  children: [
                    const ShimmerAvatar(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerLine(width: 120, height: 14),
                          const SizedBox(height: 4),
                          const ShimmerLine(width: 80, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              if (hasAvatar) const SizedBox(height: 12),
              if (hasImage) ...[
                const ShimmerImage(
                  width: double.infinity,
                  height: 180,
                ),
                const SizedBox(height: 12),
              ],
              ...List.generate(
                linesCount,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index < linesCount - 1 ? 8 : 0),
                  child: ShimmerLine(
                    widthFactor: index == linesCount - 1 ? 0.7 : 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content-specific shimmer layouts
class FeedCardShimmer extends StatelessWidget {
  const FeedCardShimmer({
    super.key,
    this.hasImage = true,
    this.hasTags = true,
    this.hasActions = true,
  });

  final bool hasImage;
  final bool hasTags;
  final bool hasActions;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      animationType: ShimmerAnimationType.standard,
      intensity: ShimmerIntensity.medium,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and user info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const ShimmerAvatar(size: 40),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: double.infinity, height: 14),
                        SizedBox(height: 8),
                        ShimmerLine(width: 120, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ShimmerLine(width: 60, height: 12),
                ],
              ),
            ),
            // Image placeholder
            if (hasImage)
              const ShimmerImage(
                width: double.infinity,
                aspectRatio: 16 / 9,
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const ShimmerLine(widthFactor: 1.0, height: 12),
                  const SizedBox(height: 8),
                  const ShimmerLine(widthFactor: 0.9, height: 12),
                  const SizedBox(height: 8),
                  const ShimmerLine(widthFactor: 0.7, height: 12),
                  if (hasTags) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const ShimmerBadge(width: 80, height: 24),
                        const SizedBox(width: 8),
                        const ShimmerBadge(width: 70, height: 24),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            if (hasActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    const ShimmerButton(width: 80, height: 32),
                    const SizedBox(width: 8),
                    const ShimmerButton(width: 70, height: 32),
                    const Spacer(),
                    const ShimmerLine(width: 40, height: 12),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailShimmer extends StatelessWidget {
  const ReportDetailShimmer({
    super.key,
    this.hasImage = true,
    this.hasComments = true,
  });

  final bool hasImage;
  final bool hasComments;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      animationType: ShimmerAnimationType.slow,
      intensity: ShimmerIntensity.subtle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const ShimmerLine(height: 24, width: 220),
            const SizedBox(height: 12),
            // Status badges
            Row(
              children: [
                const ShimmerBadge(width: 80, height: 24),
                const SizedBox(width: 8),
                const ShimmerBadge(width: 100, height: 24),
                const SizedBox(width: 8),
                const ShimmerBadge(width: 80, height: 24),
              ],
            ),
            const SizedBox(height: 16),
            // Image
            if (hasImage) ...[
              const ShimmerImage(
                height: 200,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
            ],
            // Description
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(height: 14, width: double.infinity),
                SizedBox(height: 8),
                ShimmerLine(height: 14, width: double.infinity),
                SizedBox(height: 8),
                ShimmerLine(height: 14, widthFactor: 0.8),
                SizedBox(height: 16),
              ],
            ),
            // Location info
            Row(
              children: [
                const ShimmerCircle(size: 16),
                const SizedBox(width: 8),
                const ShimmerLine(width: 150, height: 12),
              ],
            ),
            const SizedBox(height: 16),
            // Comments section
            if (hasComments) ...[
              const ShimmerLine(height: 18, width: 100),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerAvatar(size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShimmerLine(width: 80, height: 12),
                            const SizedBox(height: 6),
                            const ShimmerLine(widthFactor: 0.9, height: 11),
                            const SizedBox(height: 4),
                            const ShimmerLine(widthFactor: 0.6, height: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({
    super.key,
    this.hasStats = true,
    this.menuItemsCount = 6,
  });

  final bool hasStats;
  final int menuItemsCount;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      animationType: ShimmerAnimationType.pulse,
      intensity: ShimmerIntensity.medium,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Column(
              children: [
                const ShimmerAvatar(
                  size: 100,
                  hasBorder: true,
                ),
                const SizedBox(height: 16),
                const ShimmerLine(width: 150, height: 18),
                const SizedBox(height: 8),
                const ShimmerLine(width: 200, height: 14),
                const SizedBox(height: 16),
              ],
            ),
            // Stats
            if (hasStats) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    children: [
                      ShimmerLine(width: 40, height: 20),
                      SizedBox(height: 4),
                      ShimmerLine(width: 60, height: 12),
                    ],
                  ),
                  const Column(
                    children: [
                      ShimmerLine(width: 40, height: 20),
                      SizedBox(height: 4),
                      ShimmerLine(width: 60, height: 12),
                    ],
                  ),
                  const Column(
                    children: [
                      ShimmerLine(width: 40, height: 20),
                      SizedBox(height: 4),
                      ShimmerLine(width: 60, height: 12),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Menu items
            ...List.generate(
              menuItemsCount,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const ShimmerBox(width: 24, height: 24),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: ShimmerLine(width: double.infinity, height: 14),
                        ),
                        const SizedBox(width: 16),
                        const ShimmerBox(width: 20, height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormShimmer extends StatelessWidget {
  const FormShimmer({
    super.key,
    this.fieldsCount = 4,
    this.hasImagePicker = false,
    this.hasSubmitButton = true,
  });

  final int fieldsCount;
  final bool hasImagePicker;
  final bool hasSubmitButton;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      animationType: ShimmerAnimationType.fast,
      intensity: ShimmerIntensity.strong,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form fields
            ...List.generate(
              fieldsCount,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLine(width: 100, height: 14),
                    const SizedBox(height: 8),
                    ShimmerBox(
                      width: double.infinity,
                      height: index == fieldsCount - 1 ? 100 : 56, // Last field is textarea
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ),
            // Image picker
            if (hasImagePicker) ...[
              const ShimmerLine(width: 120, height: 14),
              const SizedBox(height: 8),
              const ShimmerImage(
                width: double.infinity,
                height: 180,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: ShimmerButton(
                      width: double.infinity,
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: ShimmerButton(
                      width: double.infinity,
                      height: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Submit button
            if (hasSubmitButton)
              const ShimmerButton(
                width: double.infinity,
                height: 48,
              ),
          ],
        ),
      ),
    );
  }
}

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
  });

  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      child: ListTile(
        leading: hasLeading ? const ShimmerCircle(size: 40) : null,
        title: const ShimmerLine(width: 150, height: 14),
        subtitle: subtitleLines > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  subtitleLines,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 6 : 4,
                      bottom: index < subtitleLines - 1 ? 4 : 0,
                    ),
                    child: ShimmerLine(
                      widthFactor: index == subtitleLines - 1 ? 0.6 : 0.9,
                      height: 12,
                    ),
                  ),
                ),
              )
            : null,
        trailing: hasTrailing
            ? const Icon(Icons.chevron_right, color: Colors.white)
            : null,
      ),
    );
  }
}

class LoadingIndicatorShimmer extends StatelessWidget {
  const LoadingIndicatorShimmer({
    super.key,
    this.type = LoadingType.dots,
  });

  final LoadingType type;

  @override
  Widget build(BuildContext context) {
    return EnhancedShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildLoadingContent(),
        ),
      ),
    );
  }

  List<Widget> _buildLoadingContent() {
    switch (type) {
      case LoadingType.dots:
        return [
          const ShimmerCircle(size: 8),
          const SizedBox(width: 8),
          const ShimmerCircle(size: 8),
          const SizedBox(width: 8),
          const ShimmerCircle(size: 8),
        ];
      case LoadingType.bars:
        return [
          const ShimmerBox(width: 40, height: 8),
          const SizedBox(width: 8),
          const ShimmerBox(width: 40, height: 8),
          const SizedBox(width: 8),
          const ShimmerBox(width: 40, height: 8),
        ];
      case LoadingType.pulse:
        return [
          const ShimmerBox(
            width: 120,
            height: 8,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ];
      case LoadingType.wave:
        return [
          const ShimmerBox(width: 4, height: 16),
          const SizedBox(width: 4),
          const ShimmerBox(width: 4, height: 24),
          const SizedBox(width: 4),
          const ShimmerBox(width: 4, height: 20),
          const SizedBox(width: 4),
          const ShimmerBox(width: 4, height: 28),
          const SizedBox(width: 4),
          const ShimmerBox(width: 4, height: 16),
        ];
      case LoadingType.bounce:
        return [
          const ShimmerCircle(size: 12),
          const SizedBox(width: 6),
          const ShimmerCircle(size: 10),
          const SizedBox(width: 6),
          const ShimmerCircle(size: 14),
          const SizedBox(width: 6),
          const ShimmerCircle(size: 10),
          const SizedBox(width: 6),
          const ShimmerCircle(size: 12),
        ];
    }
  }
}

enum LoadingType { dots, bars, pulse, wave, bounce }

/// Shimmer list builders
class ShimmerListView extends StatelessWidget {
  const ShimmerListView({
    super.key,
    required this.itemBuilder,
    this.itemCount = 6,
    this.padding,
    this.separatorHeight = 8,
  });

  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double separatorHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: separatorHeight),
      itemBuilder: itemBuilder,
    );
  }
}

class TeamsShimmer extends StatelessWidget {
  const TeamsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerListView(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const ShimmerCircle(size: 40),
              title: const ShimmerLine(width: 120, height: 16),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const ShimmerLine(width: 80, height: 12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const ShimmerCircle(size: 16),
                      const SizedBox(width: 4),
                      const Expanded(
                        flex: 2,
                        child: ShimmerLine(height: 12),
                      ),
                      const SizedBox(width: 8),
                      const ShimmerCircle(size: 16),
                      const SizedBox(width: 2),
                      const Expanded(
                        flex: 3,
                        child: ShimmerLine(height: 12),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerListView(
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ListTileShimmer(
          hasLeading: true,
          hasTrailing: true,
          subtitleLines: 2,
        );
      },
    );
  }
}

class CreateReportShimmer extends StatelessWidget {
  const CreateReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const FormShimmer(
      fieldsCount: 4,
      hasImagePicker: true,
      hasSubmitButton: true,
    );
  }
}

class LoadingMoreShimmer extends StatelessWidget {
  const LoadingMoreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingIndicatorShimmer(
      type: LoadingType.bars,
    );
  }
}

class CommentsShimmer extends StatelessWidget {
  const CommentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return const ListTileShimmer(
          hasLeading: true,
          hasTrailing: false,
          subtitleLines: 2,
        );
      },
    );
  }
}