import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dht.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:async';
import 'package:marquee/marquee.dart';

class SinglePageApp extends StatefulWidget {
  @override
  _SinglePageAppState createState() => _SinglePageAppState();
}

class _SinglePageAppState extends State<SinglePageApp> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int tabIndex = 0;

  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _dhtRef = FirebaseDatabase.instance.reference().child('DHT');

  bool _signIn;
  String heatIndexText;
  Timer _timer;

  // double waterHeight=0.2;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _signIn = false;
    heatIndexText = "Please wait ...";
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if(_signIn){
        setState((){});
      }
      
     });
     _signInAnonymously();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _signIn ? mainScaffold() : signInScaffold();

  }


  Widget mainScaffold(){
    return Scaffold(
      appBar: AppBar(
        title: Text("SYAM APP TEMP & HUMIDITY"),
        bottom: TabBar(
          controller: _tabController,
          onTap: (int index){
            setState(() {
              tabIndex = index;
            });
          },
          tabs: [
            Tab(icon: Icon(MaterialCommunityIcons.temperature_celsius)),
            Tab(icon: Icon(MaterialCommunityIcons.water_percent)),
          ],
        ),),
      body: Column(
        children: [
          Container(height: 30, child: _buildMarquee(),),
          Expanded(
            child: StreamBuilder(
            stream: _dhtRef.onValue,
            builder: (context, snapshot){

              if(snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null){

              var _dht = DHT.fromJson(snapshot.data.snapshot.value['Json']);
              print("DHT: ${_dht.temp} / ${_dht.humidity} / ${_dht.heatindex}");
              _setMarqueeText(_dht);
                    return IndexedStack(
                        index: tabIndex,
                        children: [_temperatureLayout(_dht), _humidityLayout(_dht)],
                    );
              }else{
                   return Center(child: Text("NO DATA YET"));
              }
             
            }),
          ),
        ],
      ),
    );
  }

  Widget _humidityLayout(DHT _dht){
    return Center(
      child: Column(
        children: [
          Container(padding: const EdgeInsets.only(top: 40),
          child: Text("HUMIDITY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: 
              WaveProgress(300.0, Colors.blue, Colors.blueAccent, _dht.humidity),
                
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            "${_dht.humidity.toStringAsFixed(2)} %", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 28),),
        ),
      ],
      )
    );
  }

  Widget _temperatureLayout(DHT _dht){
    return Center(
      child: Column(
        children: [
          Container(padding: const EdgeInsets.only(top: 40),
          child: Text("TEMPERATURE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: FAProgressBar(
                progressColor: Colors.green, 
                direction: Axis.vertical, 
                verticalDirection: VerticalDirection.up,
                size: 100,
                currentValue: _dht.temp.round(),
                changeColorValue: 100,
                changeProgressColor: Colors.red,
                maxValue: 100,
                displayText: "°C",
                borderRadius: 16,
                animatedDuration: Duration(milliseconds: 500),
                )
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 40),
          child: Text(
            "${_dht.temp.toStringAsFixed(2)}°C", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 28),),
        ),
      ],
      )
    );
  }

  _setMarqueeText(DHT _dht){
    heatIndexText = "Heat Index: ${_dht.heatindex.toStringAsFixed(2)}°C.";
    if(_dht.heatindex > 26 && _dht.heatindex <= 32){
      heatIndexText += 
      "Perhatian: kelelahan bisa terjadi dengan eksposur dan aktivitas yang lama. Melanjutkan aktivitas dapat menyebabkan kram panas.";
    }else if(_dht.heatindex > 32 && _dht.heatindex <= 41){
       heatIndexText +=
       "Perhatian ekstrim: kram panas dan kelelahan panas mungkin terjadi. Melanjutkan aktivitas dapat menyebabkan sengatan panas.";
    }else if(_dht.heatindex > 41 && _dht.heatindex <= 54){
      heatIndexText +=
      "Bahaya: kram panas dan kelelahan panas mungkin terjadi; serangan panas mungkin terjadi dengan aktivitas yang berkelanjutan.";
    }else if(_dht.heatindex > 54){
      heatIndexText +=
      "Bahaya ekstrim: serangan panas sudah dekat.";
    }else {
      heatIndexText +=
      "Normal";
    }
  }

  Widget _buildMarquee(){
    return Marquee(
      text: heatIndexText,
      style : TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
    );
  }

  Widget signInScaffold(){
    return Scaffold(
      
      body: Center(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Text("FLUTTER DHT21 SYAM APP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ), 
          SizedBox(
            height: 50,
          ),
          RaisedButton(
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), 
              side: BorderSide(
                color: Colors.red
              )),
            onPressed: () async{
              _signInAnonymously();
            },
            child: Text("ANONYMOUS SIGN-IN", style: TextStyle(fontSize: 14)),textColor: Colors.white,)
        ],)  
      ,),
    );
  }

  void _signInAnonymously() async{
    final User user = (await _auth.signInAnonymously()).user;
    print("*** user : ${user.isAnonymous}");
    print("user uid : ${user.uid}");
    setState(() {
      if (user != null){
      _signIn = true;
      }else{
      _signIn = false;
      }
    });
    
  }
}