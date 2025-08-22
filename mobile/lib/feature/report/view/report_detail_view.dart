import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/report/report_repository.dart';

class ReportDetailView extends StatefulWidget {
  const ReportDetailView({super.key, required this.reportId});

  final int reportId;

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends State<ReportDetailView> {
  final _dateFmt = DateFormat('dd.MM.yyyy HH:mm');

  ReportDetail? _detail;
  bool _loading = false;
  String? _error;

  final _commentCtrl = TextEditingController();
  bool _sending = false;

  ReportRepository get _repo => di<ReportRepository>();

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
      final detail = await _repo.fetchDetail(widget.reportId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
      });
    } catch (e) {
      setState(() {
        _error = 'Bildirimi yüklerken bir hata oluştu';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final newComment = await _repo.addComment(reportId: widget.reportId, content: text);
      if (!mounted) return;
      setState(() {
        _detail = _detail == null
            ? _detail
            : ReportDetail(
                id: _detail!.id,
                title: _detail!.title,
                description: _detail!.description,
                status: _detail!.status,
                priority: _detail!.priority,
                reporter: _detail!.reporter,
                category: _detail!.category,
                assignedTeam: _detail!.assignedTeam,
                location: _detail!.location,
                latitude: _detail!.latitude,
                longitude: _detail!.longitude,
                createdAt: _detail!.createdAt,
                updatedAt: _detail!.updatedAt,
                mediaFiles: _detail!.mediaFiles,
                comments: [newComment, ..._detail!.comments],
              );
        _commentCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum gönderildi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum gönderilemedi')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Detayı'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Center(child: Text(_error!)),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ),
        ],
      );
    }
    final d = _detail;
    if (d == null) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Veri bulunamadı')),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          d.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(icon: Icons.flag_outlined, label: d.priority),
            _Chip(icon: Icons.info_outline, label: d.status),
            if (d.category.name.isNotEmpty) _Chip(icon: Icons.category_outlined, label: d.category.name),
            if (d.location != null && d.location!.isNotEmpty)
              _Chip(icon: Icons.place_outlined, label: d.location!),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(d.reporter.email)),
            const SizedBox(width: 12),
            const Icon(Icons.schedule, size: 18),
            const SizedBox(width: 6),
            Text(_dateFmt.format(d.createdAt)),
          ],
        ),
        const SizedBox(height: 16),
        if ((d.mediaFiles).isNotEmpty) _MediaGallery(files: d.mediaFiles),
        if ((d.mediaFiles).isNotEmpty) const SizedBox(height: 16),
        if (d.description != null && d.description!.isNotEmpty) ...[
          Text('Açıklama', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(d.description!),
          const SizedBox(height: 16),
        ],
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 4),
        Text('Yorumlar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (d.comments.isEmpty)
          Text('Henüz yorum yok', style: Theme.of(context).textTheme.bodyMedium)
        else
          ...d.comments.map((c) => _CommentTile(c, _dateFmt)),
        const SizedBox(height: 12),
        _CommentComposer(
          controller: _commentCtrl,
          sending: _sending,
          onSend: _sendComment,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _MediaGallery extends StatelessWidget {
  const _MediaGallery({required this.files});

  final List<MediaDto> files;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final f = files[index];
          final url = f.fileUrl ?? f.filePath;
          if (url == null || url.isEmpty) {
            return Container(
              width: 260,
              height: 200,
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported_outlined),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile(this.c, this.fmt);

  final CommentDto c;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(child: Icon(Icons.person_outline)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.user.email,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Text(
                      fmt.format(c.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Yorum yazın...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: sending ? null : onSend,
          icon: sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: const Text('Gönder'),
        )
      ],
    );
  }
}