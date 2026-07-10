import 'package:flutter_riverpod/legacy.dart';

import '../data/missions_repository.dart';
import '../data/progress_repository.dart';
import '../domain/mission.dart';
import 'repository_providers.dart';

class MissionProgressView {
  final int progress;
  final bool claimed;

  const MissionProgressView(this.progress, this.claimed);
}

class MissionUiEntry {
  final MissionDef def;
  final MissionProgressView progress;

  const MissionUiEntry(this.def, this.progress);

  bool get isComplete => progress.progress >= def.target;
}

class MissionsState {
  final List<MissionUiEntry> missions;

  const MissionsState(this.missions);
}

class MissionsNotifier extends StateNotifier<MissionsState> {
  final MissionsRepository _repo;
  final ProgressRepository _progressRepo;

  MissionsNotifier(this._repo, this._progressRepo)
    : super(const MissionsState([])) {
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.getTodaysMissions();
    state = MissionsState(
      list
          .map(
            (m) => MissionUiEntry(
              m.def,
              MissionProgressView(m.progress, m.claimed),
            ),
          )
          .toList(),
    );
  }

  Future<void> claimReward(int index) async {
    final entry = state.missions[index];
    if (!entry.isComplete || entry.progress.claimed) return;
    await _repo.claim(entry.def.type);
    await _progressRepo.addCoins(entry.def.coinReward);
    await _load();
  }

  Future<void> reportProgress(MissionType type, int value) async {
    await _repo.updateProgress(type, value);
    await _load();
  }
}

final missionsProvider = StateNotifierProvider<MissionsNotifier, MissionsState>(
  (ref) {
    return MissionsNotifier(
      ref.watch(missionsRepositoryProvider),
      ref.watch(progressRepositoryProvider),
    );
  },
);
