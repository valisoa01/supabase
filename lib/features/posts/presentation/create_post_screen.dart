import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_exception.dart';
import '../domain/post_repository.dart';
import '../presentation/post_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  bool loading = false;
  String? error;
  bool submitted = false;

  Future<void> _submit() async {
    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
      setState(() {
        error = 'Veuillez remplir tous les champs.';
        submitted = true;
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
      submitted = true;
    });
    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.createPost(title: titleCtrl.text.trim(), body: bodyCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(postListProvider.notifier).refreshPosts();
        Navigator.pop(context);
      }
    } on AppException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = 'Erreur inattendue: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un article')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Titre',
                border: const OutlineInputBorder(),
                errorText: submitted && titleCtrl.text.trim().isEmpty
                    ? 'Le titre est requis'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Contenu',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                errorText: submitted && bodyCtrl.text.trim().isEmpty
                    ? 'Le contenu est requis'
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: loading ? null : _submit,
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(loading ? 'Envoi en cours...' : 'Publier'),
            ),
          ],
        ),
      ),
    );
  }
}
