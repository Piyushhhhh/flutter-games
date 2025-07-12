import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/games_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for retro theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FlutterGamesApp());
}

class FlutterGamesApp extends StatelessWidget {
  const FlutterGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Home screen with retro interface
      home: const RetroGameHub(),

      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
          ),
          child: child!,
        );
      },
    );
  }
}

class RetroGameHub extends StatefulWidget {
  const RetroGameHub({super.key});

  @override
  State<RetroGameHub> createState() => _RetroGameHubState();
}

class _RetroGameHubState extends State<RetroGameHub>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _neonController;
  late Animation<double> _neonAnimation;
  int _currentPage = 0;

  final List<RetroPageData> _pages = [
    const RetroPageData(
      title: 'GAMES',
      icon: Icons.videogame_asset,
      color: Color(0xFF00FFFF),
      content: GamesMenu(),
    ),
    const RetroPageData(
      title: 'STATS',
      icon: Icons.analytics,
      color: Color(0xFF00FF00),
      content: RetroStatsPage(),
    ),
    const RetroPageData(
      title: 'PROFILE',
      icon: Icons.person,
      color: Color(0xFFFF0080),
      content: RetroProfilePage(),
    ),
    const RetroPageData(
      title: 'CONFIG',
      icon: Icons.settings,
      color: Color(0xFFFFFF00),
      content: RetroSettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _neonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _neonAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neonController,
      curve: Curves.easeInOut,
    ));
    _neonController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _neonController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.heavyImpact();
  }

  void _onBottomNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return _pages[index].content;
        },
      ),
      bottomNavigationBar: _buildRetroBottomNav(),
    );
  }

  Widget _buildRetroBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF00FFFF),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_pages.length, (index) {
          final isSelected = index == _currentPage;
          final page = _pages[index];

          return GestureDetector(
            onTap: () => _onBottomNavTap(index),
            child: AnimatedBuilder(
              animation: _neonAnimation,
              builder: (context, child) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? page.color.withOpacity(0.2)
                        : Colors.transparent,
                    border: isSelected
                        ? Border.all(
                            color: page.color,
                            width: 1,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: page.color
                                  .withOpacity(_neonAnimation.value * 0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        page.icon,
                        size: 20,
                        color: isSelected
                            ? Color.lerp(page.color, Colors.white,
                                _neonAnimation.value * 0.3)
                            : const Color(0xFF666666),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        page.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'monospace',
                          color: isSelected
                              ? Color.lerp(page.color, Colors.white,
                                  _neonAnimation.value * 0.3)
                              : const Color(0xFF666666),
                          letterSpacing: 1,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 20,
                          height: 2,
                          color: page.color,
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class RetroPageData {
  final String title;
  final IconData icon;
  final Color color;
  final Widget content;

  const RetroPageData({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });
}

// Retro Stats Page
class RetroStatsPage extends StatelessWidget {
  const RetroStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D001A),
            Color(0xFF1A0033),
            Color(0xFF000000),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00FF00),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF00).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 40,
                      color: Color(0xFF00FF00),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'STATISTICS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFF00FF00),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: const Color(0xFF00FF00),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildRetroStatItem(
                          'GAMES PLAYED', '0', const Color(0xFF00FFFF)),
                      const SizedBox(height: 16),
                      _buildRetroStatItem(
                          'HIGH SCORE', '0', const Color(0xFFFF0080)),
                      const SizedBox(height: 16),
                      _buildRetroStatItem(
                          'PLAY TIME', '00:00:00', const Color(0xFFFFFF00)),
                      const SizedBox(height: 16),
                      _buildRetroStatItem(
                          'ACHIEVEMENTS', '0/50', const Color(0xFF8A2BE2)),
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

  Widget _buildRetroStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: color,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Retro Profile Page
class RetroProfilePage extends StatelessWidget {
  const RetroProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D001A),
            Color(0xFF1A0033),
            Color(0xFF000000),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFF0080),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF0080).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFFFF0080),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'USER PROFILE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFFFF0080),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Profile avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0080).withOpacity(0.2),
                  border: Border.all(
                    color: const Color(0xFFFF0080),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFFFF0080),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PLAYER_001',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Color(0xFFFF0080),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'LEVEL: NEWBIE',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Color(0xFF00FFFF),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: const Color(0xFFFF0080),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'PROFILE DATA LOADING...\n\nCOMPLETE GAMES TO\nUNLOCK ACHIEVEMENTS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: Color(0xFF666666),
                        letterSpacing: 1,
                        height: 1.5,
                      ),
                    ),
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

// Retro Settings Page
class RetroSettingsPage extends StatelessWidget {
  const RetroSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D001A),
            Color(0xFF1A0033),
            Color(0xFF000000),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFFFF00),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFFF00).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      size: 40,
                      color: Color(0xFFFFFF00),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'SYSTEM CONFIG',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFFFFFF00),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: const Color(0xFFFFFF00),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildRetroSettingItem(
                          'SOUND FX', true, const Color(0xFF00FFFF)),
                      const SizedBox(height: 16),
                      _buildRetroSettingItem(
                          'MUSIC', true, const Color(0xFF00FF00)),
                      const SizedBox(height: 16),
                      _buildRetroSettingItem(
                          'VIBRATION', true, const Color(0xFFFF0080)),
                      const SizedBox(height: 16),
                      _buildRetroSettingItem(
                          'SCANLINES', true, const Color(0xFF8A2BE2)),
                      const SizedBox(height: 16),
                      _buildRetroSettingItem(
                          'CRT MODE', false, const Color(0xFFFFFF00)),
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

  Widget _buildRetroSettingItem(String label, bool value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: color,
              letterSpacing: 1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value ? color.withOpacity(0.3) : Colors.transparent,
              border: Border.all(
                color: color,
                width: 1,
              ),
            ),
            child: Text(
              value ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: color,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
