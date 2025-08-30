import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced form validation utilities and widgets
class FormValidators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta gerekli';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    
    return null;
  }

  // Password validation with strength checking
  static String? validatePassword(String? value, {bool requireStrong = false}) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    
    if (requireStrong) {
      if (value.length < 8) {
        return 'Güçlü şifre için en az 8 karakter gerekli';
      }
      
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'En az bir büyük harf gerekli';
      }
      
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return 'En az bir küçük harf gerekli';
      }
      
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'En az bir rakam gerekli';
      }
    }
    
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    
    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalı';
    }
    
    if (value.length > 20) {
      return 'Kullanıcı adı en fazla 20 karakter olabilir';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Sadece harf, rakam ve alt çizgi kullanılabilir';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Bu alan gerekli' : null;
    }
    
    if (int.tryParse(value) == null) {
      return 'Geçerli bir sayı giriniz';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL gerekli' : null;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Geçerli bir URL giriniz';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != originalPassword) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  // Length validation
  static String? validateLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    
    if (value.length < minLength) {
      return '$fieldName en az $minLength karakter olmalı';
    }
    
    if (value.length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olabilir';
    }
    
    return null;
  }
}

/// Password strength indicator
enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

class PasswordStrengthChecker {
  static PasswordStrength checkStrength(String password) {
    int score = 0;
    
    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    switch (score) {
      case 0:
      case 1:
      case 2:
        return PasswordStrength.weak;
      case 3:
      case 4:
        return PasswordStrength.medium;
      case 5:
        return PasswordStrength.strong;
      case 6:
      default:
        return PasswordStrength.veryStrong;
    }
  }

  static Color getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.blue;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }

  static String getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Zayıf';
      case PasswordStrength.medium:
        return 'Orta';
      case PasswordStrength.strong:
        return 'Güçlü';
      case PasswordStrength.veryStrong:
        return 'Çok Güçlü';
    }
  }
}

/// Enhanced TextFormField with real-time validation
class EnhancedTextFormField extends StatefulWidget {
  const EnhancedTextFormField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.showRealTimeValidation = true,
    this.showPasswordStrength = false,
    this.inputFormatters,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final bool showRealTimeValidation;
  final bool showPasswordStrength;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  State<EnhancedTextFormField> createState() => _EnhancedTextFormFieldState();
}

class _EnhancedTextFormFieldState extends State<EnhancedTextFormField> {
  String? _validationError;
  bool _hasInteracted = false;
  PasswordStrength? _passwordStrength;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (!widget.showRealTimeValidation || !_hasInteracted) return;
    
    setState(() {
      _validationError = widget.validator?.call(widget.controller.text);
      
      if (widget.showPasswordStrength && widget.controller.text.isNotEmpty) {
        _passwordStrength = PasswordStrengthChecker.checkStrength(widget.controller.text);
      } else {
        _passwordStrength = null;
      }
    });
  }

  void _onFieldChanged(String value) {
    _hasInteracted = true;
    widget.onChanged?.call(value);
    _onTextChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: widget.showRealTimeValidation ? _validationError : null,
            border: const OutlineInputBorder(),
            counterText: widget.maxLength != null ? null : '',
          ),
          validator: widget.validator,
          onChanged: _onFieldChanged,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
        ),
        if (widget.showPasswordStrength && _passwordStrength != null) ...[
          const SizedBox(height: 8),
          _PasswordStrengthIndicator(strength: _passwordStrength!),
        ],
      ],
    );
  }
}

/// Password strength indicator widget
class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final color = PasswordStrengthChecker.getStrengthColor(strength);
    final text = PasswordStrengthChecker.getStrengthText(strength);
    
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: (strength.index + 1) / 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Form validation mixin for easy integration
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _fieldErrors = {};
  
  void setFieldError(String fieldName, String? error) {
    setState(() {
      _fieldErrors[fieldName] = error;
    });
  }
  
  String? getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }
  
  void clearFieldError(String fieldName) {
    setState(() {
      _fieldErrors.remove(fieldName);
    });
  }
  
  void clearAllErrors() {
    setState(() {
      _fieldErrors.clear();
    });
  }
  
  bool hasErrors() {
    return _fieldErrors.values.any((error) => error != null);
  }
}

/// Debounced text field for search and real-time validation
class DebouncedTextField extends StatefulWidget {
  const DebouncedTextField({
    super.key,
    required this.onChanged,
    this.decoration,
    this.debounceTime = const Duration(milliseconds: 500),
    this.controller,
  });

  final void Function(String) onChanged;
  final InputDecoration? decoration;
  final Duration debounceTime;
  final TextEditingController? controller;

  @override
  State<DebouncedTextField> createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      widget.onChanged(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: widget.decoration,
    );
  }
}