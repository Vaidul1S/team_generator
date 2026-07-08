import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class Player {
  String name;
  Player(this.name);

  Map<String, dynamic> toJson() => {'name': name};
  factory Player.fromJson(Map<String, dynamic> json) =>
      Player(json['name'] as String);
}

class Generator extends StatefulWidget {
  const Generator({super.key});

  @override
  State<Generator> createState() => _GeneratorState();
}

class _GeneratorState extends State<Generator> {
  static const _storageKey = 'generator';

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Player> pool = [];
  bool gt = false; 
  bool mix = false; 
  List<Player> teams = [];
  int size = 2;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _inputFocusNode.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final decoded = jsonDecode(data) as List<dynamic>;
        setState(() {
          pool = decoded
              .map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (err) {
      debugPrint('Failed to load data: $err');
    }
  }

  Future<void> _storeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final encoded = jsonEncode(pool.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (err) {
      debugPrint('Failed to save data: $err');
    }
  }

  Future<void> _playClick() async {
    try {      
      await _audioPlayer.play(AssetSource('sounds/click2.mp3'));
    } catch (err) {
      debugPrint('Failed to play click sound: $err');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submitName(String value) {
    _playClick();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _showAlert('Please enter a name!');
    } else if (pool.any((p) => p.name.toLowerCase() == trimmed.toLowerCase())) {
      _showAlert('Name already exists!');
      _nameController.clear();
    } else {
      setState(() {
        pool = [...pool, Player(trimmed)];
      });
      _nameController.clear();
      _storeData();
    }
    _inputFocusNode.unfocus();
  }

  void _deleteName(String nameToDelete) {
    setState(() {
      pool = pool.where((p) => p.name != nameToDelete).toList();
    });
    _storeData();
  }

  void _generateTeams() {
    _playClick();
    final shuffled = [...pool];
    shuffled.shuffle(Random());
    setState(() {
      teams = shuffled;
      gt = true;
    });
  }

  void _generateMixes() {
    size = 2;
    _playClick();
    final players = [...pool];
    final first = players.length > 4 ? players.sublist(0, 4) : players;
    final second = players.length > 4 ? players.sublist(4) : <Player>[];
    second.shuffle(Random());

    final result = <Player>[];
    for (var i = 0; i < first.length; i++) {
      result.add(first[i]);
      if (i < second.length) {
        result.add(second[i]);
      }
    }

    setState(() {
      teams = result;
      mix = true;
    });
  }

  void _goBack() {
    _playClick();
    setState(() {
      gt = false;
      mix = false;
    });
  }

  void _setTeamSize(int value) {
    _playClick();
    setState(() {
      size = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !(gt || mix),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && (gt || mix)) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(43, 108, 124, 1),
        body: Stack(
          children: [
            SafeArea(child: _buildMainScreen()),
            if (gt)
              _buildResultsOverlay(
                useSize: true,
                onGenerateAgain: _generateTeams,
              ),
            if (mix)
              _buildResultsOverlay(
                useSize: false,
                onGenerateAgain: _generateMixes,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      color: const Color(0x80000000),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontFamily: 'BrightAura',
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(64, 176, 204, 1),
          padding: const EdgeInsets.all(10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontFamily: 'BrightAura',
          ),
        ),
      ),
    );
  }

  Widget _sizeButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(64, 176, 204, 1),
          padding: const EdgeInsets.all(6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontFamily: 'BrightAura',
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(6),
          color: const Color(0x80000000),
          child: const Text(
            'Team Generator',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontFamily: 'BrightAura',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(            
            controller: _nameController,            
            focusNode: _inputFocusNode,
            onSubmitted: _submitName,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'BrightAura',
              fontSize: 20,
            ),
            decoration: InputDecoration(
              hintText: 'Enter a name',
              hintStyle: const TextStyle(color: Colors.white70),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: _primaryButton(
            'Add name',
            () => _submitName(_nameController.text),
          ),
        ),
        _sectionHeader('Name Pool'),
        SizedBox(
          height: 270,
          child: Wrap(
            alignment: WrapAlignment.start,
            direction: Axis.vertical,
            children: [
              for (var i = 0; i < pool.length; i++)
                GestureDetector(
                  onLongPress: () => _deleteName(pool[i].name),
                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '${i + 1}. ${pool[i].name}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'BrightAura',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _sectionHeader('Team Size: $size'),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final n in [2, 3, 4, 5, 6])
                _sizeButton(n.toString(), () => _setTeamSize(n)),
              _sizeButton('M', _generateMixes),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: _primaryButton('Generate Teams', _generateTeams),
        ),
      ],
    );
  }

  /// Full-screen overlay used for both the "generate teams" and
  /// "generate mixes" result views (equivalent to the two RN Modal's).
  Widget _buildResultsOverlay({
    required bool useSize,
    required VoidCallback onGenerateAgain,
  }) {
    return Positioned.fill(
      child: Material(
        color: const Color.fromRGBO(43, 108, 124, 1),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.all(6),
                color: const Color(0x80000000),
                child: const Text(
                  'Teams',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontFamily: 'BrightAura',
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < teams.length; i++)
                      Padding(
                        padding: EdgeInsets.only(top: i % size == 0 ? 30 : 0),
                        child: Text(
                          '${i % size + 1}. ${teams[i].name}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'BrightAura',
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: _primaryButton('Generate Again', onGenerateAgain),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: _primaryButton('Go Back', _goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
