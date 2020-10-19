class User {
  String _name, _userName, _token;
  int _id, _instituteId;

  User(this._id, this._instituteId, this._userName, this._name, this._token);

  int get id => _id;

  int get instituteId => _instituteId;

  String get name => _name;

  String get userName => _userName;

  String get token => _token;
}
