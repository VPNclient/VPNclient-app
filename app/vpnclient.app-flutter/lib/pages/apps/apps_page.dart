import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_icons.dart';
import '../../design/app_spacing.dart';
import '../../design/widgets/surface_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/split_tunnel_provider.dart';

enum SplitMode { off, bypass, only }

/// Apps screen — split-tunneling rules. Off / Bypass listed / Only listed,
/// then a search field and a list of installed apps with a per-app switch.
class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<SplitTunnelProvider>();

    final apps = prov.apps.where((a) {
      if (_query.isEmpty) return true;
      return a.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      children: [
        const SizedBox(height: AppSpacing.xs),
        _ModeSegment(
          mode: prov.mode,
          onChanged: prov.setMode,
        ),
        if (prov.mode == SplitMode.off)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: _Hint(text: l.split_off_hint),
          )
        else ...[
          const SizedBox(height: AppSpacing.sm),
          _SearchField(onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: AppSpacing.sm),
          _AppRow(
            iconWidget: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apps_rounded, color: Colors.white),
            ),
            title: l.all_apps,
            subtitle: null,
            value: prov.allEnabled,
            onChanged: prov.toggleAll,
          ),
          for (final a in apps)
            _AppRow(
              iconWidget: _AppIcon(name: a.name, color: a.color),
              title: a.name,
              subtitle: a.packageName,
              value: prov.isEnabled(a.packageName),
              onChanged: (v) => prov.toggle(a.packageName, v),
            ),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final SplitMode mode;
  final ValueChanged<SplitMode> onChanged;
  const _ModeSegment({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      (SplitMode.off, l.split_off),
      (SplitMode.bypass, l.split_bypass),
      (SplitMode.only, l.split_only),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          for (final it in items)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(it.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: mode == it.$1 ? AppColors.brandGradient : null,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    it.$2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mode == it.$1
                          ? Colors.white
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(children: [
        const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: l.search,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AppRow extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AppRow({
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(width: 36, height: 36, child: iconWidget),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ]
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Real brand icon where the catalog has one (see [AppIcons]); falls back to
/// a colored letter avatar (e.g. "Telegram" has no shipped brand asset).
class _AppIcon extends StatelessWidget {
  final String name;
  final Color color;
  const _AppIcon({required this.name, required this.color});
  @override
  Widget build(BuildContext context) {
    final asset = AppIcons.forName(name);
    if (asset == null) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        alignment: Alignment.center,
        child: Text(
          name[0],
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      );
    }
    final child = asset.endsWith('.svg')
        ? SvgPicture.asset(asset, width: 36, height: 36, fit: BoxFit.cover)
        : Image.asset(asset, width: 36, height: 36, fit: BoxFit.cover);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: child,
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      child: Row(children: [
        const Icon(Icons.info_outline_rounded,
            color: AppColors.textMuted, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted))),
      ]),
    );
  }
}
