import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';

class CategoryFormSheet extends StatefulWidget {
  final Category? initial;
  final VoidCallback onSuccess;

  const CategoryFormSheet({
    super.key,
    this.initial,
    required this.onSuccess,
  });

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _net = GetIt.I<INetworkService>();
  final formKey = GlobalKey<FormState>();
  String? name;
  String? description;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      name = widget.initial!.name;
      description = widget.initial!.description;
      isActive = widget.initial!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? 'Yeni Kategori' : 'Kategori Düzenle',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(
                labelText: 'Kategori Adı',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Kategori adı gerekli.' : null,
              onSaved: (v) => name = v?.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(
                labelText: 'Açıklama (İsteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (v) => description = v?.trim().isEmpty == true ? null : v?.trim(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktif'),
              subtitle: const Text('Bu kategori kullanılabilir olsun mu?'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    final currentState = formKey.currentState;
                    if (currentState == null || !currentState.validate()) return;
                    currentState.save();

                    final body = <String, dynamic>{
                      'name': name,
                      if (description != null) 'description': description,
                      'is_active': isActive,
                    };

                    final isEdit = (widget.initial?.id) != null;
                    final categoryId = widget.initial?.id;
                    final path = categoryId != null
                        ? ApiEndpoints.categoryById(categoryId)
                        : ApiEndpoints.categories;
                    final reqType = isEdit ? RequestType.patch : RequestType.post;

                    final res = await _net.request<Category>(
                      path: path,
                      type: reqType,
                      data: body,
                      parser: (json) => Category.fromJson(json as Map<String, dynamic>),
                    );

                    if (!mounted) return;
                    if (!context.mounted) return;

                    if (res.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEdit ? 'Kategori güncellendi.' : 'Kategori oluşturuldu.')),
                      );
                      Navigator.of(context).pop();
                      widget.onSuccess();
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res.error ?? 'İşlem başarısız.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(widget.initial == null ? 'Oluştur' : 'Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}