import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:organic_farming_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OrganicFarmingApp());
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.sendEmailVerification();
  }

  static Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      await _auth.signInWithPopup(provider);
      return;
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }

  static String readableError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found for this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a little and try again.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    return error.toString();
  }
}

class AppColors {
  static const seed = Color(0xFF22C55E);
  static const primary = Color(0xFF16A34A);
  static const softBackground = Color(0xFFF3FFF6);
  static const softBorder = Color(0x334ADE80);
}

class OrganicFarmingApp extends StatelessWidget {
  const OrganicFarmingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
        scaffoldBackgroundColor: AppColors.softBackground,
      ),
      routes: {
        '/': (_) => const SplashScreen(),
        '/auth': (_) => const AuthScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/verify-email': (_) => const VerifyEmailScreen(),
        '/home': (_) => const HomeScreen(),
        '/crops': (_) => const CropListScreen(),
        '/crop-planner': (_) => const UnknownCropPlannerScreen(),
        '/fertilizers': (_) => const FertilizerKnowledgeScreen(),
        '/pest': (_) => const PestControlKnowledgeScreen(),
        '/schemes': (_) => const GovernmentSchemesScreen(),
        '/weather': (_) => const WeatherScreen(),
        '/videos': (_) => const VideosScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      User? user;
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (_) {
        user = null;
      }
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/auth');
      } else if (user.email != null && !user.emailVerified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF34D399), Color(0xFF16A34A)],
          ),
        ),
        child: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.eco, size: 64, color: Colors.white),
            SizedBox(height: 10),
            Text('Organic Farming Assistant',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            Text('Grow Naturally', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0x1A000000)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Farmer',
                    style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 180,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 180,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = true;
  bool _hidePassword = true;
  bool _authLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _showForgotPasswordDialog() async {
    final messenger = ScaffoldMessenger.of(context);
    final dialogFormKey = GlobalKey<FormState>();
    var resetEmail = _email.text.trim();
    final emailToReset = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your account email and we will send a password reset link.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: resetEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => resetEmail = value.trim(),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Email required';
                    }
                    if (!email.contains('@')) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!dialogFormKey.currentState!.validate()) {
                  return;
                }
                Navigator.of(dialogContext).pop(resetEmail);
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
    if (!mounted || emailToReset == null) {
      return;
    }

    try {
      await AuthService.sendPasswordResetEmail(email: emailToReset);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent to $emailToReset. Check inbox and spam, open the link, change your password, then sign in.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(AuthService.readableError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: AppColors.softBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const Icon(Icons.shield_moon,
                        color: AppColors.primary, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign In',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in using email/password or Google',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    _AuthTextField(
                      controller: _email,
                      label: 'Email',
                      prefix: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email required';
                        }
                        if (!v.contains('@')) {
                          return 'Enter valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _AuthTextField(
                      controller: _password,
                      label: 'Password',
                      prefix: Icons.lock_outline,
                      obscure: _hidePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                        ),
                        const Text('Remember me'),
                        const Spacer(),
                        TextButton(
                          onPressed:
                              _authLoading ? null : _showForgotPasswordDialog,
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _authLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                if (!_form.currentState!.validate()) {
                                  return;
                                }
                                setState(() => _authLoading = true);
                                try {
                                  await AuthService.signInWithEmail(
                                    email: _email.text.trim(),
                                    password: _password.text.trim(),
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null &&
                                      user.email != null &&
                                      !user.emailVerified) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Email not verified. Please verify before continuing.',
                                        ),
                                      ),
                                    );
                                    navigator.pushNamed('/verify-email');
                                  } else {
                                    navigator.pushNamedAndRemoveUntil(
                                      '/home',
                                      (_) => false,
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(AuthService.readableError(e)),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _authLoading = false);
                                  }
                                }
                              },
                        child: Text(_authLoading ? 'Signing in...' : 'Sign in'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _authLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _authLoading = true);
                                try {
                                  await AuthService.signInWithGoogle();
                                  if (!mounted) {
                                    return;
                                  }
                                  if (FirebaseAuth.instance.currentUser !=
                                      null) {
                                    navigator.pushNamedAndRemoveUntil(
                                      '/home',
                                      (_) => false,
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(AuthService.readableError(e)),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _authLoading = false);
                                  }
                                }
                              },
                        icon: const Icon(Icons.g_mobiledata, size: 26),
                        label: const Text('Sign in with Google'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('No account? Create one'),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _authLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: AppColors.softBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const Icon(Icons.person_add_alt_1,
                        color: AppColors.primary, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Create Account',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                        'Use your email. We will send a verification link.'),
                    const SizedBox(height: 18),
                    _AuthTextField(
                      controller: _email,
                      label: 'Email',
                      prefix: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email required';
                        }
                        if (!v.contains('@')) {
                          return 'Enter valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _AuthTextField(
                      controller: _password,
                      label: 'Password',
                      prefix: Icons.lock_outline,
                      obscure: _hidePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _AuthTextField(
                      controller: _confirm,
                      label: 'Confirm Password',
                      prefix: Icons.lock_reset,
                      obscure: _hideConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _hideConfirm = !_hideConfirm),
                      ),
                      validator: (v) => (v != _password.text)
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _authLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                if (!_form.currentState!.validate()) {
                                  return;
                                }
                                setState(() => _authLoading = true);
                                try {
                                  await AuthService.signUpWithEmail(
                                    email: _email.text.trim(),
                                    password: _password.text.trim(),
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Account created. Verification email sent.',
                                      ),
                                    ),
                                  );
                                  navigator.pushNamed('/verify-email');
                                } catch (e) {
                                  if (!mounted) {
                                    return;
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(AuthService.readableError(e)),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _authLoading = false);
                                  }
                                }
                              },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(_authLoading ? 'Signing up...' : 'Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Back to sign in'),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _verified = false;
  bool _loading = false;
  bool _resending = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      setState(() {
        _email = refreshed?.email ?? '';
        _verified = refreshed?.emailVerified ?? false;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _resending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent again.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.readableError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: AppColors.softBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _verified
                        ? Icons.verified
                        : Icons.mark_email_unread_outlined,
                    color: AppColors.primary,
                    size: 50,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verify Email',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _email.isEmpty ? 'No account email found.' : _email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _verified ? 'Status: Verified' : 'Status: Not verified',
                    style: TextStyle(
                      color: _verified
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _resending ? null : _resendEmail,
                      icon: const Icon(Icons.mark_email_read_outlined),
                      label: Text(_resending
                          ? 'Sending...'
                          : 'Resend Verification Email'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _checkStatus,
                      icon: const Icon(Icons.refresh),
                      label: Text(_loading
                          ? 'Checking...'
                          : 'I Have Verified, Refresh'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: _verified
                          ? () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (_) => false,
                              )
                          : null,
                      child: const Text('Verified, Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.prefix,
    required this.validator,
    this.obscure = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefix;
  final String? Function(String?) validator;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        prefixIcon: Icon(prefix),
        suffixIcon: suffix,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <MenuItem>[
      MenuItem('Crop Information', Icons.grass,
          () => Navigator.pushNamed(context, '/crops')),
      MenuItem('Organic Fertilizers', Icons.spa,
          () => Navigator.pushNamed(context, '/fertilizers')),
      MenuItem('Pest Control', Icons.bug_report,
          () => Navigator.pushNamed(context, '/pest')),
      MenuItem('Weather', Icons.cloud,
          () => Navigator.pushNamed(context, '/weather')),
      MenuItem('Tips', Icons.tips_and_updates,
          () => Navigator.pushNamed(context, '/videos')),
      MenuItem('Government Schemes', Icons.account_balance,
          () => Navigator.pushNamed(context, '/schemes')),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              tooltip: 'Profile',
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) async {
                if (value != 'logout') {
                  return;
                }
                final navigator = Navigator.of(context);
                await AuthService.signOut();
                navigator.pushNamedAndRemoveUntil('/auth', (_) => false);
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (c, b) {
        final n = b.maxWidth > 1150
            ? 4
            : b.maxWidth > 800
                ? 3
                : 2;
        return Padding(
          padding: const EdgeInsets.all(14),
          child: GridView.count(
            crossAxisCount: n,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              for (final i in items)
                _Card(title: i.title, icon: i.icon, onTap: i.onTap)
            ],
          ),
        );
      }),
    );
  }
}

class MenuItem {
  MenuItem(this.title, this.icon, this.onTap);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x12000000), blurRadius: 8)
            ]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(
              backgroundColor: const Color(0xFFD9F2E6),
              child: Icon(icon, color: const Color(0xFF1B5E20))),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final categories = <String>{
      'All',
      ...cropProfiles.map((c) => c.category),
    }.toList();
    final filtered = cropProfiles.where((crop) {
      final matchQuery = crop.name.toLowerCase().contains(query) ||
          crop.category.toLowerCase().contains(query);
      final matchCategory =
          selectedCategory == 'All' || crop.category == selectedCategory;
      return matchQuery && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Library')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search crop (e.g. Rice, Maize, Mango)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (_) {
                          setState(() => selectedCategory = category);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Showing ${filtered.length} of ${cropProfiles.length} crops',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? _CropNotFoundCard(query: _searchController.text.trim())
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final crop = filtered[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFD9F2E6),
                              child: Text(
                                crop.name.substring(0, 1),
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(crop.name),
                            subtitle: Text(
                              '${crop.category} | ${crop.season} | ${crop.duration}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CropDetailScreen(crop: crop),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropNotFoundCard extends StatelessWidget {
  const _CropNotFoundCard({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 42),
              const SizedBox(height: 8),
              Text(
                query.isEmpty
                    ? 'No crop found for selected filter.'
                    : 'No exact result for "$query".',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use Universal Crop Planner to get a complete cultivation checklist for any crop.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/crop-planner',
                    arguments: query,
                  );
                },
                icon: const Icon(Icons.agriculture),
                label: const Text('Open Universal Crop Planner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CropDetailScreen extends StatelessWidget {
  const CropDetailScreen({super.key, required this.crop});

  final CropProfile crop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(crop.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Season: ${crop.season}'),
                Text('Duration: ${crop.duration}'),
                Text('Soil: ${crop.soil}'),
                Text('Water: ${crop.waterNeed}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CropSection(title: 'Land & Sowing', points: [
            'Spacing: ${crop.spacing}',
            'Seed rate: ${crop.seedRate}',
            crop.landPrep,
          ]),
          _CropSection(title: 'Nutrition Plan', points: crop.nutritionPlan),
          _CropSection(
              title: 'Pest and Disease Management', points: crop.pestPlan),
          _CropSection(title: 'Harvest and Market', points: crop.harvestPlan),
          _CropSection(title: 'Pro Tips', points: crop.proTips),
        ],
      ),
    );
  }
}

class _CropSection extends StatelessWidget {
  const _CropSection({required this.title, required this.points});

  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: [
          for (final p in points)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline, size: 18),
              title: Text(p),
            ),
        ],
      ),
    );
  }
}

class CropProfile {
  const CropProfile({
    required this.name,
    required this.category,
    required this.season,
    required this.duration,
    required this.soil,
    required this.waterNeed,
    required this.spacing,
    required this.seedRate,
    required this.landPrep,
    required this.nutritionPlan,
    required this.pestPlan,
    required this.harvestPlan,
    required this.proTips,
  });

  final String name;
  final String category;
  final String season;
  final String duration;
  final String soil;
  final String waterNeed;
  final String spacing;
  final String seedRate;
  final String landPrep;
  final List<String> nutritionPlan;
  final List<String> pestPlan;
  final List<String> harvestPlan;
  final List<String> proTips;
}

const List<CropProfile> cropProfiles = [
  CropProfile(
    name: 'Rice',
    category: 'Cereal',
    season: 'Kharif / Rabi',
    duration: '110-150 days',
    soil: 'Clay loam',
    waterNeed: 'High',
    spacing: '20 x 15 cm',
    seedRate: '20-25 kg/acre',
    landPrep: 'Puddle field well and level before transplanting.',
    nutritionPlan: [
      'Apply compost 2 tons/acre before planting',
      'Top dress neem cake at tillering stage'
    ],
    pestPlan: [
      'Use pheromone traps for stem borer',
      'Spray neem seed extract for leaf folder'
    ],
    harvestPlan: [
      'Harvest when 80% panicles turn golden',
      'Dry grain to safe moisture before storage'
    ],
    proTips: [
      'Use short duration variety in low rainfall area',
      'Keep alternate wetting and drying irrigation'
    ],
  ),
  CropProfile(
    name: 'Wheat',
    category: 'Cereal',
    season: 'Rabi',
    duration: '110-130 days',
    soil: 'Well-drained loam',
    waterNeed: 'Medium',
    spacing: '22 cm rows',
    seedRate: '40-45 kg/acre',
    landPrep: 'Fine tilth with two ploughings and one plank.',
    nutritionPlan: ['Apply FYM before sowing', 'Split nitrogen in 2 doses'],
    pestPlan: ['Monitor aphids on ear heads', 'Use yellow sticky traps'],
    harvestPlan: [
      'Harvest when spikes are fully dry and hard',
      'Store in dry, ventilated place'
    ],
    proTips: [
      'Timely sowing gives higher yield',
      'Avoid late irrigation near maturity'
    ],
  ),
  CropProfile(
    name: 'Maize',
    category: 'Cereal',
    season: 'Kharif / Rabi',
    duration: '90-120 days',
    soil: 'Sandy loam',
    waterNeed: 'Medium',
    spacing: '60 x 20 cm',
    seedRate: '8-10 kg/acre',
    landPrep: 'Prepare raised beds for better drainage.',
    nutritionPlan: [
      'Apply vermicompost at sowing',
      'Use biofertilizer seed treatment'
    ],
    pestPlan: [
      'Scout for fall armyworm weekly',
      'Apply neem formulation in whorl'
    ],
    harvestPlan: [
      'Harvest cobs at physiological maturity',
      'Dry cobs before shelling'
    ],
    proTips: [
      'Intercrop with legumes for soil health',
      'Avoid waterlogging at early stage'
    ],
  ),
  CropProfile(
    name: 'Millets (Bajra)',
    category: 'Cereal',
    season: 'Kharif',
    duration: '75-95 days',
    soil: 'Light soils',
    waterNeed: 'Low',
    spacing: '45 x 15 cm',
    seedRate: '1.5-2 kg/acre',
    landPrep: 'One deep ploughing is enough in dryland.',
    nutritionPlan: ['FYM before sowing', 'Use jeevamrutham foliar spray'],
    pestPlan: [
      'Bird perches for insect predators',
      'Neem extract for shoot fly'
    ],
    harvestPlan: ['Harvest when ear heads become hard', 'Sun dry thoroughly'],
    proTips: [
      'Best option for drought-prone areas',
      'Use line sowing for easy weeding'
    ],
  ),
  CropProfile(
    name: 'Cotton',
    category: 'Fiber',
    season: 'Kharif',
    duration: '150-180 days',
    soil: 'Black cotton soil',
    waterNeed: 'Medium',
    spacing: '120 x 45 cm',
    seedRate: '1-1.5 kg/acre',
    landPrep: 'Deep plough in summer to reduce pest carryover.',
    nutritionPlan: [
      'Apply compost and neem cake',
      'Use liquid organic manure at square formation'
    ],
    pestPlan: [
      'Install pheromone traps for pink bollworm',
      'Use neem spray for sucking pests'
    ],
    harvestPlan: ['Pick only fully opened bolls', 'Keep kapas dry and clean'],
    proTips: [
      'Do not over-irrigate after boll formation',
      'Remove pest-infested squares early'
    ],
  ),
  CropProfile(
    name: 'Sugarcane',
    category: 'Commercial',
    season: 'Spring / Autumn',
    duration: '10-12 months',
    soil: 'Loam to clay loam',
    waterNeed: 'High',
    spacing: '120 cm rows',
    seedRate: '25000 setts/acre',
    landPrep: 'Prepare deep furrows with good drainage.',
    nutritionPlan: [
      'Apply press mud or compost',
      'Use microbial consortia in furrows'
    ],
    pestPlan: [
      'Trash mulching to suppress early shoot borer',
      'Release biological agents'
    ],
    harvestPlan: ['Harvest at peak sugar stage', 'Send to mill quickly'],
    proTips: [
      'Use trash mulching to conserve water',
      'Regular earthing up improves tillering'
    ],
  ),
  CropProfile(
    name: 'Groundnut',
    category: 'Oilseed',
    season: 'Kharif / Rabi',
    duration: '100-120 days',
    soil: 'Sandy loam',
    waterNeed: 'Low to medium',
    spacing: '30 x 10 cm',
    seedRate: '35-40 kg/acre',
    landPrep: 'Fine seedbed is important for pegging.',
    nutritionPlan: [
      'Apply gypsum at pegging stage',
      'Use compost before sowing'
    ],
    pestPlan: [
      'Neem spray for leaf miner',
      'Trichoderma seed treatment for rot'
    ],
    harvestPlan: [
      'Harvest when inner shell turns dark',
      'Dry pods to avoid aflatoxin'
    ],
    proTips: ['Irrigate at flowering and pegging', 'Avoid delayed harvest'],
  ),
  CropProfile(
    name: 'Soybean',
    category: 'Oilseed',
    season: 'Kharif',
    duration: '90-110 days',
    soil: 'Well-drained loam',
    waterNeed: 'Medium',
    spacing: '45 x 5 cm',
    seedRate: '30 kg/acre',
    landPrep: 'Use flat bed with good residue incorporation.',
    nutritionPlan: [
      'Rhizobium inoculation before sowing',
      'Apply farm compost'
    ],
    pestPlan: [
      'Monitor girdle beetle and semilooper',
      'Neem-based spray at threshold'
    ],
    harvestPlan: [
      'Harvest when pods turn yellow-brown',
      'Dry before threshing'
    ],
    proTips: [
      'Do not irrigate during heavy rainfall periods',
      'Timely weed control is critical'
    ],
  ),
  CropProfile(
    name: 'Sunflower',
    category: 'Oilseed',
    season: 'Kharif / Rabi',
    duration: '85-100 days',
    soil: 'Loam',
    waterNeed: 'Medium',
    spacing: '60 x 30 cm',
    seedRate: '2 kg/acre',
    landPrep: 'Maintain friable soil for root growth.',
    nutritionPlan: [
      'Use FYM and vermicompost',
      'Spray micronutrient mixture at bud stage'
    ],
    pestPlan: [
      'Bird perches and neem spray for capitulum borer',
      'Field sanitation'
    ],
    harvestPlan: [
      'Harvest when back of head turns yellow',
      'Dry heads before threshing'
    ],
    proTips: [
      'Avoid water stress at flowering',
      'Do not delay harvest to prevent shattering'
    ],
  ),
  CropProfile(
    name: 'Mustard',
    category: 'Oilseed',
    season: 'Rabi',
    duration: '100-120 days',
    soil: 'Sandy loam',
    waterNeed: 'Low',
    spacing: '45 x 15 cm',
    seedRate: '1.5-2 kg/acre',
    landPrep: 'Light land preparation with good drainage.',
    nutritionPlan: [
      'Use compost and wood ash',
      'Foliar spray of seaweed extract'
    ],
    pestPlan: [
      'Yellow sticky traps for aphids',
      'Soap solution spray if infestation rises'
    ],
    harvestPlan: [
      'Harvest when pods are yellow',
      'Thresh gently to reduce loss'
    ],
    proTips: [
      'Early sowing in rabi avoids terminal heat',
      'Keep one irrigation at flowering'
    ],
  ),
  CropProfile(
    name: 'Tomato',
    category: 'Vegetable',
    season: 'Year-round (region specific)',
    duration: '90-120 days',
    soil: 'Sandy loam',
    waterNeed: 'Medium',
    spacing: '60 x 45 cm',
    seedRate: '50-60 g/acre nursery',
    landPrep: 'Prepare raised beds and add compost.',
    nutritionPlan: [
      'Apply vermicompost per pit',
      'Use fermented liquid manure every 15 days'
    ],
    pestPlan: ['Sticky traps for whitefly', 'Neem oil spray for fruit borer'],
    harvestPlan: [
      'Pick fruits at breaker stage for transport',
      'Grade and pack gently'
    ],
    proTips: [
      'Use staking to reduce disease',
      'Mulch beds to save water and suppress weeds'
    ],
  ),
  CropProfile(
    name: 'Chilli',
    category: 'Vegetable',
    season: 'Kharif / Rabi',
    duration: '120-150 days',
    soil: 'Well-drained loam',
    waterNeed: 'Medium',
    spacing: '60 x 45 cm',
    seedRate: '300-400 g/acre nursery',
    landPrep: 'Transplant healthy seedlings only.',
    nutritionPlan: [
      'Compost at planting',
      'Apply fish amino acid foliar spray'
    ],
    pestPlan: ['Neem oil for thrips and mites', 'Blue sticky traps for thrips'],
    harvestPlan: [
      'Harvest green/red depending on market',
      'Dry red chilli under shade-sun cycle'
    ],
    proTips: [
      'Avoid overhead irrigation during flowering',
      'Use border crop to reduce vector pests'
    ],
  ),
  CropProfile(
    name: 'Onion',
    category: 'Vegetable',
    season: 'Rabi / late kharif',
    duration: '100-130 days',
    soil: 'Friable loam',
    waterNeed: 'Medium',
    spacing: '15 x 10 cm',
    seedRate: '3-4 kg/acre nursery',
    landPrep: 'Fine tilth with raised beds.',
    nutritionPlan: [
      'FYM and neem cake',
      'Foliar micronutrients at bulb formation'
    ],
    pestPlan: [
      'Use sticky traps for thrips',
      'Spray neem formulation at early stage'
    ],
    harvestPlan: [
      'Harvest when tops bend naturally',
      'Cure bulbs before storage'
    ],
    proTips: [
      'Stop irrigation 10 days before harvest',
      'Use well-ventilated storage'
    ],
  ),
  CropProfile(
    name: 'Brinjal',
    category: 'Vegetable',
    season: 'Year-round',
    duration: '130-160 days',
    soil: 'Loam',
    waterNeed: 'Medium',
    spacing: '75 x 60 cm',
    seedRate: '150-200 g/acre nursery',
    landPrep: 'Deep plough and add organic manure.',
    nutritionPlan: [
      'Vermicompost at planting',
      'Jeevamrutham drench every 15 days'
    ],
    pestPlan: [
      'Install pheromone traps for shoot borer',
      'Remove and destroy infested shoots'
    ],
    harvestPlan: ['Harvest at tender stage', 'Frequent picking boosts yield'],
    proTips: ['Use marigold trap crop', 'Avoid continuous brinjal cropping'],
  ),
  CropProfile(
    name: 'Cabbage',
    category: 'Vegetable',
    season: 'Cool season',
    duration: '80-100 days',
    soil: 'Loam rich in organic matter',
    waterNeed: 'Medium',
    spacing: '45 x 45 cm',
    seedRate: '200 g/acre nursery',
    landPrep: 'Raised beds with high compost.',
    nutritionPlan: [
      'Apply compost and biofertilizer',
      'Use panchagavya spray at vegetative stage'
    ],
    pestPlan: [
      'Netting against diamondback moth',
      'Neem spray at larval stage'
    ],
    harvestPlan: ['Harvest when heads are compact', 'Avoid over maturity'],
    proTips: ['Maintain field sanitation', 'Rotate with legumes'],
  ),
  CropProfile(
    name: 'Potato',
    category: 'Vegetable',
    season: 'Rabi',
    duration: '90-110 days',
    soil: 'Sandy loam',
    waterNeed: 'Medium',
    spacing: '60 x 20 cm',
    seedRate: '8-10 quintal/acre seed tubers',
    landPrep: 'Prepare ridges and furrows.',
    nutritionPlan: [
      'Apply compost before planting',
      'Use liquid manure after earthing up'
    ],
    pestPlan: ['Monitor aphids and cutworms', 'Neem-based management'],
    harvestPlan: ['Harvest after vines dry', 'Cure tubers before bagging'],
    proTips: ['Earthing up is critical', 'Avoid irrigation before harvest'],
  ),
  CropProfile(
    name: 'Turmeric',
    category: 'Spice',
    season: 'Kharif',
    duration: '7-9 months',
    soil: 'Loam rich in organic carbon',
    waterNeed: 'Medium',
    spacing: '45 x 20 cm',
    seedRate: '8-10 quintal rhizome/acre',
    landPrep: 'Raised beds with heavy mulching.',
    nutritionPlan: [
      'Apply FYM 10 tons/acre',
      'Top dress vermicompost at 60 and 120 days'
    ],
    pestPlan: [
      'Trichoderma for rhizome rot prevention',
      'Neem cake for soil pests'
    ],
    harvestPlan: [
      'Harvest when leaves turn yellow',
      'Boil and cure for dry turmeric'
    ],
    proTips: [
      'Mulch immediately after planting',
      'Use healthy disease-free rhizomes'
    ],
  ),
  CropProfile(
    name: 'Ginger',
    category: 'Spice',
    season: 'Kharif',
    duration: '7-8 months',
    soil: 'Sandy loam with organic matter',
    waterNeed: 'Medium',
    spacing: '30 x 20 cm',
    seedRate: '6-8 quintal rhizome/acre',
    landPrep: 'Prepare raised beds under partial shade if needed.',
    nutritionPlan: [
      'Heavy compost application',
      'Biofertilizer drench at 45 days'
    ],
    pestPlan: [
      'Trichoderma treatment for seed rhizomes',
      'Good drainage to prevent rot'
    ],
    harvestPlan: [
      'Early harvest for green ginger',
      'Full maturity harvest for dry ginger'
    ],
    proTips: [
      'Never allow stagnant water',
      'Regular mulching improves rhizome size'
    ],
  ),
  CropProfile(
    name: 'Banana',
    category: 'Fruit',
    season: 'Year-round',
    duration: '11-13 months',
    soil: 'Deep loam',
    waterNeed: 'High',
    spacing: '6 x 6 ft',
    seedRate: '1200-1500 plants/acre',
    landPrep: 'Pit planting with compost and neem cake.',
    nutritionPlan: [
      'Apply organic manure monthly',
      'Use banana special bio-inputs'
    ],
    pestPlan: [
      'Clean field and remove diseased suckers',
      'Use bio-control for pseudostem borer'
    ],
    harvestPlan: [
      'Harvest bunch at mature green stage',
      'Handle bunches carefully to avoid bruising'
    ],
    proTips: ['Desucker regularly', 'Provide propping at bunch stage'],
  ),
  CropProfile(
    name: 'Mango',
    category: 'Fruit',
    season: 'Perennial',
    duration: 'Bearing starts from 3rd year',
    soil: 'Well-drained deep soil',
    waterNeed: 'Medium',
    spacing: '10 x 10 m',
    seedRate: '40 plants/acre',
    landPrep: 'Dig large pits and fill with compost mix.',
    nutritionPlan: [
      'Apply FYM yearly',
      'Use micronutrient spray pre-flowering'
    ],
    pestPlan: ['Manage hopper with neem spray', 'Prune diseased twigs'],
    harvestPlan: [
      'Harvest mature fruits with stalk',
      'Pre-cool before transport'
    ],
    proTips: ['Prune after harvest', 'Bag fruits in high-value orchards'],
  ),
];

class UnknownCropPlannerScreen extends StatefulWidget {
  const UnknownCropPlannerScreen({super.key});

  @override
  State<UnknownCropPlannerScreen> createState() =>
      _UnknownCropPlannerScreenState();
}

class _UnknownCropPlannerScreenState extends State<UnknownCropPlannerScreen> {
  final _cropController = TextEditingController();
  final _soilController = TextEditingController();
  final _seasonController = TextEditingController();
  final _waterController = TextEditingController();
  final _marketController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initial = ModalRoute.of(context)?.settings.arguments;
    if (initial is String &&
        initial.isNotEmpty &&
        _cropController.text.isEmpty) {
      _cropController.text = initial;
    }
  }

  @override
  void dispose() {
    _cropController.dispose();
    _soilController.dispose();
    _seasonController.dispose();
    _waterController.dispose();
    _marketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universal Crop Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Use this for any crop not listed in the app. Fill your local conditions and get a full execution checklist.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cropController,
            decoration: const InputDecoration(
              labelText: 'Crop name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _soilController,
            decoration: const InputDecoration(
              labelText: 'Soil type (example: sandy loam)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _seasonController,
            decoration: const InputDecoration(
              labelText: 'Season (Kharif / Rabi / Summer)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _waterController,
            decoration: const InputDecoration(
              labelText: 'Water availability (Low / Medium / High)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _marketController,
            decoration: const InputDecoration(
              labelText: 'Target market (local mandi / wholesale / retail)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('Generate Plan'),
          ),
          const SizedBox(height: 14),
          if (_cropController.text.trim().isNotEmpty)
            _UniversalPlanCard(
              crop: _cropController.text.trim(),
              soil: _soilController.text.trim(),
              season: _seasonController.text.trim(),
              water: _waterController.text.trim(),
              market: _marketController.text.trim(),
            ),
        ],
      ),
    );
  }
}

class _UniversalPlanCard extends StatelessWidget {
  const _UniversalPlanCard({
    required this.crop,
    required this.soil,
    required this.season,
    required this.water,
    required this.market,
  });

  final String crop;
  final String soil;
  final String season;
  final String water;
  final String market;

  @override
  Widget build(BuildContext context) {
    final soilText = soil.isEmpty ? 'your soil type' : soil;
    final seasonText = season.isEmpty ? 'current season' : season;
    final waterText = water.isEmpty ? 'available water level' : water;
    final marketText = market.isEmpty ? 'selected market channel' : market;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$crop: Complete Action Plan',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Profile: $soilText | $seasonText | Water: $waterText'),
            Text('Market Focus: $marketText'),
            const Divider(height: 20),
            const Text('1. Before Sowing',
                style: TextStyle(fontWeight: FontWeight.w700)),
            Text('- Check if $crop is suitable for $seasonText in your area'),
            Text(
                '- Perform soil test and add organic manure based on $soilText'),
            const SizedBox(height: 8),
            const Text('2. Sowing and Establishment',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('- Use certified seed/planting material'),
            const Text('- Follow local recommended spacing and seed rate'),
            const SizedBox(height: 8),
            const Text('3. Nutrition and Irrigation',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('- Apply compost + biofertilizers in split schedule'),
            Text('- Set irrigation frequency according to $waterText'),
            const SizedBox(height: 8),
            const Text('4. Pest and Disease',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('- Weekly field scouting and trap-based monitoring'),
            const Text('- Use neem and biological control before chemicals'),
            const SizedBox(height: 8),
            const Text('5. Harvest and Post-Harvest',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Text('- Harvest at market maturity stage'),
            Text('- Grade and pack for $marketText'),
          ],
        ),
      ),
    );
  }
}

class FertilizerKnowledgeScreen extends StatelessWidget {
  const FertilizerKnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ProcessModule(
        title: 'Compost',
        icon: Icons.compost,
        accent: Color(0xFF4E944F),
        steps: [
          'Collect dry leaves + kitchen waste + crop residue',
          'Layer waste and soil in pit',
          'Turn pile every 10 days',
          'Use after 45-60 days',
        ],
        stepImages: [
          'assets/images/compost_1.png',
          'assets/images/compost_2.png',
          'assets/images/compost_3.png',
          'assets/images/compost_4.png',
        ],
      ),
      ProcessModule(
        title: 'Vermicompost',
        icon: Icons.grass,
        accent: Color(0xFF2E7D32),
        steps: [
          'Prepare shaded bed with moist biomass',
          'Release earthworms and cover with jute',
          'Keep moisture at 60-70%',
          'Collect casting in 45 days',
        ],
        stepImages: [
          'assets/images/vermi_1.png',
          'assets/images/vermi_2.png',
          'assets/images/vermi_3.png',
          'assets/images/vermi_4.png',
        ],
      ),
      ProcessModule(
        title: 'Jeevamrutham',
        icon: Icons.science,
        accent: Color(0xFF00897B),
        steps: [
          'Mix cow dung, urine, jaggery, pulse flour, and soil',
          'Ferment for 5-7 days',
          'Apply through irrigation every 15 days',
        ],
        stepImages: [
          'assets/images/jeeva_1.png',
          'assets/images/jeeva_2.png',
          'assets/images/jeeva_3.png',
        ],
      ),
      ProcessModule(
        title: 'Neem Extract Spray',
        icon: Icons.spa,
        accent: Color(0xFF558B2F),
        steps: [
          'Crush neem seeds or use neem oil',
          'Mix with water + mild soap',
          'Spray in evening on both leaf surfaces',
        ],
        stepImages: [
          'assets/images/neem_1.png',
          'assets/images/neem_2.png',
          'assets/images/neem_3.png',
        ],
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Organic Fertilizers')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final item in items)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.accent.withValues(alpha: 0.18),
                  child: Icon(item.icon, color: item.accent),
                ),
                title: Text(item.title),
                subtitle: const Text('Open guide'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StepByStepProcessScreen(module: item),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class PestControlKnowledgeScreen extends StatelessWidget {
  const PestControlKnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      [
        'Leaves turning yellow',
        'Nutrient deficiency / sap sucking pests',
        'Neem oil + micronutrient foliar spray'
      ],
      [
        'White insects',
        'Whitefly / mealybug',
        'Garlic-chilli extract + yellow sticky traps'
      ],
      ['Leaf holes', 'Caterpillar', 'Pheromone traps + hand picking'],
      [
        'Root rot',
        'Waterlogging fungus',
        'Improve drainage + Trichoderma soil application'
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pest Control')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final row in rows)
            Card(
              child: ListTile(
                title: Text(row[0]),
                subtitle: Text('Cause: ${row[1]}\nAction: ${row[2]}'),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}

class GovernmentSchemesScreen extends StatelessWidget {
  const GovernmentSchemesScreen({super.key});

  static const schemes = [
    SchemeInfo(
      title: 'PM-KISAN',
      summary: 'Income support for eligible farm families',
      benefit: 'Rs 6000 per year in 3 installments',
      eligibility:
          'Small and marginal farmer families with cultivable land records',
      documents: 'Aadhaar, bank account, land document, mobile number, eKYC',
      applySteps: [
        'Visit PM-KISAN portal or nearest CSC',
        'Submit land and Aadhaar details',
        'Complete eKYC verification',
        'Track status online with registration number',
      ],
      contacts: 'PM-KISAN Helpline: 155261 / 011-24300606',
    ),
    SchemeInfo(
      title: 'PMFBY (Crop Insurance)',
      summary: 'Insurance support against crop loss and extreme weather',
      benefit:
          'Compensation for notified crop damage due to drought/flood/pests',
      eligibility: 'Farmers growing notified crops in notified areas',
      documents:
          'Aadhaar, bank passbook, sowing proof, land/lease records, premium receipt',
      applySteps: [
        'Check notified crops for your district',
        'Enroll through bank/insurance portal before cutoff date',
        'Pay farmer premium share',
        'Report crop loss quickly through app/helpline/local officer',
      ],
      contacts: 'PMFBY Helpline: 14447',
    ),
    SchemeInfo(
      title: 'Soil Health Card',
      summary: 'Soil testing and scientific nutrient recommendations',
      benefit: 'Soil fertility report and crop-wise nutrient correction advice',
      eligibility: 'All farmers',
      documents: 'Farmer ID, land details, sample location details',
      applySteps: [
        'Submit soil sample to agriculture lab or camp',
        'Get pH, NPK and micronutrient status report',
        'Use recommended fertilizer schedule in next crop cycle',
      ],
      contacts: 'Contact local Agriculture Extension Office',
    ),
    SchemeInfo(
      title: 'Micro Irrigation Subsidy',
      summary: 'Support for drip/sprinkler system installation',
      benefit: 'Subsidy support varies by state and farmer category',
      eligibility:
          'Farmers with cultivable land and feasible irrigation source',
      documents: 'Aadhaar, land record, bank account, quotation from vendor',
      applySteps: [
        'Apply in horticulture/agriculture department portal',
        'Field verification by department officer',
        'Install approved system through registered vendor',
        'Submit completion report to claim subsidy',
      ],
      contacts: 'District Horticulture Department',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government Schemes')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final s in schemes)
            Card(
              child: ListTile(
                title: Text(s.title),
                subtitle: Text('${s.summary}\n${s.contacts}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SchemeDetailScreen(scheme: s),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SchemeInfo {
  const SchemeInfo({
    required this.title,
    required this.summary,
    required this.benefit,
    required this.eligibility,
    required this.documents,
    required this.applySteps,
    required this.contacts,
  });

  final String title;
  final String summary;
  final String benefit;
  final String eligibility;
  final String documents;
  final List<String> applySteps;
  final String contacts;
}

class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key, required this.scheme});

  final SchemeInfo scheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(scheme.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SchemeCard(title: 'Scheme Benefit', value: scheme.benefit),
          _SchemeCard(title: 'Eligibility', value: scheme.eligibility),
          _SchemeCard(title: 'Required Documents', value: scheme.documents),
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              title: const Text(
                'How to Apply',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              children: [
                for (final step in scheme.applySteps)
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(step),
                  ),
              ],
            ),
          ),
          _SchemeCard(title: 'Helpdesk', value: scheme.contacts),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(value),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = 'Hyderabad';
  final cities = const {
    'Hyderabad': [17.385, 78.4867],
    'Vijayawada': [16.5062, 80.648],
    'Delhi': [28.6139, 77.209],
    'Nambur': [16.3659, 80.4352],
    'Guntur': [16.3067, 80.4365],
    'Amaravati': [16.5141, 80.5165],
    'Visakhapatnam': [17.6868, 83.2185],
    'Tirupati': [13.6288, 79.4192],
    'Bengaluru': [12.9716, 77.5946],
    'Chennai': [13.0827, 80.2707],
    'Mumbai': [19.076, 72.8777]
  };
  Future<Map<String, dynamic>> _load() async {
    final c = cities[city]!;
    final u = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${c[0]}&longitude=${c[1]}&current=temperature_2m,wind_speed_10m&hourly=precipitation_probability&forecast_days=1');
    final r = await http.get(u);
    final j = jsonDecode(r.body);
    return j as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final cityItems = cities.keys
        .map((name) => DropdownMenuItem<String>(value: name, child: Text(name)))
        .toList();
    final selectedCity = cities.containsKey(city) ? city : cities.keys.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButtonFormField<String>(
              value: selectedCity,
              items: cityItems,
              onChanged: cityItems.isEmpty
                  ? null
                  : (v) {
                      if (v == null) {
                        return;
                      }
                      setState(() => city = v);
                    },
              isExpanded: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'City')),
          const SizedBox(height: 14),
          FutureBuilder<Map<String, dynamic>>(
            future: _load(),
            builder: (c, s) {
              if (!s.hasData) return const CircularProgressIndicator();
              final cur = s.data!['current'];
              final rain =
                  (s.data!['hourly']['precipitation_probability'] as List)
                      .cast<num>()
                      .reduce((a, b) => a > b ? a : b)
                      .toInt();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temperature: ${cur['temperature_2m']} C'),
                        Text('Wind Speed: ${cur['wind_speed_10m']} km/h'),
                        Text('Rain Chance: $rain%'),
                        const SizedBox(height: 8),
                        Text(rain >= 50
                            ? 'Rain expected, avoid spraying pesticides.'
                            : 'Weather is suitable for field work.'),
                      ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  static const tips = [
    'Prepare compost pits before the season starts.',
    'Test soil once in every crop cycle.',
    'Use mulching to reduce weed growth and save moisture.',
    'Scout crops twice a week for pest symptoms.',
    'Spray bio-inputs in evening for better effectiveness.',
    'Avoid over-irrigation to prevent root diseases.',
    'Keep a simple farm diary for inputs and weather.',
    'Use trap crops near main crop to reduce pest pressure.',
    'Rotate crops to improve soil health naturally.',
    'Grade produce before selling for better market price.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tips')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (var i = 0; i < tips.length; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFD9F2E6),
                  child: Text('${i + 1}'),
                ),
                title: Text(tips[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class ProcessModule {
  const ProcessModule({
    required this.title,
    required this.icon,
    required this.accent,
    required this.steps,
    required this.stepImages,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> steps;
  final List<String> stepImages;
}

class StepByStepProcessScreen extends StatefulWidget {
  const StepByStepProcessScreen({super.key, required this.module});

  final ProcessModule module;

  @override
  State<StepByStepProcessScreen> createState() =>
      _StepByStepProcessScreenState();
}

class _StepByStepProcessScreenState extends State<StepByStepProcessScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final steps = widget.module.steps;
    final total = steps.length;
    final stepText = steps[index];
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.module.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Step ${index + 1} of $total',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Container(
                key: ValueKey(index),
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.module.accent.withValues(alpha: 0.15),
                      widget.module.accent.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.module.stepImages[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: widget.module.accent.withValues(alpha: 0.15),
                      alignment: Alignment.center,
                      child: Text(
                        'Image missing for step ${index + 1}',
                        style: TextStyle(
                          color: widget.module.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          widget.module.accent.withValues(alpha: 0.2),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: widget.module.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          Text(stepText, style: const TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        index == 0 ? null : () => setState(() => index--),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: index == total - 1
                        ? null
                        : () => setState(() => index++),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
