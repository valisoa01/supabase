import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading = false;
  String? error;
  bool submitted = false;

  Future<void> _submit() async {
    setState(() {
      submitted = true;
      error = null;
    });

    if (emailCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty ||
        confirmCtrl.text.trim().isEmpty) {
      setState(() => error = 'Veuillez remplir tous les champs.');
      return;
    }
    if (passCtrl.text != confirmCtrl.text) {
      setState(() => error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (passCtrl.text.length < 6) {
      setState(() => error = 'Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }

    setState(() => loading = true);
    try {
      await ref.read(authRepositoryProvider).register(emailCtrl.text, passCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès. Connectez-vous.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      String message = 'Inscription échouée.';
      if (e.toString().contains('already registered')) {
        message = 'Cet email est déjà utilisé.';
      } else if (e.toString().contains('Invalid email')) {
        message = 'Adresse email invalide.';
      } else if (e.toString().contains('network')) {
        message = 'Erreur réseau. Vérifiez votre connexion.';
      }
      setState(() => error = message);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.person_add,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
                errorText: submitted && emailCtrl.text.trim().isEmpty
                    ? 'L\'email est requis'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                errorText: submitted && passCtrl.text.trim().isEmpty
                    ? 'Le mot de passe est requis'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                errorText: submitted && confirmCtrl.text.trim().isEmpty
                    ? 'La confirmation est requise'
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
                        Icon(Icons.error_outline,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(error!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('S\'inscrire'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Déjà un compte ? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
