import 'dart:convert';
import 'package:cash_overflow/ai_support.dart';
import 'package:cash_overflow/subscribe/subscription_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cash_overflow/Dashboard_page.dart';
import 'package:cash_overflow/Profile_settings_page.dart';
import 'package:cash_overflow/SignIn_page.dart';
import 'package:flutter/material.dart';

class SidebarWidget extends StatefulWidget {
  final String currentRoute;

  const SidebarWidget({super.key, this.currentRoute = 'Profile Settings'});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late String _activeItem;

  // متغيرة لتخزين بيانات المستخدم
  String _firstuserName = '';
  String _lastuserName = '';
  String _userRole = '';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _activeItem = widget.currentRoute;
    _fetchUserData();
  }

  // دالة لجلب البيانات من الـ API
  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // استخراج التوكين (تأكد من مطابقة الاسم Key الذي استخدمته عند الحفظ)
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        setState(() {
          _firstuserName = 'Guest';
          _lastuserName = '';
          _userRole = '';
          _isLoadingUser = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://cashoverflow-api.runasp.net/v1/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // قم بتعديل المسميات حسب مفاتيح الـ JSON القادمة من الـ API لديك
          _firstuserName = data['firstName'] ?? 'User';
          _lastuserName = data['lastName'] ?? '';
          _userRole = data['role'] ?? data['jobTitle'] ?? 'Member';
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _firstuserName = 'User';
          _lastuserName = '';
          _userRole = '';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _firstuserName = 'User';
        _lastuserName = '';
        _userRole = '';
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF0A0F1D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Image.asset('assets/img/logo.png', width: 26, height: 26),
                const SizedBox(width: 12),
                const Text(
                  'Cash Overflow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dashboard
          _buildNavItem(
            Icons.dashboard_rounded,
            'Dashboard',
            onTap: () {
              setState(() => _activeItem = 'Dashboard');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),

          // AI Support
          _buildNavItem(
            Icons.auto_awesome,
            'AI Support',
            onTap: () {
              setState(() => _activeItem = 'AI Support');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),

          // Team Management
          _buildNavItem(
            Icons.group_outlined,
            'Team Management',
            onTap: () {
              setState(() => _activeItem = 'Team Management');
            },
          ),

          // Subscription
          _buildNavItem(
            Icons.credit_card,
            'Subscription',
            onTap: () {
              setState(() => _activeItem = 'Subscription');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionBillingScreen()),
              );
            },
          ),

          // Profile Settings
          _buildNavItem(
            Icons.settings_outlined,
            'Profile Settings',
            onTap: () {
              setState(() => _activeItem = 'Profile Settings');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsPage(),
                ),
              );
            },
          ),

          const Spacer(),
          const Divider(color: Color(0xFF1E293B), height: 1),

          // Log Out
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildNavItem(
              Icons.logout_rounded,
              'Log out',
              isLogout: true,
              onTap: () async {
                // مسح البيانات عند تسجيل الخروج
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          // User Info Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop',
                  ),
                ),
                const SizedBox(width: 12),

                // الجزء المطلوب لجلب البيانات ديناميكياً
                Expanded(
                  child: _isLoadingUser
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blueAccent,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _firstuserName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _lastuserName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (_userRole.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _userRole,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String title, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final bool isActive = _activeItem == title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout
                      ? Colors.redAccent
                      : (isActive ? Colors.blueAccent : Colors.grey[400]),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isLogout
                        ? Colors.redAccent
                        : (isActive ? Colors.white : Colors.grey[400]),
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
