import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Team {
  String name;
  List<String> matches;
  double points;
  dynamic place; // 'TBD' or an int

  Team({
    required this.name,
    required this.matches,
    this.points = 0,
    this.place = 'TBD',
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'] as String? ?? '',
      matches: List<String>.from(json['matches'] ?? const []),
      points: double.tryParse(json['points'].toString()) ?? double.nan,
      place: json['place'] ?? 'TBD',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'matches': matches,
    'points': points.isNaN ? 'NaN' : points,
    'place': place,
  };
}

class TournamentTable extends StatefulWidget {
  const TournamentTable({super.key});

  @override
  State<TournamentTable> createState() => _TournamentTableScreenState();
}

class _TournamentTableScreenState extends State<TournamentTable> {
  static const List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  List<List<Team>> groups = [];
  List<TextEditingController> newTeamControllers = [];

  @override
  void initState() {
    super.initState();
    _resetNewTeamControllers();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in newTeamControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetNewTeamControllers() {
    for (final c in newTeamControllers) {
      c.dispose();
    }
    newTeamControllers = List.generate(4, (_) => TextEditingController());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('table');
    if (data == null) return;
    try {
      final decoded = jsonDecode(data) as List;
      setState(() {
        groups = decoded
            .map<List<Team>>(
              (g) => (g as List)
                  .map((t) => Team.fromJson(t as Map<String, dynamic>))
                  .toList(),
            )
            .toList();
      });
    } catch (err) {
      debugPrint('Failed to load data: $err');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        groups.map((g) => g.map((t) => t.toJson()).toList()).toList(),
      );
      await prefs.setString('table', encoded);
    } catch (err) {
      debugPrint('Failed to save data: $err');
    }
  }

  // ---- match-result mirroring -------------------------------------------
  // Propagates results from the upper triangle (i < j) to the lower

  void _reflectForward(List<Team> team) {
    for (int i = 0; i < team.length; i++) {
      for (int j = i + 1; j < team.length; j++) {
        final a = int.tryParse(team[i].matches[j]);
        if (a == 3) {
          team[j].matches[i] = '0';
        } else if (a == 0) {
          team[j].matches[i] = '3';
        }
        if (a == 2) {
          team[j].matches[i] = '1';
        } else if (a == 1) {
          team[j].matches[i] = '2';
        }
      }
    }
  }

  // Propagates results from the lower triangle to the upper triangle.
  void _reflectBackward(List<Team> team) {
    for (int i = 0; i < team.length; i++) {
      for (int j = i + 1; j < team.length; j++) {
        final b = int.tryParse(team[j].matches[i]);
        if (b == 3) {
          team[i].matches[j] = '0';
        } else if (b == 0) {
          team[i].matches[j] = '3';
        }
        if (b == 2) {
          team[i].matches[j] = '1';
        } else if (b == 1) {
          team[i].matches[j] = '2';
        }
      }
    }
  }

  void updateMatch(int grIndex, int gIndex, int matchIndex, String value) {
    setState(() {
      final team = groups[grIndex];
      team[gIndex].matches[matchIndex] = value;

      if (gIndex < matchIndex) {
        _reflectForward(team);
      } else {
        _reflectBackward(team);
      }

      for (int teamIndex = 0; teamIndex < team.length; teamIndex++) {
        final t = team[teamIndex];
        double points = 0;
        for (int i = 0; i < t.matches.length; i++) {
          if (i != teamIndex) {
            points += double.tryParse(t.matches[i]) ?? double.nan;
          }
        }
        t.points = points;
      }
    });
    _saveData();
  }

  void changeTeamName(int grIndex, int gIndex, String text) {
    setState(() {
      groups[grIndex][gIndex].name = text;
    });
    _saveData();
  }

  void calcPlaces(int e) {
    setState(() {
      final group = groups[e];
      final sorted = [...group]..sort((a, b) => b.points.compareTo(a.points));
      for (final team in group) {
        for (int sIndex = 0; sIndex < sorted.length; sIndex++) {
          if (sorted[sIndex].name == team.name) {
            team.place = sIndex + 1;
          }
        }
      }
    });
    _saveData();
  }

  List<Team> _makeTable() {
    final names = newTeamControllers.map((c) => c.text).toList();
    final teams = names
        .map(
          (name) => Team(
            name: name,
            matches: List.generate(names.length, (_) => '-'),
          ),
        )
        .toList();
    for (int i = 0; i < teams.length; i++) {
      teams[i].matches[i] = '#';
    }
    return teams;
  }

  void addGroup() {
    setState(() {
      groups.add(_makeTable());
      _resetNewTeamControllers();
    });
    _saveData();
    Navigator.of(context).pop();
  }

  void removeGroup(int index) {
    setState(() {
      groups.removeAt(index);
    });
    _saveData();
    Navigator.of(context).pop();
  }

  // ---- dialogs ------------------------------------------------------------

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF194955),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create New Group',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromRGBO(64, 176, 204, 1),
                      fontFamily: 'BrightAura',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(newTeamControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: newTeamControllers[index],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'BrightAura',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Team name',
                                hintStyle: const TextStyle(
                                  color: Colors.white30,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                newTeamControllers[index].dispose();
                                newTeamControllers.removeAt(index);
                              });
                              setDialogState(() {});
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFC00707),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'BrightAura',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          newTeamControllers.add(TextEditingController());
                        });
                        setDialogState(() {});
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Team',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'BrightAura',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: addGroup,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'BrightAura',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            64,
                            176,
                            204,
                            1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'BrightAura',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteGroupDialog(int grIndex) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF194955),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromRGBO(64, 176, 204, 1),
                  fontFamily: 'BrightAura',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => removeGroup(grIndex),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC00707),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'BrightAura',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(64, 176, 204, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'BrightAura',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(43, 108, 124, 1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      width: double.infinity,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (int grIndex = 0; grIndex < groups.length; grIndex++)
              _buildGroup(grIndex),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  onPressed: _showAddGroupDialog,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add group',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'BrightAura',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(int grIndex) {
    final gr = groups[grIndex];
    final label = grIndex < letters.length
        ? letters[grIndex]
        : '#${grIndex + 1}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '$label Group',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontFamily: 'BrightAura',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'Pts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'BrightAura',
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Plc',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'BrightAura',
                      ),
                    ),
                  ],
                ),
              ),
              for (int gIndex = 0; gIndex < gr.length; gIndex++)
                _TeamRow(
                  key: ValueKey('$grIndex-$gIndex'),
                  team: gr[gIndex],
                  grIndex: grIndex,
                  gIndex: gIndex,
                  onNameChanged: changeTeamName,
                  onMatchChanged: updateMatch,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => calcPlaces(grIndex),
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(64, 176, 204, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Calc',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'BrightAura',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => _showDeleteGroupDialog(grIndex),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFC00707),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'BrightAura',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamRow extends StatefulWidget {
  final Team team;
  final int grIndex;
  final int gIndex;
  final void Function(int grIndex, int gIndex, String text) onNameChanged;
  final void Function(int grIndex, int gIndex, int matchIndex, String text)
  onMatchChanged;

  const _TeamRow({
    super.key,
    required this.team,
    required this.grIndex,
    required this.gIndex,
    required this.onNameChanged,
    required this.onMatchChanged,
  });

  @override
  State<_TeamRow> createState() => _TeamRowState();
}

class _TeamRowState extends State<_TeamRow> {
  late TextEditingController nameController;
  late List<TextEditingController> matchControllers;
  final FocusNode nameFocus = FocusNode();
  late List<FocusNode> matchFocus;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.team.name);
    matchControllers = widget.team.matches
        .map((m) => TextEditingController(text: m))
        .toList();
    matchFocus = widget.team.matches.map((_) => FocusNode()).toList();
  }

  @override
  void didUpdateWidget(covariant _TeamRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!nameFocus.hasFocus && nameController.text != widget.team.name) {
      nameController.text = widget.team.name;
    }
    for (
      int i = 0;
      i < widget.team.matches.length && i < matchControllers.length;
      i++
    ) {
      if (!matchFocus[i].hasFocus &&
          matchControllers[i].text != widget.team.matches[i]) {
        matchControllers[i].text = widget.team.matches[i];
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    for (final c in matchControllers) {
      c.dispose();
    }
    for (final f in matchFocus) {
      f.dispose();
    }
    super.dispose();
  }

  String _pointsLabel(double points) =>
      points.isNaN ? '-' : points.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 110,
            child: TextField(
              controller: nameController,
              focusNode: nameFocus,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'BrightAura',
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: (text) =>
                  widget.onNameChanged(widget.grIndex, widget.gIndex, text),
            ),
          ),
          for (int i = 0; i < matchControllers.length; i++)
            SizedBox(
              width: 30,
              child: TextField(
                controller: matchControllers[i],
                focusNode: matchFocus[i],
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'BrightAura',
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (text) => widget.onMatchChanged(
                  widget.grIndex,
                  widget.gIndex,
                  i,
                  text.trim(),
                ),
              ),
            ),
          Text(
            _pointsLabel(widget.team.points),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontFamily: 'BrightAura',
            ),
          ),
          Text(
            '${widget.team.place}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontFamily: 'BrightAura',
            ),
          ),
        ],
      ),
    );
  }
}
