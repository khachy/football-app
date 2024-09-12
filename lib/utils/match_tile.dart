import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MatchTile extends StatelessWidget {
  final String homeTeamLogo;
  final String homeTeamName;
  final String awayTeamLogo;
  final String awayTeamName;
  final int homeTeamScore;
  final int awayTeamScore;
  final String length;
  // final Color color;
  final DateTime fixtureTime;
  final DateTime dateTime;
  final VoidCallback onTap;
  const MatchTile({
    super.key,
    required this.homeTeamLogo,
    required this.homeTeamName,
    required this.awayTeamLogo,
    required this.awayTeamName,
    required this.homeTeamScore,
    required this.awayTeamScore,
    required this.length,
    required this.onTap,
    // required this.color,
    required this.dateTime,
    required this.fixtureTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
          ),
          height: 70.h,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network(
                        homeTeamLogo,
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.circle,
                            color: Colors.grey,
                            size: 25,
                          );
                        },
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        homeTeamName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  Visibility(
                    visible: length != toTime(fixtureTime),
                    child: Text(
                      homeTeamScore.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: length == toTime(fixtureTime) ? 10.w : 40.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20.h,
                      width: length == toTime(fixtureTime) ? 70.w : 20.w,
                      child: Column(
                        children: [
                          Text(
                            length.toString(),
                            style: TextStyle(
                              color: length == 'FT' ||
                                      length == toTime(fixtureTime) ||
                                      length == 'HT'
                                  ? Colors.grey
                                  : Colors.green.shade500,
                              fontSize: length == toTime(fixtureTime) ? 12 : 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Visibility(
                            visible: length != 'FT' &&
                                length != 'HT' &&
                                length != toTime(fixtureTime),
                            child: LinearProgressIndicator(
                              color: Colors.green.shade500,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network(
                        awayTeamLogo,
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.circle,
                            color: Colors.grey,
                            size: 25,
                          );
                        },
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        awayTeamName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  Visibility(
                    visible: length != toTime(fixtureTime),
                    child: Text(
                      awayTeamScore.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String toTime(DateTime dateTime) {
    DateTime oneHourAhead = dateTime.add(const Duration(hours: 1));
    return DateFormat('hh:mm a').format(oneHourAhead.toLocal());
  }
}
