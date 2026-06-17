import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/core/utils/app_utils.dart';
import 'package:kututakip/providers/app_providers.dart';

/// Widget to manage items in a box (add, list, delete)
class ItemManagementSection extends ConsumerStatefulWidget {
  final int boxId;

  const ItemManagementSection({
    Key? key,
    required this.boxId,
  }) : super(key: key);

  @override
  ConsumerState<ItemManagementSection> createState() =>
      _ItemManagementSectionState();
}

class _ItemManagementSectionState extends ConsumerState<ItemManagementSection> {
  bool _showForm = false;
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  bool _fragile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsByBoxIdProvider(widget.boxId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppConstants.itemsLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showForm = !_showForm;
                  });
                },
                icon: Icon(_showForm ? Icons.close : Icons.add),
                label: Text(_showForm ? 'İptal' : AppConstants.addItemAction),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add Item Form (shown when _showForm is true)
          if (_showForm) _buildAddItemForm(),

          const SizedBox(height: 16),

          // Items List
          itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      AppConstants.noItemsMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (item.fragile)
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red[700],
                              size: 20,
                            )
                          else
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Miktar: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (item.notes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.notes,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          ref
                              .read(itemMutationProvider.notifier)
                              .deleteItem(item.id ?? 0, widget.boxId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(AppConstants.deleteSuccessMessage),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        tooltip: AppConstants.deleteButton,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(AppConstants.errorMessage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemForm() {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Item Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Eşya Adı',
                hintText: 'Örn: Yastık, Çarşaf',
              ),
            ),
            const SizedBox(height: 12),

            // Quantity & Fragile Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: AppConstants.quantityLabel,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppConstants.fragileLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Checkbox(
                        value: _fragile,
                        onChanged: (value) {
                          setState(() {
                            _fragile = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: AppConstants.notesLabel,
                hintText: 'Ekstra bilgi...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showForm = false;
                      });
                      _resetForm();
                    },
                    child: const Text(AppConstants.cancelButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final quantity = int.tryParse(_quantityController.text);
                      if (_nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Eşya adı boş olamaz'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      if (quantity == null || quantity < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Miktar geçersiz'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      ref.read(itemMutationProvider.notifier).createItem(
                            boxId: widget.boxId,
                            name: _nameController.text,
                            quantity: quantity,
                            notes: _notesController.text,
                            fragile: _fragile,
                          );

                      setState(() {
                        _showForm = false;
                      });
                      _resetForm();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppConstants.createSuccessMessage),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text(AppConstants.addButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _quantityController.text = '1';
    _notesController.clear();
    _fragile = false;
  }
}
