import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Swipeable "Novedades" feed on the patient home screen: one card per
/// announcement published by *any* registered psychologist in the app, not
/// just the patient's own assigned one -- patients should be able to see
/// what every psychologist is publishing (see the comment on the `news`
/// collection in `firebase/firestore.rules`, which already allows any
/// signed-in user to read any news doc). Renders nothing if no psychologist
/// has published anything yet -- there's no empty state to show here, it
/// just doesn't take up space on the home screen.
class NewsCarouselWidget extends StatefulWidget {
  const NewsCarouselWidget({super.key});

  @override
  State<NewsCarouselWidget> createState() => _NewsCarouselWidgetState();
}

class _NewsCarouselWidgetState extends State<NewsCarouselWidget> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NewsRecord>>(
      // No filter: every patient sees news from every psychologist. Sorting
      // happens client-side below (same tradeoff used elsewhere in this
      // app, see `_fetchPerPatient` in `psychologist_home_widget.dart`) so
      // this doesn't need a composite index either.
      stream: queryNewsRecord(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final news = snapshot.data!
          ..sort((a, b) => (b.createdTime ?? DateTime(0))
              .compareTo(a.createdTime ?? DateTime(0)));
        if (_currentPage >= news.length) {
          _currentPage = 0;
        }

        return Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Novedades',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 190.0,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: news.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8.0),
                    child: _NewsCard(news: news[index]),
                  ),
                ),
              ),
              if (news.length > 1) ...[
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    news.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      width: index == _currentPage ? 18.0 : 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? FlutterFlowTheme.of(context).primary
                            : FlutterFlowTheme.of(context).alternate,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final NewsRecord news;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24.0),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _NewsDetailSheet(news: news),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (news.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: news.imageUrl,
                height: 90.0,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 90.0,
                color: theme.primary.withValues(alpha: 0.08),
                alignment: Alignment.center,
                child: Icon(Icons.campaign_rounded,
                    color: theme.primary, size: 32.0),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Expanded(
                      child: Text(
                        news.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full detail for one news item, opened from [_NewsCard]. Shows the image
/// (if any) at full width, the complete text, and an "Abrir enlace" button
/// when the psychologist attached one.
class _NewsDetailSheet extends StatelessWidget {
  const _NewsDetailSheet({required this.news});

  final NewsRecord news;

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.tryParse(news.linkUrl);
    final opened = uri == null
        ? false
        : await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            if (news.imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  height: 180.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            Text(
              news.title,
              style: theme.titleMedium.override(
                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                color: theme.primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (news.psychologistName.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                'Publicado por ${news.psychologistName}',
                style: theme.bodySmall.override(
                  font: GoogleFonts.outfit(),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ],
            const SizedBox(height: 16.0),
            Text(
              news.content,
              style: theme.bodyMedium.override(
                font: GoogleFonts.outfit(),
                color: theme.primaryText,
                letterSpacing: 0.0,
                lineHeight: 1.5,
              ),
            ),
            if (news.linkUrl.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              InkWell(
                onTap: () => _openLink(context),
                child: Container(
                  height: 48.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded,
                          color: theme.onPrimary, size: 18.0),
                      const SizedBox(width: 8.0),
                      Text(
                        'Abrir enlace',
                        style: theme.labelMedium.override(
                          font:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: theme.onPrimary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
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
