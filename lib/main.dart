import 'package:flutter/material.dart';
import 'controlPage.dart';
import 'hostBindPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alertDialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart appliances',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(color: Colors.blueGrey),
      ),
      home: SmartAppliancesHomePage(title: 'Smart appliances'),
    );
  }
}

class SmartAppliancesHomePage extends StatefulWidget {
  SmartAppliancesHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SmartAppliancesState createState() => _SmartAppliancesState();
}

class _SmartAppliancesState extends State<SmartAppliancesHomePage> {
  bool _isBindHost = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sps) {
      String host = sps.getString('host');
      int port = sps.getInt('port');
      showDialogSelf('host:$host -- port:$port', context);
      if (host != null && port != null) {
        setState(() {
          _isBindHost = true;
        });
      }
    });
  }

  void _handleHostChanged(bool newValue) {
    setState(() {
      _isBindHost = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isBindHost
          ? ControlPage(
              isBindHost: _isBindHost,
              onChanged: _handleHostChanged,
            )
          : HostBindPage(
              isBindHost: _isBindHost,
              onChanged: _handleHostChanged,
            ),
    );
  }
}
