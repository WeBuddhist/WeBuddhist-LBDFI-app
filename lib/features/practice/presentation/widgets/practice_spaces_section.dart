import 'package:flutter/material.dart';
import 'package:flutter_pecha/core/error/failures.dart';
import 'package:flutter_pecha/core/extensions/context_ext.dart';
import 'package:flutter_pecha/features/group_profile/domain/entities/group_practice.dart';
import 'package:flutter_pecha/features/practice/domain/entities/chant_book.dart';
import 'package:flutter_pecha/features/practice/presentation/providers/chants_page_providers.dart';
import 'package:flutter_pecha/features/practice/presentation/providers/practice_spaces_providers.dart';
import 'package:flutter_pecha/features/practice/presentation/screens/chant_books_see_all_screen.dart';
import 'package:flutter_pecha/features/practice/presentation/utils/chants_page_actions.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/chants/chant_book_card.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_section_container.dart';
import 'package:flutter_pecha/features/practice/presentation/widgets/practice_space_cards.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

List<T> _valueOr<T>(AsyncValue<Either<Failure, List<T>>> value) =>
    value.valueOrNull?.getOrElse((_) => <T>[]) ?? <T>[];

/// Joined-space practices for one row; empty while loading or on failure.
final _joinedRowProvider = Provider.autoDispose
    .family<List<GroupPractice>, PracticeSpaceRow>((ref, row) {
      return _valueOr(
        ref.watch(practiceSpacePracticesProvider((row: row, joined: true))),
      );
    });

/// Chant books from the spaces the user joined (or the rest).
final practiceSpaceChantBooksProvider = Provider.autoDispose
    .family<List<ChantBook>, bool>((ref, joined) {
      final books = ref.watch(spaceChantBooksProvider).valueOrNull;
      return books?.fold(
            (_) => const <ChantBook>[],
            (books) => joined ? books.yours : books.others,
          ) ??
          const <ChantBook>[];
    });

/// Whether "From your spaces" has anything to show. The Practice tab uses
/// it to choose between the simple layout and the grouped one.
final practiceHasJoinedSpaceContentProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(_joinedRowProvider(PracticeSpaceRow.plans)).isNotEmpty ||
      ref
          .watch(_joinedRowProvider(PracticeSpaceRow.accumulations))
          .isNotEmpty ||
      ref.watch(practiceSpaceChantBooksProvider(true)).isNotEmpty;
});

/// "From your spaces": plans, chant books and accumulations from the
/// spaces the user joined. Rows with nothing in them are left out, and so
/// is the whole group when every row is empty.
class PracticeSpacesSection extends ConsumerWidget {
  const PracticeSpacesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final plans = ref.watch(_joinedRowProvider(PracticeSpaceRow.plans));
    final books = ref.watch(practiceSpaceChantBooksProvider(true));
    final accumulations = ref.watch(
      _joinedRowProvider(PracticeSpaceRow.accumulations),
    );
    if (plans.isEmpty && books.isEmpty && accumulations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PracticeGroupHeading(title: l10n.practice_from_your_spaces),
        if (plans.isNotEmpty)
          PracticeSectionContainer(
            title: l10n.home_shortcut_plans,
            isSubsection: true,
            child: PracticeSpacePlanRail(practices: plans),
          ),
        if (books.isNotEmpty)
          PracticeSectionContainer(
            title: l10n.home_chants,
            isSubsection: true,
            seeAllLabel: l10n.see_all,
            onSeeAll:
                () =>
                    openChantBooksSeeAll(context, ChantBooksSeeAll.yourSpaces),
            child: PracticeChantBookRail(
              books: books.take(practiceSpacePreviewLimit).toList(),
            ),
          ),
        if (accumulations.isNotEmpty)
          PracticeSectionContainer(
            title: l10n.practice_space_accumulations,
            isSubsection: true,
            child: PracticeSpaceAccumulatorRail(practices: accumulations),
          ),
      ],
    );
  }
}

void openChantBooksSeeAll(BuildContext context, ChantBooksSeeAll list) {
  Navigator.of(context).push(
    MaterialPageRoute(
      settings: const RouteSettings(name: 'chant-books-see-all'),
      builder: (_) => ChantBooksSeeAllScreen(list: list),
    ),
  );
}

/// Height of a rail of [PracticeSpacePlanCard]s and catalog plan cards at
/// the device's text size.
double practicePlanRailHeight(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context);
  final height = PracticeSpacePlanCard.imageHeight + 30 + scaler.scale(60);
  return height < 240 ? 240 : height;
}

/// Space plans and series in a horizontal rail.
class PracticeSpacePlanRail extends StatelessWidget {
  const PracticeSpacePlanRail({super.key, required this.practices});

  final List<GroupPractice> practices;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: practicePlanRailHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: practices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder:
            (context, index) => Align(
              alignment: Alignment.topCenter,
              child: PracticeSpacePlanCard(practice: practices[index]),
            ),
      ),
    );
  }
}

/// Space accumulations in a horizontal rail.
class PracticeSpaceAccumulatorRail extends StatelessWidget {
  const PracticeSpaceAccumulatorRail({super.key, required this.practices});

  final List<GroupPractice> practices;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final withBodies = [
      for (final practice in practices)
        if (practice.accumulator != null) practice,
    ];
    return SizedBox(
      height:
          PracticeSpaceAccumulatorCard.railImageHeight + 34 + scaler.scale(90),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: withBodies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final practice = withBodies[index];
          return Align(
            alignment: Alignment.topCenter,
            child: PracticeSpaceAccumulatorCard(
              practice: practice,
              accumulator: practice.accumulator!,
            ),
          );
        },
      ),
    );
  }
}

/// Space chant books in a horizontal rail, as on the Chants page.
class PracticeChantBookRail extends ConsumerWidget {
  const PracticeChantBookRail({super.key, required this.books});

  final List<ChantBook> books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: ChantBookCard.railHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          return Align(
            alignment: Alignment.topCenter,
            child: ChantBookCard(
              name: book.name,
              chantCount: book.chantCount,
              subtitle: book.subtitle,
              imageUrl: book.imageUrl ?? book.groupAvatarUrl,
              hasAudio: book.hasAudio,
              onTap: () => openChantBook(context, ref, book),
            ),
          );
        },
      ),
    );
  }
}
