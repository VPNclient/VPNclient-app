import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
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
    final theme = Theme.of(context);

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
              iconWidget: _AppIcon(letter: a.name[0], color: a.color),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
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
    );
  }
}

class _AppIcon extends StatelessWidget {
  final String letter;
  final Color color;
  const _AppIcon({required this.letter, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded,
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
