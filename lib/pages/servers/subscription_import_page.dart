import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/subscription_provider.dart';

/// Subscription import sheet — modelled on v2rayNG/Hiddify/Happ. Three
/// methods (URL / QR / file), a name field, and an auto-update toggle.
/// Lives as a bottom sheet so server selection isn't lost on cancel.
class SubscriptionImportPage extends StatefulWidget {
  const SubscriptionImportPage({super.key});

  @override
  State<SubscriptionImportPage> createState() => _SubscriptionImportPageState();
}

enum _Method { url, qr, file }
enum _ImportState { idle, fetching, success, error }

class _SubscriptionImportPageState extends State<SubscriptionImportPage> {
  _Method _method = _Method.url;
  _ImportState _state = _ImportState.idle;
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _autoUpdate = true;
  String? _errorMessage;
  int _importedCount = 0;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) _urlCtrl.text = data!.text!;
  }

  Future<void> _doImport() async {
    if (_urlCtrl.text.trim().isEmpty) return;
    setState(() => _state = _ImportState.fetching);
    try {
      final n = await context.read<SubscriptionProvider>().importFromUrl(
            url: _urlCtrl.text.trim(),
            name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
            autoUpdate: _autoUpdate,
          );
      if (!mounted) return;
      setState(() {
        _state = _ImportState.success;
        _importedCount = n;
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _state = _ImportState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final canImport = _urlCtrl.text.trim().isNotEmpty &&
        _state != _ImportState.fetching;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      l.add_subscription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.sm,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                children: [
                  _MethodSegment(
                    method: _method,
                    onChanged: (m) => setState(() => _method = m),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _UrlField(
                    controller: _urlCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    _Chip(
                      icon: Icons.content_paste_rounded,
                      label: l.paste,
                      onTap: () async { await _paste(); setState(() {}); },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _Chip(
                      icon: Icons.qr_code_scanner_rounded,
                      label: l.scan_qr,
                      onTap: () {
                        // TODO: open camera scanner; on success, set _urlCtrl.
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _FieldLabel(text: l.display_name_optional),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Hiddify · Public',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AutoUpdateRow(
                    value: _autoUpdate,
                    onChanged: (v) => setState(() => _autoUpdate = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_state == _ImportState.success)
                    _Toast(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      text: l.servers_imported(_importedCount),
                    ),
                  if (_state == _ImportState.error)
                    _Toast(
                      icon: Icons.error_outline_rounded,
                      color: AppColors.danger,
                      text: _errorMessage ?? 'Import failed',
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                0,
                AppSpacing.pageGutter,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  if (_state == _ImportState.fetching)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: LinearProgressIndicator(
                        backgroundColor: Color(0x2900C6FB),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: canImport ? AppColors.brandGradient : null,
                        color: canImport ? null : const Color(0xFFC8D4DC),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: canImport
                            ? [
                                BoxShadow(
                                  color: AppColors.brandBlue
                                      .withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          onTap: canImport ? _doImport : null,
                          child: Center(
                            child: Text(
                              _state == _ImportState.fetching
                                  ? l.fetching_servers
                                  : l.import_subscription,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodSegment extends StatelessWidget {
  final _Method method;
  final ValueChanged<_Method> onChanged;
  const _MethodSegment({required this.method, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final items = [
      (_Method.url, 'URL'),
      (_Method.qr, l.scan_qr),
      (_Method.file, 'File'),
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
                    gradient: method == it.$1 ? AppColors.brandGradient : null,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    it.$2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: method == it.$1
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

class _UrlField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _UrlField({required this.controller, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          hintText: 'https://sub.example.com/v2/...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          labelText: l.subscription_url,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.primary)),
          ]),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted)),
    );
  }
}

class _AutoUpdateRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AutoUpdateRow({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.auto_update, style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(l.auto_update_hint,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _Toast extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Toast({required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}
