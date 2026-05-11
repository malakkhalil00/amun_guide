// 📁 lib/screens/general/about_us_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.pyramids,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.bgCard),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.bgDark],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              AppAssets.logo,
                              height: 32,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.explore,
                                color: AppColors.gold,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Amun Guide',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Discover Egypt Like Never Before',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── About ────────────────────────────
                _sectionTitle('About Amun Guide'),
                const SizedBox(height: 12),
                _card(
                  child: const Text(
                    'Amun Guide is your ultimate travel companion for exploring the wonders of Egypt. '
                    'From the majestic pyramids of Giza to the serene temples of Luxor, we connect '
                    'travelers with certified local guides to create unforgettable experiences.\n\n'
                    'Our platform brings together the rich history and culture of Egypt with modern '
                    'technology, making it easier than ever to plan, book, and enjoy your Egyptian adventure.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Stats ────────────────────────────
                _sectionTitle('By the Numbers'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('500+', 'Tours')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('200+', 'Guides')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('50+', 'Destinations')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('10K+', 'Travelers')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('4.9★', 'Rating')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('5+', 'Years')),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Mission ──────────────────────────
                _sectionTitle('Our Mission'),
                const SizedBox(height: 12),
                _card(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flag_outlined, color: AppColors.gold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'To make Egypt\'s treasures accessible to every traveler through authentic, '
                          'safe, and memorable guided experiences — while supporting local communities '
                          'and preserving cultural heritage.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Team ─────────────────────────────
                _sectionTitle('Meet the Team'),
                const SizedBox(height: 12),
                _teamCard(
                  name: 'Ahmed Hassan',
                  role: 'CEO & Co-Founder',
                  image: AppAssets.ahmed,
                ),
                const SizedBox(height: 10),
                _teamCard(
                  name: 'Sarah Mohamed',
                  role: 'Head of Operations',
                  image: AppAssets.sarah,
                ),
                const SizedBox(height: 10),
                _teamCard(
                  name: 'Layla Nour',
                  role: 'Lead Developer',
                  image: AppAssets.sarah,
                ),

                const SizedBox(height: 28),

                // ── Features ─────────────────────────
                _sectionTitle('Why Amun Guide?'),
                const SizedBox(height: 12),
                _featureCard(Icons.verified_user_outlined, 'Certified Guides',
                    'All our guides are certified and background-checked.'),
                const SizedBox(height: 10),
                _featureCard(Icons.auto_awesome_outlined, 'AI-Powered',
                    'Personalized recommendations powered by Amun AI.'),
                const SizedBox(height: 10),
                _featureCard(Icons.payment_outlined, 'Secure Payments',
                    'Safe and transparent payment system.'),
                const SizedBox(height: 10),
                _featureCard(Icons.support_agent_outlined, '24/7 Support',
                    'We\'re always here to help you.'),

                const SizedBox(height: 28),

                // ── Contact ──────────────────────────
                _sectionTitle('Contact Us'),
                const SizedBox(height: 12),
                _card(
                  child: Column(
                    children: [
                      _contactRow(Icons.email_outlined, 'support@amunguide.com'),
                      const Divider(color: Colors.white10, height: 20),
                      _contactRow(Icons.phone_outlined, '+20 100 000 0000'),
                      const Divider(color: Colors.white10, height: 20),
                      _contactRow(Icons.location_on_outlined, 'Cairo, Egypt'),
                      const Divider(color: Colors.white10, height: 20),
                      _contactRow(Icons.language_outlined, 'www.amunguide.com'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Social ───────────────────────────
                _sectionTitle('Follow Us'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialBtn(Icons.facebook_outlined, 'Facebook'),
                    _socialBtn(Icons.camera_alt_outlined, 'Instagram'),
                    _socialBtn(Icons.alternate_email, 'Twitter'),
                    _socialBtn(Icons.play_circle_outline, 'YouTube'),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Version ──────────────────────────
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.explore,
                          color: AppColors.gold,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Amun Guide v1.0.0',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '© 2025 Amun Guide. All rights reserved.',
                        style: TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _teamCard({required String name, required String role, required String image}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.bgInput,
                  child: const Icon(Icons.person, color: Colors.white38),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                role,
                style: const TextStyle(color: AppColors.gold, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 14),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _socialBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: AppColors.gold, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}