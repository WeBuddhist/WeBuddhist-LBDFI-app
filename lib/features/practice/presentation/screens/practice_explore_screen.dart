import 'package:flutter/material.dart';
import 'package:flutter_pecha/core/config/locale/locale_notifier.dart';
import 'package:flutter_pecha/core/constants/app_assets.dart';
import 'package:flutter_pecha/core/extensions/context_ext.dart';
import 'package:flutter_pecha/features/auth/presentation/providers/state_providers.dart';
import 'package:flutter_pecha/features/auth/presentation/widgets/login_drawer.dart';
import 'package:flutter_pecha/features/practice/presentation/providers/chants_page_providers.dart';
import 'package:flutter_pecha/features/practice/presentation/providers/practice_explore_providers.dart';
import 'package:flutter_pecha/features/practice/presentation/providers/practice_spaces_providers.dart';
import 'package:flutter_pecha/features/practice/presentation/providers/routine_api_providers.dart';
import 'package:flutter_pecha/features/practice/presentation/screens/practice_search_screen.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_accumulations_section.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_chants_section.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_next_session_section.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_plans_section.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_section_container.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_shortcut_buttons.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_spaces_section.dart';
import 'package:flutter_pecha/shared/widgets/main_tab_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Practice tab.
///
/// With a routine or joined spaces it is grouped: the next routine session,
/// Mala and Timer, "From your spaces", then "Discover more" (the catalog
/// and spaces the user has not joined). Without either it is just the
/// discover rows, with Mala and Timer under Plans.
class PracticeExploreScreen extends ConsumerStatefulWidget {
  const PracticeExploreScreen({super.key});

  @override
  ConsumerState<PracticeExploreScreen> createState() =>
      _PracticeExploreScreenState();
}

class _PracticeExploreScreenState extends ConsumerState<PracticeExploreScreen> {
  Future<void> _refreshAll() async {
    final repo = ref.read(practiceExploreRepositoryProvider);
    final language = ref.read(contentLanguageProvider);
    final auth = ref.read(authProvider);
    ref.invalidate(practiceSpacePracticesProvider);
    ref.invalidate(spaceChantBooksProvider);
    await Future.wait([
      repo.refreshSeries(language),
      repo.refreshRecitations(language),
      if (auth.isLoggedIn && !auth.isGuest)
        ref
            .read(routineApiRepositoryProvider)
            .refreshUserRoutine(language: language),
    ]);
  }

  void _openBookmarks() {
    if (ref.read(authProvider).isGuest) {
      LoginDrawer.show(context, ref);
      return;
    }
    context.pushNamed('bookmarks');
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'practice-search'),
        builder: (_) => const PracticeSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: MainTabAppBar(
        title: l10n.nav_practice,
        actions: [
          IconButton(
            tooltip: l10n.bookmarks,
            onPressed: _openBookmarks,
            icon: Icon(
              AppAssets.bookmarkSimple,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            onPressed: _openSearch,
            icon: Icon(
              AppAssets.search,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            for (final child in _sections(context))
              SliverToBoxAdapter(child: child),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context) {
    final routine = ref.watch(userRoutineProvider).valueOrNull;
    final hasRoutine = routine != null && routine.hasItems;
    final hasSpaces = ref.watch(practiceHasJoinedSpaceContentProvider);

    if (!hasRoutine && !hasSpaces) {
      return const [
        PracticePlansSection(),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: PracticeShortcutButtons(),
        ),
        PracticeChantsSection(),
        PracticeAccumulationsSection(),
      ];
    }

    return [
      if (hasRoutine) PracticeNextSessionSection(routine: routine),
      Padding(
        padding: EdgeInsets.only(top: hasRoutine ? 16 : 8),
        child: const PracticeShortcutButtons(),
      ),
      const PracticeSpacesSection(),
      PracticeGroupHeading(title: context.l10n.practice_discover_more),
      const PracticePlansSection(isSubsection: true),
      const PracticeChantsSection(isSubsection: true),
      const PracticeAccumulationsSection(isSubsection: true),
    ];
  }
}
