import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'video_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phoneTail = user?.phoneNumber?.substring(
          (user.phoneNumber!.length - 4).clamp(0, user.phoneNumber!.length),
        ) ??
        '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('नमस्ते 👋',
                            style: TextStyle(color: Color(0xFF8B84A3), fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('...$phoneTail',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout, color: Colors.white54),
                      tooltip: 'लॉगआउट',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _ToolCard(
                      icon: Icons.video_call_rounded,
                      color: const Color(0xFFFF4D6D),
                      label: 'वीडियो अपलोड करें',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VideoScreen()),
                      ),
                    ),
                    _ToolCard(
                      icon: Icons.content_cut_rounded,
                      color: const Color(0xFF29E7CD),
                      label: 'वीडियो एडिट करें',
                      onTap: () {},
                    ),
                    _ToolCard(
                      icon: Icons.share_rounded,
                      color: const Color(0xFFB79BFF),
                      label: 'शेयर करें',
                      onTap: () {},
                    ),
                    _ToolCard(
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFFFFB25C),
                      label: 'व्यूज़ देखें',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 12, 22, 6),
                child: Text('हाल की वीडियो',
                    style: TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                height: 140,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('videos')
                      .orderBy('createdAt', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 22),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          'अभी तक कोई वीडियो नहीं — पहली वीडियो अपलोड करें!',
                          style: TextStyle(color: Color(0xFF8B84A3), fontSize: 12),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        return _VideoThumb(caption: data['caption'] ?? '');
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF4D6D),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideoScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1830),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _VideoThumb extends StatelessWidget {
  final String caption;
  const _VideoThumb({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2246), Color(0xFF1A1428)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 26),
      ),
    );
  }
}
