import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key});

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 7.w,
          vertical: 5.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 8.w,
            ),
            child: Column(
              children: [
                // First row with headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const Text(
                            '#',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          const Text(
                            'Team',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MP',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'W',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'D',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'L',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'PTS',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Wrap ListView.builder with Expanded
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero, // Remove padding around ListView
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return StandingItem(
                        position: index + 1,
                        teamName: 'Nottingham Forest',
                        matchesPlayed: 20 + index,
                        wins: 10 + index,
                        draws: 5,
                        losses: 3,
                        points: 40 + index,
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StandingItem extends StatelessWidget {
  final int position;
  final String teamName;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int points;

  const StandingItem({
    super.key,
    required this.position,
    required this.teamName,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text(
                  '$position',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Image.asset(
                  'assets/watermark.png',
                  height: 20,
                ),
                SizedBox(width: 10.w),
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$matchesPlayed',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$wins',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$draws',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$losses',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
