import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/widgets/enhanced_form_validation.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
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
    _nameController = TextEditingController(text: name);
    _descriptionController = TextEditingController(text: description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
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
            EnhancedTextFormField(
              controller: _nameController,
              labelText: 'Kategori Adı',
              prefixIcon: const Icon(Icons.category_rounded),
              validator: (value) => FormValidators.validateRequired(value, 'Kategori Adı'),
              showRealTimeValidation: true,
              maxLength: 50,
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            const SizedBox(height: 16),
            EnhancedTextFormField(
              controller: _descriptionController,
              labelText: 'Açıklama (İsteğe bağlı)',
              prefixIcon: const Icon(Icons.description_rounded),
              maxLines: 3,
              showRealTimeValidation: true,
              maxLength: 200,
              onChanged: (value) {
                setState(() {
                  description = value.isEmpty ? null : value;
                });
              },
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
        ),
      ),
    );
  }
}