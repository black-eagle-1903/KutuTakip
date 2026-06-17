import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/features/box/presentation/screens/box_detail_screen.dart';
import 'package:kututakip/providers/app_providers.dart';

/// Notifier to manage search query state
final _searchQueryProvider = StateProvider<String>((ref) => '');

class BoxListScreen extends ConsumerWidget {
  const BoxListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(_searchQueryProvider);
    final boxesAsync = searchQuery.isEmpty
        ? ref.watch(allBoxesProvider)
        : ref.watch(searchBoxesProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.boxesTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              onChanged: (query) {
                ref.read(_searchQueryProvider.notifier).state = query;
              },
              hintText: 'Ara... (kutu no, başlık, hedef)',
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.search),
              ),
              trailing: searchQuery.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref.read(_searchQueryProvider.notifier).state = '';
                          },
                        ),
                      ),
                    ]
                  : [],
            ),
          ),

          // Box List
          Expanded(
            child: boxesAsync.when(
              data: (boxes) {
                if (boxes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        searchQuery.isEmpty
                            ? AppConstants.noBoxesMessage
                            : 'Arama sonucu bulunamadı.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: boxes.length,
                  itemBuilder: (context, index) {
                    final box = boxes[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: box.status == AppConstants.statusMoved
                              ? Colors.green
                              : Colors.orange,
                          child: Text(
                            box.boxNumber.replaceAll('KT-', ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          box.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              box.destination,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  box.status == AppConstants.statusMoved
                                      ? Icons.check_circle
                                      : Icons.schedule,
                                  size: 14,
                                  color: box.status == AppConstants.statusMoved
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  box.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: box.status == AppConstants.statusMoved
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BoxDetailScreen(boxId: box.id ?? 0),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  AppConstants.errorMessage,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewBoxScreen(),
            ),
          );
        },
        tooltip: AppConstants.newBoxTitle,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Screen to create a new box
class NewBoxScreen extends ConsumerWidget {
  const NewBoxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String selectedDestination = AppConstants.predefinedDestinations[0];
    String selectedStatus = AppConstants.statusPending;
    String notes = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.newBoxTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: AppConstants.titleLabel,
                  hintText: 'Örn: Yatak Odası Eşyaları',
                ),
                onChanged: (value) => title = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: AppConstants.descriptionLabel,
                  hintText: 'Kutu içeriği hakkında bilgi',
                ),
                maxLines: 3,
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 16),

              // Destination Dropdown
              DropdownButtonFormField<String>(
                value: selectedDestination,
                decoration: const InputDecoration(
                  labelText: AppConstants.destinationLabel,
                ),
                items: AppConstants.predefinedDestinations
                    .map((dest) => DropdownMenuItem(
                          value: dest,
                          child: Text(dest),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedDestination = value;
                },
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: AppConstants.statusLabel,
                ),
                items: AppConstants.boxStatuses
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedStatus = value;
                },
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: AppConstants.notesLabel,
                  hintText: 'Ekstra notlar...',
                ),
                maxLines: 3,
                onChanged: (value) => notes = value,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppConstants.cancelButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final mutation = ref.read(boxMutationProvider.notifier);
                          await mutation.createBox(
                            title: title,
                            description: description,
                            destination: selectedDestination,
                            status: selectedStatus,
                            notes: notes,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(AppConstants.createSuccessMessage),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(AppConstants.createButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder for BoxDetailScreen (will be implemented next)
class BoxDetailScreen extends StatelessWidget {
  final int boxId;

  const BoxDetailScreen({
    Key? key,
    required this.boxId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kutu Detayı'),
      ),
      body: const Center(
        child: Text('Kutu detayı sayfası (yakında)'),
      ),
    );
  }
}
