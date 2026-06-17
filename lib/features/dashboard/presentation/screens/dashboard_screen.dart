import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/core/utils/app_utils.dart';
import 'package:kututakip/features/backup/presentation/screens/backup_screen.dart';
import 'package:kututakip/features/box/presentation/screens/box_list_screen.dart';
import 'package:kututakip/providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxStatsAsync = ref.watch(boxStatisticsProvider);
    final fragileCountAsync = ref.watch(_fragileCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            boxStatsAsync.when(
              data: (stats) => _buildStatisticsGrid(context, stats, fragileCountAsync),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Hata: $error'),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            _buildQuickActionsSection(context),
            const SizedBox(height: 32),

            // Recent Boxes
            _buildRecentBoxesSection(context, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BoxListScreen(),
            ),
          );
        },
        tooltip: AppConstants.newBoxTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, Map<String, dynamic> stats, AsyncValue<int> fragileCount) {
    final totalBoxes = (stats['totalBoxes'] as int?) ?? 0;
    final movedBoxes = (stats['movedBoxes'] as int?) ?? 0;
    final pendingBoxes = (stats['pendingBoxes'] as int?) ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Total Boxes Card
        _buildStatCard(
          title: 'Toplam Kutular',
          value: totalBoxes.toString(),
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),

        // Moved Boxes Card
        _buildStatCard(
          title: AppConstants.statusMoved,
          value: movedBoxes.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),

        // Pending Boxes Card
        _buildStatCard(
          title: AppConstants.statusPending,
          value: pendingBoxes.toString(),
          icon: Icons.schedule,
          color: Colors.orange,
        ),

        // Fragile Items Card
        fragileCount.when(
          data: (count) => _buildStatCard(
            title: 'Kırılgan Eşyalar',
            value: count.toString(),
            icon: Icons.warning,
            color: Colors.red,
          ),
          loading: () => _buildStatCard(
            title: 'Kırılgan Eşyalar',
            value: '...',
            icon: Icons.warning,
            color: Colors.red,
          ),
          error: (_, __) => _buildStatCard(
            title: 'Kırılgan Eşyalar',
            value: '0',
            icon: Icons.warning,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 0, bottom: 12),
          child: Text(
            'Hızlı İşlemler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BoxListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_box),
                label: const Text(AppConstants.newBoxTitle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.backup),
                label: const Text(AppConstants.backupAction),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBoxesSection(BuildContext context, WidgetRef ref) {
    final allBoxesAsync = ref.watch(allBoxesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Son Kutular',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        allBoxesAsync.when(
          data: (boxes) {
            if (boxes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    AppConstants.noBoxesMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            final recentBoxes = boxes.length > 5 ? boxes.sublist(0, 5) : boxes;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentBoxes.length,
              itemBuilder: (context, index) {
                final box = recentBoxes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(box.boxNumber),
                    ),
                    title: Text(box.title),
                    subtitle: Text(
                      '${box.destination} • ${box.status}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      box.status == AppConstants.statusMoved
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: box.status == AppConstants.statusMoved
                          ? Colors.green
                          : Colors.orange,
                    ),
                    onTap: () {
                      // TODO: Navigate to box detail screen
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Hata: $error'),
          ),
        ),
      ],
    );
  }
}

/// Provider to get total fragile item count across all boxes
final _fragileCountProvider = FutureProvider<int>((ref) async {
  final allBoxes = await ref.watch(allBoxesProvider.future);
  int totalFragile = 0;

  for (final box in allBoxes) {
    final fragileCount = await ref.watch(fragileItemCountProvider(box.id ?? 0).future);
    totalFragile += fragileCount;
  }

  return totalFragile;
});
