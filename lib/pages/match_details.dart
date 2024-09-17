// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_app/constants/constants.dart';
import 'package:football_app/models/event_model.dart';
import 'package:football_app/tabs/commentary_tab.dart';
import 'package:football_app/tabs/match_info_tab.dart';
import 'package:football_app/tabs/overview_tab.dart';
import 'package:football_app/tabs/standings_tab.dart';
import 'package:http/http.dart' as http;

class MatchDetails extends StatefulWidget {
  final int fixtureId;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int homeScore;
  final int awayScore;
  final String homeTeamName;
  final String awayTeamName;
  final int homeTeamId;
  final int awayTeamId;

  const MatchDetails({
    Key? key,
    required this.homeTeamLogo,
    required this.homeScore,
    required this.awayScore,
    required this.awayTeamLogo,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.fixtureId,
    required this.homeTeamId,
    required this.awayTeamId,
  }) : super(key: key);

  @override
  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  late Future<Map<String, List<Events>>> fixturesFuture;
  Map<String, List<Events>> events = {};
  late TabController _tabController;
  Map<String, List<Events>> eventMap = {};

  List<String> tabs = [
    'Match Info',
    'Summary',
    'Commentary',
    'Stats',
    'Lineups',
    'Standings',
    'H2H',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    fixturesFuture = processFixturesById(widget.fixtureId);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollPosition = _scrollController.position.pixels;
        });
      });
  }

  Future<Map<String, List<Events>>> processFixturesById(int fixtureId) async {
    try {
      var response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/fixtures/$fixtureId?include=events.type'),
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
        print('DataList: $dataList');

        for (var event in dataList) {
          const goalEvent = 'Goal';
          const ownGoalEvent = 'Own Goal';
          const penaltyGoalEvent = 'Penalty';
          if (event.type.name.contains(goalEvent) ||
              event.type.name.contains(ownGoalEvent) ||
              event.type.name.contains(penaltyGoalEvent)) {
            if (!eventMap.containsKey(event.type.name)) {
              eventMap[event.type.name] = [];
            }
            eventMap[event.type.name]!.add(event);
          }
          print(eventMap);
        }

        // Sorting events within each type by minute
        for (var eventsList in eventMap.values) {
          eventsList.sort((a, b) => a.minute.compareTo(b.minute));
        }

        return eventMap;
      }
    } on SocketException {
      print('No internet!');
      const snackBar = SnackBar(content: Text('No internet Connection!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print('Error: $e');
    }

    return {};
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<String>> groupEventsByPlayer(List<Events> events) {
    Map<String, List<String>> playerEvents = {};
    for (var event in events) {
      String eventType = '';
      if (event.type.name == 'Goal') {
        eventType = '';
      } else if (event.type.name == 'Penalty') {
        eventType = ' (P)';
      } else if (event.type.name == 'Own Goal') {
        eventType = ' (OG)';
      } else if (event.type.name == 'Missed Penalty') {
        eventType = ' (MP)';
      }

      String minuteString;
      if (event.extraTime != null) {
        minuteString = '${event.minute}+${event.extraTime}';
      } else {
        minuteString = event.minute.toString();
      }

      final eventString = '$minuteString\'$eventType';

      if (playerEvents.containsKey(event.playerName)) {
        playerEvents[event.playerName]!.add(eventString);
      } else {
        playerEvents[event.playerName] = [eventString];
      }
    }
    return playerEvents;
  }

  int _parseMinute(String minuteString, String? extraTime) {
    int mainMinute = int.tryParse(minuteString) ?? 0;
    int additionalMinute = extraTime != null ? int.tryParse(extraTime) ?? 0 : 0;

    return mainMinute * 100 + additionalMinute;
  }

  @override
  Widget build(BuildContext context) {
    double appBarOpacity = _scrollPosition / 170.0.h;
    appBarOpacity = appBarOpacity > 1 ? 1 : appBarOpacity;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: 0,
              title: AnimatedOpacity(
                opacity: appBarOpacity,
                duration: const Duration(milliseconds: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.network(
                      widget.homeTeamLogo,
                      height: 25,
                      width: 25,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.circle,
                          color: Colors.grey,
                          size: 25,
                        );
                      },
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${widget.homeScore} - ${widget.awayScore}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 10.w),
                    Image.network(
                      widget.awayTeamLogo,
                      height: 25,
                      width: 25,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.circle,
                          color: Colors.grey,
                          size: 25,
                        );
                      },
                    ),
                  ],
                ),
              ),
              expandedHeight: 170.h,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(top: 53.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 18.h),
                      // height: 200.h,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.network(
                                widget.homeTeamLogo,
                                height: 50,
                                width: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.circle,
                                    color: Colors.grey,
                                    size: 52,
                                  );
                                },
                              ),
                              Text(
                                '${widget.homeScore} - ${widget.awayScore}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Image.network(
                                widget.awayTeamLogo,
                                height: 50,
                                width: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.circle,
                                    color: Colors.grey,
                                    size: 52,
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.homeTeamName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Full Time',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.awayTeamName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          FutureBuilder<Map<String, List<Events>>>(
                            future: fixturesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text(''),
                                );
                              } else {
                                final homeEvents = snapshot.data!.values
                                    .expand((events) => events.where((event) =>
                                        event.participantId ==
                                        widget.homeTeamId))
                                    .toList();
                                final awayEvents = snapshot.data!.values
                                    .expand((events) => events.where((event) =>
                                        event.participantId ==
                                        widget.awayTeamId))
                                    .toList();
                                // Sort events by minute
                                homeEvents.sort((a, b) {
                                  int aTotalMinute = _parseMinute(
                                      a.minute.toString(),
                                      a.extraTime.toString());
                                  int bTotalMinute = _parseMinute(
                                      b.minute.toString(),
                                      b.extraTime.toString());
                                  return aTotalMinute.compareTo(bTotalMinute);
                                });
                                awayEvents.sort((a, b) {
                                  int aTotalMinute = _parseMinute(
                                      a.minute.toString(),
                                      a.extraTime.toString());
                                  int bTotalMinute = _parseMinute(
                                      b.minute.toString(),
                                      b.extraTime.toString());
                                  return aTotalMinute.compareTo(bTotalMinute);
                                });
                                // Group events by player
                                final groupedHomeEvents =
                                    groupEventsByPlayer(homeEvents);
                                final groupedAwayEvents =
                                    groupEventsByPlayer(awayEvents);
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: groupedHomeEvents.entries
                                            .map((entry) {
                                          String playerName = entry.key;
                                          List<String> minutes = entry.value;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      playerName
                                                          .split(' ')
                                                          .last,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    minutes.join(', '),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // SizedBox(height: 10.h),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.awayScore == 0 &&
                                              widget.homeScore == 0
                                          ? false
                                          : true,
                                      child: Expanded(
                                        child: Image.asset(
                                          'assets/ball.png',
                                          height: 12,
                                          width: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: groupedAwayEvents.entries
                                            .map((entry) {
                                          String playerName = entry.key;
                                          List<String> minutes = entry.value;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      playerName
                                                          .split(' ')
                                                          .last,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    minutes.join(', '),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // SizedBox(height: 10.h),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(-30.h),
                child: SizedBox(
                  child: Container(
                    color: Colors.white, // Ensure the color remains consistent
                  ),
                ),
              ),
              flexibleSpace: DefaultTabController(
                length: tabs.length,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade700,
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'UberMove',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontFamily: 'UberMove',
                    fontWeight: FontWeight.normal,
                  ),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: tabs.map((tab) {
                    return Container(
                      width: 80.w, // Set a fixed width for each tab
                      alignment: Alignment.center,
                      child: Text(
                        tab,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: tabs.map((tab) {
            switch (tab) {
              case 'Match Info':
                // return MatchInfoTab();
                return MatchInfoTab(
                  fixtureId: widget.fixtureId,
                );
              case 'Summary':
                return OverviewTab(
                  fixtureId: widget.fixtureId,
                  homeId: widget.homeTeamId,
                  awayId: widget.awayTeamId,
                );
              // return const Center(child: Text('1'));
              case 'Commentary':
                return CommentaryTab(
                  fixtureId: widget.fixtureId,
                );
              case 'Stats':
                return const Center(child: Text('Unknown Tab'));
              case 'Lineups':
                return const Center(child: Text('Unknown Tab'));
              case 'Standings':
                return const StandingsTab();
              case 'H2H':
                return const Center(child: Text('Unknown Tab'));
              default:
                return const Center(child: Text('Unknown Tab'));
            }
          }).toList(),
        ),
      ),
    );
  }
}
