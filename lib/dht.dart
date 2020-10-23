class DHT{
  final double temp;
  final double humidity;
  final double heatindex;
  DHT({this.temp, this.humidity, this.heatindex});
  factory DHT.fromJson(Map<dynamic, dynamic> json){
    double parser(dynamic source){
      try{
        return double.parse(source.toString());
      } on FormatException{
        return -1;
      }
    }

    return DHT(
      temp: parser(json['temp']), 
      humidity: parser(json['hum']), 
      heatindex: parser(json['ht']),);
  }
}