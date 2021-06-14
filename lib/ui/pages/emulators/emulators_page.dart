import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:neonrom3r/repository/emulators_repository.dart';
import 'package:neonrom3r/ui/pages/emulators/console_emulators_page.dart';
import 'package:neonrom3r/ui/widgets/console_tile.dart';

class EmulatorsPage extends StatefulWidget {
  @override
  _EmulatorsPageState createState() => _EmulatorsPageState();
}

class _EmulatorsPageState extends State<EmulatorsPage> {
  Map<Console, List<Emulator>> _emulators = {};
  bool _isLoading = false;
  @override
  void initState() {
    fetchEmulators();
    super.initState();
  }

  setLoading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  fetchEmulators() async {
    setLoading(true);
    try {
      var _res = await EmulatorsRepository().fetchEmulators();
      setState(() {
        _emulators = _res;
      });
    } catch (err) {}
    setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emulators"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(_emulators.length, (index) {
                var _emus = _emulators.values.toList()[index];
                var _console = _emulators.keys.toList()[index];
                return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ConsoleEmulatorsPage(_console, _emus)));
                    },
                    child: FadeInUp(
                        delay: Duration(milliseconds: 50 * index),
                        child: ConsoleTile(_emulators.keys.toList()[index])));
              }),
            ),
    );
  }
}
