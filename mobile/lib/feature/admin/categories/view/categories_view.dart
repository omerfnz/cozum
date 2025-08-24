import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/report/report_repository.dart';
import '../../../../core/widgets/widgets.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool _loading = true;
  String? _error;
  List<CategoryDto> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await di<ReportRepository>().fetchCategories();
      setState(() => _items = list);
    } catch (e, s) {
      di<Logger>().e('[Categories] Liste alma hatası: $e', stackTrace: s);
      setState(() => _error = 'Kategoriler yüklenemedi');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategoriler')),
      body: _loading
          ? const GlobalLoadingWidget(message: 'Kategoriler yükleniyor...')
          : _error != null
              ? GlobalErrorWidget(
                  error: _error!,
                  onRetry: _load,
                )
              : _items.isEmpty
                  ? const EmptyStateWidget(
                      message: 'Kategori bulunamadı',
                      icon: Icons.category_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final c = _items[index];
                          return Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
                              title: Text(c.name),
                              subtitle: Text('ID: ${c.id}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {},
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: _items.length,
                      ),
                    ),
    );
  }
}