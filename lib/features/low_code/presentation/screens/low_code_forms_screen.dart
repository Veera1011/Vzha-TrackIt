import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/low_code_provider.dart';

class LowCodeFormsScreen extends ConsumerWidget {
  const LowCodeFormsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formsAsync = ref.watch(formsProvider);

    return Scaffold(
      body: formsAsync.when(
        data: (forms) {
          if (forms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.extension_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Custom Modules',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use the web portal to build dynamic forms using the Low-Code engine.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.dynamic_form)),
                  title: Text(form.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(form.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/dynamic-form/${form.id}', extra: form);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/module-builder'),
        icon: const Icon(Icons.build),
        label: const Text('Build Module'),
      ),
    );
  }
}
