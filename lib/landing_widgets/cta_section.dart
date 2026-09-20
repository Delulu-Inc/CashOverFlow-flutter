import 'package:cash_overflow/SignUp_page.dart';
import 'package:flutter/material.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(96, 80, 0, 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF000F16),
            Color(0xFF000D13),
            Color(0xFF010A0F),
            Color(0xFF01060A),
            Color(0xFF000000),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Give your business back the\n'
                  'clarity cash flow uncertainty was\n'
                  'taking away.',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFFCFCFC),
                    height: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 48),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    side: const BorderSide(color: Color(0xFFFCFCFC), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    foregroundColor: const Color(0xFFFCFCFC),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Demo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFCFCFC),
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.north_east,
                        size: 24,
                        color: Color(0xFFFCFCFC),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Image.asset(
              'assets/images/CTA.jpg',
              width: 444,
              height: 444,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 444,
                  height: 444,
                  color: const Color(0xFF11141A),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white24,
                      size: 50,
                    ),
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
