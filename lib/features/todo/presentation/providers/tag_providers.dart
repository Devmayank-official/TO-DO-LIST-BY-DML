import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/todo/domain/entities/tag.dart';
import 'package:dml_hub/features/todo/domain/usecases/tag/create_tag_usecase.dart';

final allTagsProvider = StateProvider<List<Tag>>((ref) => const <Tag>[]);

final createTagProvider = Provider<TagActions>((ref) {
  return TagActions(ref);
});

class TagActions {
  const TagActions(this._ref);

  final Ref _ref;

  Future<void> createTag(CreateTagParams params) async {
    final result = await const CreateTagUseCase().call(params);
    result.fold(
      (failure) => null,
      (tag) {
        final current = _ref.read(allTagsProvider);
        _ref.read(allTagsProvider.notifier).state = [...current, tag];
      },
    );
  }
}
