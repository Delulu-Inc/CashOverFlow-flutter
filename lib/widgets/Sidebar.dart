import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SidebarWidget extends StatefulWidget {
  final String currentRoute;
  final ValueChanged<String>? onNavigate;

  const SidebarWidget({
    super.key,
    this.currentRoute = 'Profile Settings',
    this.onNavigate,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late String _activeItem;

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

  @override
  void didUpdateWidget(covariant SidebarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      setState(() {
        _activeItem = widget.currentRoute;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
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

        final role = data['role'] ?? data['jobTitle'] ?? 'Member';

        // Cache role locally for page route guards
        await prefs.setString('user_role', role);

        if (!mounted) return;
        setState(() {
          _firstuserName = data['firstName'] ?? 'User';
          _lastuserName = data['lastName'] ?? '';
          _userRole = role;
          _isLoadingUser = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _firstuserName = 'User';
          _lastuserName = '';
          _userRole = '';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _firstuserName = 'User';
        _lastuserName = '';
        _userRole = '';
        _isLoadingUser = false;
      });
    }
  }

  void _navigate(String itemName, String route) {
    debugPrint('CLICKED: $itemName');
    debugPrint('ROUTE: $route');

    setState(() {
      _activeItem = itemName;
    });

    widget.onNavigate?.call(route);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = _userRole.trim().toLowerCase() == 'owner';

    return Container(
      width: 260,
      color: const Color(0xFF0A0F1D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // DASHBOARD (Visible to everyone)
          _buildNavItem(
            Icons.dashboard_rounded,
            'Dashboard',
            onTap: () {
              _navigate('Dashboard', '/dashboard');
            },
          ),

          // AI SUPPORT (Visible to everyone)
          _buildNavItem(
            Icons.auto_awesome,
            'AI Support',
            onTap: () {
              _navigate('AI Support', '/ai-support');
            },
          ),

          // RESTRICTED TO OWNER ONLY
          if (isOwner) ...[
            // TEAM MANAGEMENT
            _buildNavItem(
              Icons.group_outlined,
              'Team Management',
              onTap: () {
                _navigate('Team Management', '/team-management');
              },
            ),

            // SUBSCRIPTION
            _buildNavItem(
              Icons.credit_card,
              'Subscription',
              onTap: () {
                _navigate('Subscription', '/subscription');
              },
            ),
          ],

          // PROFILE SETTINGS (Visible to everyone)
          _buildNavItem(
            Icons.settings_outlined,
            'Profile Settings',
            onTap: () {
              _navigate('Profile Settings', '/profile-settings');
            },
          ),

          const Spacer(),

          const Divider(color: Color(0xFF1E293B), height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildNavItem(
              Icons.logout_rounded,
              'Log out',
              isLogout: true,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1D4ED8),
                  child: Text(
                    (_firstuserName.isNotEmpty)
                        ? _firstuserName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                                Flexible(
                                  child: Text(
                                    _firstuserName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _lastuserName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
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
