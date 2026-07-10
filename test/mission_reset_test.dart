import 'package:flutter_test/flutter_test.dart';
import 'package:snake_evolution/domain/mission.dart';

void main() {
  group('Mission daily reset (pure functions)', () {
    test('shouldResetMissions is true when no prior date stored', () {
      expect(shouldResetMissions(null, DateTime(2026, 7, 6)), isTrue);
    });

    test('shouldResetMissions is false for same calendar day', () {
      final today = DateTime(2026, 7, 6, 23, 59);
      final storedKey = dateKey(DateTime(2026, 7, 6, 0, 1));
      expect(shouldResetMissions(storedKey, today), isFalse);
    });

    test('shouldResetMissions is true once the day changes', () {
      final storedKey = dateKey(DateTime(2026, 7, 5));
      expect(shouldResetMissions(storedKey, DateTime(2026, 7, 6)), isTrue);
    });

    test('selectDailyMissions is deterministic for the same date', () {
      final a = selectDailyMissions(DateTime(2026, 7, 6));
      final b = selectDailyMissions(DateTime(2026, 7, 6));
      expect(a.map((m) => m.description), b.map((m) => m.description));
    });

    test('selectDailyMissions returns the requested count', () {
      final missions = selectDailyMissions(DateTime(2026, 7, 6), count: 2);
      expect(missions.length, 2);
    });
  });
}
