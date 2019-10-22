import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

// 마커 추가하기 => https://medium.com/flutter/google-maps-and-flutter-cfb330f9a245
// 내 위치 찾아가ㅣ => https://medium.com/flutter-community/get-a-users-location-in-flutter-20f488ac8043
// 위치에 따른 카메라 이동(예제 사용) => https://pub.dev/packages/google_maps_flutter#-readme-tab-

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();


  void setPermission() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
  }
  //서울시립대 위치
  CameraPosition univ = CameraPosition(target: LatLng(37.5838657,127.0565884),  zoom: 16.4746,);

  //내 현재 위치 가져오기
  Future<void> toMyLocation() async{
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var myLocation = CameraPosition( zoom: 16.4746, target: LatLng(position.latitude, position.longitude));

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(myLocation));
  }

  //마커 집합
  final Set<Marker> _markers = {};

  //ch
  LatLng _lastMapPosition = LatLng(37.5838657,127.0565884);

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }


  @override
  void initState() {
    setPermission();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        label: Text("내 위치로~"),
        backgroundColor: Colors.green,
        onPressed: (){
          toMyLocation();
        },
        icon: Icon(Icons.my_location, color: Colors.white,),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    return Stack(
      children: <Widget>[
        GoogleMap(
          onCameraMove: _onCameraMove,
          markers: _markers,
          mapType: MapType.normal,
          initialCameraPosition: univ,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
          },
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.textsms),
                  onPressed: (){
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 1000),
                      content: Text("총 마커의 개수는 ${_markers.toSet().length}개입니다."),
                    ));
                  },
                ),
                SizedBox(height: 16.0),
                FloatingActionButton(
                  onPressed: _onAddMarkerButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add_location, size: 36.0),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Icon(Icons.add_location, color: Colors.red.withOpacity(0.5), size: 33,),
        ),
      ],
    );
  }
}
