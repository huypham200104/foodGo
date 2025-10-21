import 'package:flutter/material.dart';

class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialButton(
          label: "Google",
          icon: Icons.g_mobiledata,
          color: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.black12,
          logo: 'assets/icons/google.png', // thêm file logo Google
        ),
        SizedBox(width: 20),
        _SocialButton(
          label: "Facebook",
          icon: Icons.facebook,
          color: Color(0xFF1877F2),
          textColor: Colors.white,
          logo: 'assets/icons/facebook.png', // thêm file logo Facebook
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final String? logo;
  final Color? borderColor;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.logo,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (logo != null)
              Image.asset(
                logo!,
                width: 24,
                height: 24,
              )
            else
              Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
