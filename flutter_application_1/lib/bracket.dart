import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _GroupTeam {
  final String name;
  final dynamic place;

  _GroupTeam({required this.name, required this.place});

  factory _GroupTeam.fromJson(Map<String, dynamic> json) {
    return _GroupTeam(
      name: json['name'] as String? ?? '',
      place: json['place'],
    );
  }

  int? get numericPlace {
    if (place is int) return place;
    if (place is double) return place.toInt();
    return int.tryParse(place.toString());
  }
}

class Bracket extends StatefulWidget {
  const Bracket({super.key});

  @override
  State<Bracket> createState() => _BracketScreenState();
}

class _BracketScreenState extends State<Bracket> {
  List<List<_GroupTeam>> groups = [];
  List<String> bracket = [];
  List<String> semifinals = ['TBD', 'TBD', 'TBD', 'TBD'];
  List<String> finals = ['TBD', 'TBD', 'TBD', 'TBD'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final data = prefs.getString('table');
    if (data == null) return;
    try {
      final decoded = jsonDecode(data) as List;
      final loadedGroups = decoded
          .map<List<_GroupTeam>>(
            (g) => (g as List)
                .map((t) => _GroupTeam.fromJson(t as Map<String, dynamic>))
                .toList(),
          )
          .toList();
      setState(() {
        groups = loadedGroups;
      });
      if (groups.isNotEmpty) {
        _fillBracket();
      }
    } catch (err) {
      debugPrint('Failed to load data: $err');
    }
  }

  void _fillBracket() {
    final groupsByPlaces = groups.map((group) {
      final sorted = [...group];
      sorted.sort((a, b) {
        final ap = a.numericPlace;
        final bp = b.numericPlace;
        if (ap == null && bp == null) return 0;
        if (ap == null) return 1;
        if (bp == null) return -1;
        return ap.compareTo(bp);
      });
      return sorted;
    }).toList();

    final array = <String>[];
    for (final group in groupsByPlaces) {
      for (final team in group) {
        array.add(team.name);
      }
    }
    setState(() {
      bracket = array;
    });
  }

  String _bracketAt(int index) => index < bracket.length ? bracket[index] : '';

  void promoteTeam(String e) {
    setState(() {
      final next = [...semifinals];
      if (e == _bracketAt(0) || e == _bracketAt(7)) {
        next[0] = e;
      } else if (e == _bracketAt(2) || e == _bracketAt(5)) {
        next[1] = e;
      } else if (e == _bracketAt(1) || e == _bracketAt(6)) {
        next[2] = e;
      } else if (e == _bracketAt(4) || e == _bracketAt(3)) {
        next[3] = e;
      }
      semifinals = next;
    });
  }

  void promoteToFinals(String e) {
    setState(() {
      final next = [...finals];
      if (e == semifinals[0]) {
        next[0] = e;
        next[2] = semifinals[1];
      } else if (e == semifinals[1]) {
        next[0] = e;
        next[2] = semifinals[0];
      } else if (e == semifinals[2]) {
        next[1] = e;
        next[3] = semifinals[3];
      } else if (e == semifinals[3]) {
        next[1] = e;
        next[3] = semifinals[2];
      }
      finals = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(43, 108, 124, 1),
      alignment: Alignment.topCenter,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRoundOf8Column(),
              _buildSemifinalsColumn(),
              _buildFinalsColumn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundOf8Column() {
    return Expanded(      
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,          
          children: [
            _matchRow(
              leftLabel: '(A1) ${_bracketAt(0)}',
              rightLabel: '(B4) ${_bracketAt(7)}',
              onLeftTap: () => promoteTeam(_bracketAt(0)),
              onRightTap: () => promoteTeam(_bracketAt(7)),
            ),
            _matchRow(
              leftLabel: '(B2) ${_bracketAt(5)}',
              rightLabel: '(A3) ${_bracketAt(2)}',
              onLeftTap: () => promoteTeam(_bracketAt(5)),
              onRightTap: () => promoteTeam(_bracketAt(2)),
            ),
            _matchRow(
              leftLabel: '(A2) ${_bracketAt(1)}',
              rightLabel: '(B3) ${_bracketAt(6)}',
              onLeftTap: () => promoteTeam(_bracketAt(1)),
              onRightTap: () => promoteTeam(_bracketAt(6)),
            ),
            _matchRow(
              leftLabel: '(B1) ${_bracketAt(4)}',
              rightLabel: '(A4) ${_bracketAt(3)}',
              onLeftTap: () => promoteTeam(_bracketAt(4)),
              onRightTap: () => promoteTeam(_bracketAt(3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemifinalsColumn() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          spacing: 70,
          mainAxisAlignment: MainAxisAlignment.spaceAround,          
          children: [
            _matchRow(
              leftLabel: '(Q1) ${semifinals[0]}',
              rightLabel: '(Q2) ${semifinals[1]}',
              onLeftTap: () => promoteToFinals(semifinals[0]),
              onRightTap: () => promoteToFinals(semifinals[1]),
            ),
            _matchRow(
              leftLabel: '(Q3) ${semifinals[2]}',
              rightLabel: '(Q4) ${semifinals[3]}',
              onLeftTap: () => promoteToFinals(semifinals[2]),
              onRightTap: () => promoteToFinals(semifinals[3]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalsColumn() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          spacing: 40,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: const Text(
                'Finals🏆',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'BrightAura',
                ),
              ),
            ),
            _matchRow(
              leftLabel: '🥇(W1) ${finals[0]}',
              rightLabel: '(W2) ${finals[1]}',
            ),
            _matchRow(
              leftLabel: '🥉(L1) ${finals[2]}',
              rightLabel: '(L2) ${finals[3]}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchRow({
    required String leftLabel,
    required String rightLabel,
    VoidCallback? onLeftTap,
    VoidCallback? onRightTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _bracketButton(leftLabel, onLeftTap)),
          const Text(
            ' : ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontFamily: 'BrightAura',
            ),
          ),
          Expanded(child: _bracketButton(rightLabel, onRightTap)),
        ],
      ),
    );
  }

  Widget _bracketButton(String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.black,
          fontFamily: 'BrightAura',
        ),
      ),
    );
  }
}