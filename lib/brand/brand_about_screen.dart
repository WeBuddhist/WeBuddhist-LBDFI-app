import 'package:flutter/material.dart';
import 'package:flutter_pecha/brand/brand.dart';
import 'package:flutter_pecha/core/constants/app_assets.dart';
import 'package:flutter_pecha/core/l10n/generated/app_localizations.dart';
import 'package:flutter_pecha/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// LBDFI's About page, used in place of WeBuddhist's: the emblem, the
/// organisation's full name, its own description and links, and one
/// "Powered by WeBuddhist" line at the foot.
class BrandAboutScreen extends StatelessWidget {
  const BrandAboutScreen({super.key});

  static const List<_Link> _links = [
    _Link(
      icon: AppAssets.globe,
      title: 'Website',
      subtitle: Brand.websiteLabel,
      url: Brand.websiteUrl,
    ),
    _Link(
      icon: AppAssets.facebook,
      title: 'Facebook',
      subtitle: 'facebook.com/LBDFI',
      url: Brand.facebookUrl,
    ),
    _Link(
      icon: AppAssets.youtube,
      title: 'YouTube',
      subtitle: '@LBDFIOnline',
      url: Brand.youtubeUrl,
    ),
    _Link(
      icon: PhosphorIconsRegular.envelopeSimple,
      title: 'Email',
      subtitle: Brand.email,
      url: 'mailto:${Brand.email}',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(AppAssets.arrowLeft),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        title: Text(
          l10n.about_title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  AppAssets.weBuddhistLogo,
                  width: 112,
                  height: 112,
                  semanticLabel: Brand.appName,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Brand.fullName,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Brand.appName,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              for (final paragraph in Brand.aboutParagraphs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    paragraph,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                l10n.about_connect_with_us,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              for (final link in _links) _LinkTile(link: link, isDark: isDark),
              const SizedBox(height: 40),
              Text(
                'Powered by ${Brand.platformName}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.link, required this.isDark});

  final _Link link;
  final bool isDark;

  Future<void> _open() async {
    final uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: _open,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(link.icon, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        link.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  AppAssets.arrowSquareOut,
                  size: 20,
                  color: AppColors.grey600,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.cardBorderDark : AppColors.grey100,
          ),
        ],
      ),
    );
  }
}

class _Link {
  const _Link({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
}
