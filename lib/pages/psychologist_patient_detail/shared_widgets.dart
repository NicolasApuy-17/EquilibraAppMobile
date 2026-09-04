import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text, {super.key, this.icon = Icons.inbox_outlined});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26.0, color: theme.secondaryText),
            const SizedBox(height: 8.0),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                font: GoogleFonts.outfit(),
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of an infinite spinner when a stream/future genuinely
/// fails (as opposed to just being empty) -- every async section in the
/// patient detail screen must check this before `!snapshot.hasData`, or a
/// real error looks identical to "still loading" forever.
class AsyncErrorHint extends StatelessWidget {
  const AsyncErrorHint({super.key, this.text = 'No se pudo cargar esta información.'});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20.0, color: theme.error),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                text,
                style: theme.bodySmall.override(
                  font: GoogleFonts.outfit(),
                  color: theme.error,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves an [AsyncSnapshot] into loading/error/data states in the one
/// order every async section here needs -- error checked *before*
/// `!hasData`, so a genuine failure can never be mistaken for "still
/// loading" and spin forever.
Widget asyncSection<T>(
  AsyncSnapshot<T> snapshot,
  Widget Function(T data) builder, {
  String errorText = 'No se pudo cargar esta información.',
}) {
  if (snapshot.hasError) return AsyncErrorHint(text: errorText);
  if (!snapshot.hasData) return const LoadingRow();
  return builder(snapshot.data as T);
}

class LoadingRow extends StatelessWidget {
  const LoadingRow({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: LinearProgressIndicator(),
      );
}

class ChoiceChipRow extends StatelessWidget {
  const ChoiceChipRow({
    super.key,
    required this.options,
    required this.labelBuilder,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String Function(String) labelBuilder;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        for (final option in options)
          InkWell(
            onTap: () => onSelected(option),
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
              decoration: BoxDecoration(
                color: selected == option
                    ? FlutterFlowTheme.of(context).primary10
                    : FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: selected == option
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).alternate,
                ),
              ),
              child: Text(
                labelBuilder(option),
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: selected == option
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 140.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 18.0, color: theme.primary),
          if (icon != null) const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.titleMedium.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              color: theme.primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.bodySmall.override(
              font: GoogleFonts.outfit(),
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 48.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(
                      FlutterFlowTheme.of(context).onPrimary),
                ),
              )
            : Text(
                label,
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).onPrimary,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.outfit(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 4.0),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
