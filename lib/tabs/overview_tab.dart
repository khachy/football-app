// ignore_for_file: use_build_context_synchronously, avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_app/constants/constants.dart';
import 'package:football_app/models/event_model.dart';
// import 'package:football_app/models/fixture_model.dart';
import 'package:football_app/models/period_model.dart';
import 'package:football_app/models/score_model.dart';
import 'package:http/http.dart' as http;

class OverviewTab extends StatefulWidget {
  final int fixtureId;
  final int homeId;
  final int awayId;

  const OverviewTab({
    super.key,
    required this.fixtureId,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  late Future<Map<String, List<Events>>> eventFuture;
  String? description;
  int? timeAddedForFirstHalf;
  int? timeAddedForSecondHalf;
  Timer? countdownTimer;
  int? firstHalfHomeScore;
  int? firstHalfAwayScore;
  int? secondHalfAwayScore;
  int? secondHalfHomeScore;
  int? additionalMin;

  Future<Map<String, List<Events>>> processEventsById(int fixtureId) async {
    try {
      var response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/fixtures/$fixtureId?include=scores;periods;events.type'),
        headers: {
          'Authorization': Constants.apiToken,
        },
      );

      if (response.statusCode == 200) {
        final responseDecode = jsonDecode(response.body);
        final List<dynamic> dataList =
            (responseDecode['data']['events'] as List)
                .map((event) => Events.fromJson(event as Map<String, dynamic>))
                .toList();
        final List<dynamic> periodList = (responseDecode['data']['periods']
                as List)
            .map((period) => Period.fromJson(period as Map<String, dynamic>))
            .toList();
        final List<dynamic> scoreList =
            (responseDecode['data']['scores'] as List)
                .map((score) => Scores.fromJson(score as Map<String, dynamic>))
                .toList();
        log('Data: $dataList');

        // print('Period: ${responseDecode['data']['periods']}');

        for (var period in periodList) {
          description = period.description;
          if (period.description == '1st-half') {
            timeAddedForFirstHalf = period.timeAdded;
          } else if (period.description == '2nd-half') {
            timeAddedForSecondHalf = period.timeAdded;
          }
        }
        for (var score in scoreList) {
          if (score.description == '1ST_HALF' &&
              score.participantId == widget.homeId) {
            firstHalfHomeScore = score.goals;
          } else if (score.description == '1ST_HALF' &&
              score.participantId == widget.awayId) {
            firstHalfAwayScore = score.goals;
          } else if (score.description == 'CURRENT' &&
              score.participantId == widget.awayId) {
            secondHalfAwayScore = score.goals;
          } else if (score.description == 'CURRENT' &&
              score.participantId == widget.homeId) {
            secondHalfHomeScore = score.goals;
          }

          // print(awayScore);
        }

        Map<String, List<Events>> eventMap = {};

        for (var event in dataList) {
          const goalEvent = 'Goal';
          const ownGoalEvent = 'Own Goal';
          const penaltyGoalEvent = 'Penalty';
          const yellowCardEvent = 'Yellowcard';
          const redCardEvent = 'Redcard';
          const varEvent = 'VAR';
          const missedPenaltyEvent = 'Missed Penalty';
          const substitutionEvent = 'Substitution';
          const cardReviewedEvent = 'Card reviewed';
          if (event.type.name.contains(goalEvent) ||
              event.type.name.contains(ownGoalEvent) ||
              event.type.name.contains(penaltyGoalEvent) ||
              event.type.name.contains(yellowCardEvent) ||
              event.type.name.contains(redCardEvent) ||
              event.type.name.contains(varEvent) ||
              event.type.name.contains(substitutionEvent) ||
              event.type.name.contains(missedPenaltyEvent) ||
              event.type.name.contains(cardReviewedEvent)) {
            if (!eventMap.containsKey(event.type.name)) {
              eventMap[event.type.name] = [];
            }
            eventMap[event.type.name]!.add(event);
          }
        }

        // Sorting events within each type by minute
        for (var eventsList in eventMap.values) {
          eventsList.sort((a, b) {
            int aTotalMinute =
                _parseMinute(a.minute.toString(), a.extraTime.toString());
            int bTotalMinute =
                _parseMinute(b.minute.toString(), b.extraTime.toString());
            return aTotalMinute.compareTo(bTotalMinute);
          });
        }
        print('evebt Map: $eventMap');
        return eventMap;
      }
    } on SocketException {
      print('No internet!');
      const snackBar = SnackBar(content: Text('No internet Connection!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on TimeoutException {
      print('No internet!');
      const snackBar = SnackBar(
          content: Text('No active internet connection to fetch data!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print('Error: $e');
    }

    return {};
  }

  int _parseMinute(String minuteString, String? extraTime) {
    int mainMinute = int.tryParse(minuteString) ?? 0;
    int additionalMinute = extraTime != null ? int.tryParse(extraTime) ?? 0 : 0;

    additionalMin = additionalMinute;

    return mainMinute * 100 + additionalMinute;
  }

  String constructMinuteString(int minute, int? extraTime) {
    if (extraTime != null) {
      return '$minute+$extraTime';
    } else {
      return minute.toString();
    }
  }

  @override
  void initState() {
    eventFuture = processEventsById(widget.fixtureId);
    super.initState();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

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
          child: FutureBuilder<Map<String, List<Events>>>(
            future: eventFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Transform.scale(
                    scale: 0.6,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.5.w,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No overview available yet!'),
                );
              } else {
                final events =
                    snapshot.data!.values.expand((events) => events).toList();
                events.sort((a, b) {
                  int aTotalMinute =
                      _parseMinute(a.minute.toString(), a.extraTime.toString());
                  int bTotalMinute =
                      _parseMinute(b.minute.toString(), b.extraTime.toString());
                  return aTotalMinute.compareTo(bTotalMinute);
                });

                List<Widget> eventWidgets = [];

                for (int i = 0; i < events.length; i++) {
                  final event = events[i];
                  final isHomeEvent = event.participantId == widget.homeId;
                  final eventIcon = getEventIcon(event.type.name);
                  String? assistInfo;
                  if (event.relatedPlayerName != null &&
                      event.type.name != 'Missed Penalty') {
                    assistInfo = '${event.relatedPlayerName}';
                  } else if (event.type.name == 'Yellowcard') {
                    assistInfo = 'Foul';
                  } else if (event.type.name == 'Redcard') {
                    assistInfo = 'Sent Off';
                  } else if (event.type.name == 'VAR') {
                    assistInfo = '${event.addition}';
                  } else if (event.type.name == 'Penalty') {
                    assistInfo = 'Penalty';
                  } else if (event.type.name == 'Own Goal') {
                    assistInfo = 'Own Goal';
                  } else if (event.type.name == 'Goal') {
                    assistInfo = 'Goal';
                  } else if (event.type.name == 'Missed Penalty') {
                    assistInfo = '${event.addition}';
                  } else {
                    assistInfo = '${event.addition}';
                  }
                  String? result = event.result;

                  final minuteString =
                      constructMinuteString(event.minute, event.extraTime);

                  eventWidgets.add(
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: isHomeEvent
                                    ? eventInfo(
                                        event.playerName,
                                        assistInfo,
                                        eventIcon,
                                        result,
                                        event.type.name,
                                        event.isInjured ?? false,
                                      )
                                    : const SizedBox(),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 28.w),
                                child: Text(
                                  '$minuteString\'',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: !isHomeEvent
                                    ? eventInfo(
                                        event.playerName,
                                        assistInfo,
                                        eventIcon,
                                        result,
                                        event.type.name,
                                        event.isInjured ?? false,
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                          // Add the HT marker if this is the last event before the 45th minute
                          Visibility(
                            visible: i < events.length - 1 &&
                                _parseMinute(events[i + 1].minute.toString(),
                                        events[i + 1].extraTime.toString()) >=
                                    4500 &&
                                _parseMinute(event.minute.toString(),
                                        event.extraTime.toString()) <
                                    4500,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 5.h,
                              ),
                              child: Center(
                                child: timeAddedForFirstHalf != null
                                    ? Text(
                                        timeAddedForFirstHalf! == 1
                                            ? '+$timeAddedForFirstHalf minute added'
                                            : '+$timeAddedForFirstHalf minutes added',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ),

                          Visibility(
                            visible: (i < events.length - 1 &&
                                _parseMinute(events[i + 1].minute.toString(),
                                        events[i + 1].extraTime.toString()) >
                                    (4500 + additionalMin!) &&
                                _parseMinute(event.minute.toString(),
                                        event.extraTime.toString()) <=
                                    (4500 + additionalMin!)),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 5.h,
                              ),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Halftime ($firstHalfHomeScore - $firstHalfAwayScore)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (i < events.length - 1 &&
                                _parseMinute(events[i + 1].minute.toString(),
                                        events[i + 1].extraTime.toString()) >=
                                    9000 &&
                                _parseMinute(event.minute.toString(),
                                        event.extraTime?.toString()) <
                                    9000),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 8.h,
                              ),
                              child: Center(
                                child: timeAddedForSecondHalf != null
                                    ? Text(
                                        timeAddedForSecondHalf! == 1
                                            ? '+$timeAddedForSecondHalf minute added'
                                            : '+$timeAddedForSecondHalf minutes added',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: eventWidgets.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return eventWidgets[index];
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget eventInfo(
    String playerName,
    String assistInfo,
    Image eventIcon,
    String? result,
    String eventType,
    bool isInjured,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        eventIcon,
        SizedBox(width: 5.w),
        Flexible(
          // Use Flexible instead of Expanded
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result != null ? '$playerName scores! ($result)' : playerName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: eventType == 'Goal' ||
                          eventType == 'Penalty' ||
                          eventType == 'Own Goal'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                      eventType == 'Substitution' ? Colors.green : Colors.black,
                ),
              ),
              Text(
                assistInfo == 'null'
                    ? 'VAR review'
                    : eventType == 'Substitution' ||
                            eventType == 'Yellowcard' ||
                            eventType == 'Redcard' ||
                            eventType == 'Penalty' ||
                            eventType == 'VAR' ||
                            eventType == 'Missed Penalty' ||
                            eventType == 'Own Goal' ||
                            eventType == 'Card Reviewed'
                        ? assistInfo
                        : 'Assist: $assistInfo',
                style: TextStyle(
                  fontSize: 12,
                  color: eventType == 'Substitution'
                      ? Colors.red
                      : const Color.fromRGBO(147, 149, 152, 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Image getEventIcon(String eventType) {
    switch (eventType) {
      case 'Goal':
      case 'Penalty':
        return Image.asset(
          'assets/ball.png',
          height: 15,
        );
      case 'Own Goal':
        return Image.asset(
          'assets/ball.png',
          height: 15,
          color: Colors.black38,
          colorBlendMode: BlendMode.srcIn,
        );
      case 'Yellowcard':
        return Image.asset('assets/yellow card.jpg', height: 15);
      case 'Redcard':
        return Image.asset('assets/red card.png', height: 15);
      case 'VAR':
        return Image.asset('assets/var.png', height: 15);
      case 'Substitution':
        return Image.asset('assets/substitute.png', height: 15);
      case 'Missed Penalty':
        return Image.asset(
          'assets/missed.png',
          height: 15,
          color: Colors.red,
          colorBlendMode: BlendMode.srcIn,
        );
      default:
        return Image.asset(
          'assets/var.png',
          height: 15,
        ); // Default to var icon for unknown types
    }
  }
}
