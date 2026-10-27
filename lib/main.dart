import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
  colorSchemeSeed: const Color(0xFFFF7A00), // orange
  useMaterial3: true,
),
      home: const SignupPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Local tip simulation (Task A). No network, no AI, no form data.
// ---------------------------------------------------------------------------

enum TipStatus { idle, loading, success, error }

/// Test controls so you can demo success, error, and missing-data cases.
enum TipTestMode { normal, localError, missingData }

class LocalTipService {
  // Fixed category: the only thing that selects a tip.
  static const String category = 'password_help';

  static const Map<String, List<String>> _tips = {
    'password_help': [
      'Longer passwords are harder to guess. Try combining a few unrelated words.',
      'Avoid reusing one password across different apps or sites.',
      'A password manager can create and remember strong passwords for you.',
    ],
  };

  // Deterministic: the tip depends only on how many times the button was tapped.
  Future<String> getTip({
    required int requestCount,
    required TipTestMode mode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900)); // fake loading

    if (mode == TipTestMode.localError) {
      throw Exception('Simulated local error');
    }

    final List<String> tips =
        mode == TipTestMode.missingData ? <String>[] : (_tips[category] ?? <String>[]);

    if (tips.isEmpty) {
      throw StateError('No preset tips available');
    }

    String tip = tips[requestCount % tips.length];
    if (tip.length > 240) tip = tip.substring(0, 240); // enforce max length
    return tip;
  }
}

// ---------------------------------------------------------------------------
// Signup page
// ---------------------------------------------------------------------------

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Tip feature state (kept separate from the form on purpose).
  final _tipService = LocalTipService();
  TipStatus _tipStatus = TipStatus.idle;
  String _tipText = '';
  int _tipRequestCount = 0;
  TipTestMode _testMode = TipTestMode.normal;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _getTip() async {
    setState(() => _tipStatus = TipStatus.loading);
    try {
      // Note: no controller values are passed in. Tips ignore form data.
      final tip = await _tipService.getTip(
        requestCount: _tipRequestCount,
        mode: _testMode,
      );
      _tipRequestCount++;
      if (!mounted) return;
      setState(() {
        _tipText = tip;
        _tipStatus = TipStatus.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _tipStatus = TipStatus.error);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, $name! Your demo signup passed validation.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildTipArea() {
    switch (_tipStatus) {
      case TipStatus.idle:
        return const Text('Tap the button for a preset tip.');
      case TipStatus.loading:
        return const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading tip...'),
          ],
        );
      case TipStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_tipText),
            const SizedBox(height: 6),
            const Text(
              'Preset demo tip—not live AI.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        );
      case TipStatus.error:
        return Row(
          children: [
            const Expanded(
              child: Text(
                'Could not load a tip (local demo error).',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(onPressed: _getTip, child: const Text('Retry')),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Join the Snack Club!'),
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Task C: Confirm password
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 32),
              const Divider(),

              // Task A: tip card, separate from validation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signup Tip (local demo)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildTipArea(),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed:
                            _tipStatus == TipStatus.loading ? null : _getTip,
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Get a signup tip'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Test mode: '),
                          DropdownButton<TipTestMode>(
                            value: _testMode,
                            items: const [
                              DropdownMenuItem(
                                value: TipTestMode.normal,
                                child: Text('Normal'),
                              ),
                              DropdownMenuItem(
                                value: TipTestMode.localError,
                                child: Text('Local error'),
                              ),
                              DropdownMenuItem(
                                value: TipTestMode.missingData,
                                child: Text('Missing tip data'),
                              ),
                            ],
                            onChanged: (m) {
                              if (m != null) setState(() => _testMode = m);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}