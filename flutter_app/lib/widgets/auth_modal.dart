import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/directory_provider.dart';
import '../models/models.dart';
import '../data/translations.dart';

void showAuthModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AuthModal(),
  );
}

class AuthModal extends StatefulWidget {
  const AuthModal({super.key});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool _isSignIn = true;
  UserRole _role = UserRole.customer;
  String _email = '';
  String _phone = '';
  String _name = '';
  String _error = '';

  void _switchMode(bool isSignIn) {
    setState(() {
      _isSignIn = isSignIn;
      _email = '';
      _phone = '';
      _name = '';
      _error = '';
    });
  }

  void _submit() {
    final provider = context.read<DirectoryProvider>();
    final lang = provider.language;

    if (_isSignIn) {
      if (_email.isEmpty || _phone.isEmpty) {
        setState(() => _error = lang == 'en' ? 'Email and Phone are required' : 'البريد والهاتف مطلوبان');
        return;
      }
      provider.signIn(_email, _phone, _role, _name.isEmpty ? null : _name);
      Navigator.pop(context);
    } else {
      if (_name.isEmpty || _email.isEmpty || _phone.isEmpty) {
        setState(() => _error = t(lang, 'allFieldsRequired'));
        return;
      }
      provider.signIn(_email, _phone, _role, _name);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final lang = provider.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = const Color(0xFFFFA048);
    final bg = isDark ? const Color(0xFF13110E) : Colors.white;
    final inputBg = isDark ? const Color(0xFF0F0E0C) : Colors.grey.shade100;
    final borderCol = isDark ? const Color(0xFF2D2319) : Colors.grey.shade300;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderCol),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _TabButton(
                          title: t(lang, 'signIn'),
                          icon: LucideIcons.logIn,
                          isActive: _isSignIn,
                          onTap: () => _switchMode(true),
                        ),
                        _TabButton(
                          title: t(lang, 'register'),
                          icon: LucideIcons.userPlus,
                          isActive: !_isSignIn,
                          onTap: () => _switchMode(false),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_error.isNotEmpty) ...[
                Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 12),
              ],

              // Role Selector
              if (!_isSignIn) ...[
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: t(lang, 'roleCustomer'),
                        icon: LucideIcons.user,
                        isSelected: _role == UserRole.customer,
                        onTap: () => setState(() => _role = UserRole.customer),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleCard(
                        title: t(lang, 'roleBusiness'),
                        icon: LucideIcons.briefcase,
                        isSelected: _role == UserRole.business,
                        onTap: () => setState(() => _role = UserRole.business),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              if (_isSignIn) ...[
                Row(
                  children: [
                    Expanded(
                      child: _RoleButton(
                        title: 'Customer',
                        isSelected: _role == UserRole.customer,
                        onTap: () => setState(() => _role = UserRole.customer),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleButton(
                        title: 'Business',
                        isSelected: _role == UserRole.business,
                        onTap: () => setState(() => _role = UserRole.business),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleButton(
                        title: 'Admin',
                        isSelected: _role == UserRole.admin,
                        onTap: () => setState(() => _role = UserRole.admin),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Form
              _InputField(
                label: t(lang, 'name'),
                icon: LucideIcons.user,
                hint: 'Name',
                onChanged: (val) => _name = val,
              ),
              const SizedBox(height: 12),
              _InputField(
                label: t(lang, 'email'),
                icon: LucideIcons.mail,
                hint: 'Email',
                onChanged: (val) => _email = val,
              ),
              const SizedBox(height: 12),
              _InputField(
                label: t(lang, 'phone'),
                icon: LucideIcons.phone,
                hint: 'Phone',
                onChanged: (val) => _phone = val,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _submit,
                  child: Text(
                    _isSignIn ? t(lang, 'signIn') : t(lang, 'createAccount'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({required this.title, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFA048) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.black : Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFA048) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFFFA048) : Colors.grey.shade800),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFA048).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFFFA048) : Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFFFFA048) : Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFFFA048) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hint;
  final ValueChanged<String> onChanged;

  const _InputField({required this.label, required this.icon, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF0F0E0C) : Colors.grey.shade100;
    final borderCol = isDark ? const Color(0xFF2D2319) : Colors.grey.shade300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol),
          ),
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: Icon(icon, size: 16, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
