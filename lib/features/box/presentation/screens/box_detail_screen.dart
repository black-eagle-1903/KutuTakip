import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/features/item/presentation/widgets/item_management_section.dart';
import 'package:kututakip/features/photo/presentation/widgets/photo_management_section.dart';
import 'package:kututakip/providers/app_providers.dart';

class BoxDetailScreen extends ConsumerWidget {
  final int boxId;

  const BoxDetailScreen({
    Key? key,
    required this.boxId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxAsync = ref.watch(boxByIdProvider(boxId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kutu Detayı'),
        centerTitle: true,
      ),
      body: boxAsync.when(
        data: (box) {
          if (box == null) {
            return const Center(child: Text('Kutu bulunamadı'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Box Metadata Header Card
                _buildBoxHeader(context, ref, box),

                const SizedBox(height: 24),

                // Items Section
                ItemManagementSection(boxId: boxId),

                const SizedBox(height: 24),

                // Photos Section
                PhotoManagementSection(boxId: boxId),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  Widget _buildBoxHeader(BuildContext context, WidgetRef ref, dynamic box) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Box Number and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      box.boxNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      box.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              if (box.description.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Açıklama',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(box.description),
                    const SizedBox(height: 12),
                  ],
                ),

              // Destination & Status Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hedef Konum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          box.destination,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        SegmentedButton<String>(
                          segments: AppConstants.boxStatuses
                              .map((status) => ButtonSegment(
                                    value: status,
                                    label: Text(status),
                                  ))
                              .toList(),
                          selected: <String>{box.status},
                          onSelectionChanged: (Set<String> newSelection) {
                            final mutation =
                                ref.read(boxMutationProvider.notifier);
                            mutation.updateBox(
                              id: box.id,
                              title: box.title,
                              description: box.description,
                              destination: box.destination,
                              status: newSelection.first,
                              notes: box.notes,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              if (box.notes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notlar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(box.notes),
                    const SizedBox(height: 12),
                  ],
                ),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, ref, box.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Kutuyu Sil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    int boxId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kutuyu Sil'),
        content: const Text(
          'Bu kutuyu silmek istediğinizden emin misiniz? Tüm eşyalar ve fotoğraflar da silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppConstants.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              final mutation = ref.read(boxMutationProvider.notifier);
              await mutation.deleteBox(boxId);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to box list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppConstants.deleteSuccessMessage),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(AppConstants.deleteButton),
          ),
        ],
      ),
    );
  }
}
