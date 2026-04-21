class VehicleInfo {
  String? mobileNo;
  String? account;
  String? accountDesc;
  String? timeZone;
  String? vehicleType;
  String? driverName;
  List<DeviceInfo>? deviceList;
  String? vehicleNumber;

  VehicleInfo({
    this.mobileNo,
    this.account,
    this.accountDesc,
    this.timeZone,
    this.vehicleType,
    this.driverName,
    this.deviceList,
    this.vehicleNumber,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => VehicleInfo(
        mobileNo: json["MobileNo"],
        account: json["Account"],
        accountDesc: json["Account_desc"],
        timeZone: json["TimeZone"],
        vehicleType: json["VehicleType"],
        driverName: json["DriverName"],
        deviceList: json["DeviceList"] != null
            ? List<DeviceInfo>.from(
                json["DeviceList"].map((x) => DeviceInfo.fromMap(x)))
            : null,
        vehicleNumber: json["VehicleNumber"],
      );

  Map<String, dynamic> toJson() => {
        "MobileNo": mobileNo,
        "Account": account,
        "Account_desc": accountDesc,
        "TimeZone": timeZone,
        "VehicleType": vehicleType,
        "DriverName": driverName,
        "DeviceList": deviceList != null
            ? List<dynamic>.from(deviceList!.map((x) => x.toMap()))
            : null,
        "VehicleNumber": vehicleNumber,
      };
}

class DeviceInfo {
  String? deviceDesc;
  String? device;
  List<EventData>? eventData;

  DeviceInfo({
    this.deviceDesc,
    this.device,
    this.eventData,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> json) => DeviceInfo(
        deviceDesc: json["Device_desc"],
        device: json["Device"],
        eventData: json["EventData"] != null
            ? List<EventData>.from(
                json["EventData"].map((x) => EventData.fromMap(x)))
            : null,
      );

  Map<String, dynamic> toMap() => {
        "Device_desc": deviceDesc,
        "Device": device,
        "EventData": eventData != null
            ? List<dynamic>.from(eventData!.map((x) => x.toMap()))
            : null,
      };
}

class EventData {
  int? speed;
  double? gpsPointLat;
  double? gpsPointLon;
  String? address;
  String? gpsPoint;
  String? device;
  double? odometer;
  int? index;
  int? timestamp;
  int? statusCode;
  String? statusCodeHex;
  String? timestampDate;
  String? timestampTime;
  String? statusCodeDesc;
  String? speedUnits;
  String? odometerUnits;

  EventData({
    this.speed,
    this.gpsPointLat,
    this.gpsPointLon,
    this.address,
    this.gpsPoint,
    this.device,
    this.odometer,
    this.index,
    this.timestamp,
    this.statusCode,
    this.statusCodeHex,
    this.timestampDate,
    this.timestampTime,
    this.statusCodeDesc,
    this.speedUnits,
    this.odometerUnits,
  });

  factory EventData.fromMap(Map<String, dynamic> json) => EventData(
        speed: json["Speed"],
        gpsPointLat: json["GPSPoint_lat"]?.toDouble(),
        gpsPointLon: json["GPSPoint_lon"]?.toDouble(),
        address: json["Address"],
        gpsPoint: json["GPSPoint"],
        device: json["Device"],
        odometer: json["Odometer"]?.toDouble(),
        index: json["Index"],
        timestamp: json["Timestamp"],
        statusCode: json["StatusCode"],
        statusCodeHex: json["StatusCode_hex"],
        timestampDate: json["Timestamp_date"],
        timestampTime: json["Timestamp_time"],
        statusCodeDesc: json["StatusCode_desc"],
        speedUnits: json["Speed_units"],
        odometerUnits: json["Odometer_units"],
      );

  Map<String, dynamic> toMap() => {
        "Speed": speed,
        "GPSPoint_lat": gpsPointLat,
        "GPSPoint_lon": gpsPointLon,
        "Address": address,
        "GPSPoint": gpsPoint,
        "Device": device,
        "Odometer": odometer,
        "Index": index,
        "Timestamp": timestamp,
        "StatusCode": statusCode,
        "StatusCode_hex": statusCodeHex,
        "Timestamp_date": timestampDate,
        "Timestamp_time": timestampTime,
        "StatusCode_desc": statusCodeDesc,
        "Speed_units": speedUnits,
        "Odometer_units": odometerUnits,
      };
}
