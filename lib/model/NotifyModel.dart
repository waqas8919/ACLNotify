class ModelNotification {
  int _notifyid;
  String _message;

  ModelNotification(this._message);
  ModelNotification.withId(this._notifyid, this._message);

  int get notifyid => _notifyid;
  String get message => _message;

  set message(String newmessage) {
    if (newmessage.length <= 255) {
      this._message = newmessage;
    }
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (notifyid != null) {
      map['notifyid'] = _notifyid;
    }
    map['message'] = _message;

    return map;
  }

  // Extract a Note object from a Map object
  ModelNotification.fromMapObject(Map<String, dynamic> map) {
    this._notifyid = map['notifyid'];
    this._message = map['message'];
  }
}
