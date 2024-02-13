class JWTModel {
  int? _exp;
  int? _iat;
  String? _jti;
  String? _iss;
  String? _aud;
  String? _sub;
  String? _typ;
  String? _azp;
  String? _sessionState;
  String? _acr;
  List<String>? _allowedOrigins;
  RealmAccess? _realmAccess;
  ResourceAccess? _resourceAccess;
  String? _scope;
  String? _sid;
  bool? _emailVerified;
  String? _name;
  String? _preferredUsername;
  String? _givenName;
  String? _familyName;
  String? _email;

  JWTModel(
      {int? exp,
        int? iat,
        String? jti,
        String? iss,
        String? aud,
        String? sub,
        String? typ,
        String? azp,
        String? sessionState,
        String? acr,
        List<String>? allowedOrigins,
        RealmAccess? realmAccess,
        ResourceAccess? resourceAccess,
        String? scope,
        String? sid,
        bool? emailVerified,
        String? name,
        String? preferredUsername,
        String? givenName,
        String? familyName,
        String? email}) {
    if (exp != null) {
      this._exp = exp;
    }
    if (iat != null) {
      this._iat = iat;
    }
    if (jti != null) {
      this._jti = jti;
    }
    if (iss != null) {
      this._iss = iss;
    }
    if (aud != null) {
      this._aud = aud;
    }
    if (sub != null) {
      this._sub = sub;
    }
    if (typ != null) {
      this._typ = typ;
    }
    if (azp != null) {
      this._azp = azp;
    }
    if (sessionState != null) {
      this._sessionState = sessionState;
    }
    if (acr != null) {
      this._acr = acr;
    }
    if (allowedOrigins != null) {
      this._allowedOrigins = allowedOrigins;
    }
    if (realmAccess != null) {
      this._realmAccess = realmAccess;
    }
    if (resourceAccess != null) {
      this._resourceAccess = resourceAccess;
    }
    if (scope != null) {
      this._scope = scope;
    }
    if (sid != null) {
      this._sid = sid;
    }
    if (emailVerified != null) {
      this._emailVerified = emailVerified;
    }
    if (name != null) {
      this._name = name;
    }
    if (preferredUsername != null) {
      this._preferredUsername = preferredUsername;
    }
    if (givenName != null) {
      this._givenName = givenName;
    }
    if (familyName != null) {
      this._familyName = familyName;
    }
    if (email != null) {
      this._email = email;
    }
  }

  int? get exp => _exp;
  set exp(int? exp) => _exp = exp;
  int? get iat => _iat;
  set iat(int? iat) => _iat = iat;
  String? get jti => _jti;
  set jti(String? jti) => _jti = jti;
  String? get iss => _iss;
  set iss(String? iss) => _iss = iss;
  String? get aud => _aud;
  set aud(String? aud) => _aud = aud;
  String? get sub => _sub;
  set sub(String? sub) => _sub = sub;
  String? get typ => _typ;
  set typ(String? typ) => _typ = typ;
  String? get azp => _azp;
  set azp(String? azp) => _azp = azp;
  String? get sessionState => _sessionState;
  set sessionState(String? sessionState) => _sessionState = sessionState;
  String? get acr => _acr;
  set acr(String? acr) => _acr = acr;
  List<String>? get allowedOrigins => _allowedOrigins;
  set allowedOrigins(List<String>? allowedOrigins) =>
      _allowedOrigins = allowedOrigins;
  RealmAccess? get realmAccess => _realmAccess;
  set realmAccess(RealmAccess? realmAccess) => _realmAccess = realmAccess;
  ResourceAccess? get resourceAccess => _resourceAccess;
  set resourceAccess(ResourceAccess? resourceAccess) =>
      _resourceAccess = resourceAccess;
  String? get scope => _scope;
  set scope(String? scope) => _scope = scope;
  String? get sid => _sid;
  set sid(String? sid) => _sid = sid;
  bool? get emailVerified => _emailVerified;
  set emailVerified(bool? emailVerified) => _emailVerified = emailVerified;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get preferredUsername => _preferredUsername;
  set preferredUsername(String? preferredUsername) =>
      _preferredUsername = preferredUsername;
  String? get givenName => _givenName;
  set givenName(String? givenName) => _givenName = givenName;
  String? get familyName => _familyName;
  set familyName(String? familyName) => _familyName = familyName;
  String? get email => _email;
  set email(String? email) => _email = email;

  JWTModel.fromJson(Map<String, dynamic> json) {
    _exp = json['exp'];
    _iat = json['iat'];
    _jti = json['jti'];
    _iss = json['iss'];
    _aud = json['aud'];
    _sub = json['sub'];
    _typ = json['typ'];
    _azp = json['azp'];
    _sessionState = json['session_state'];
    _acr = json['acr'];
    _allowedOrigins = json['allowed-origins'].cast<String>();
    _realmAccess = json['realm_access'] != null
        ? new RealmAccess.fromJson(json['realm_access'])
        : null;
    _resourceAccess = json['resource_access'] != null
        ? new ResourceAccess.fromJson(json['resource_access'])
        : null;
    _scope = json['scope'];
    _sid = json['sid'];
    _emailVerified = json['email_verified'];
    _name = json['name'];
    _preferredUsername = json['preferred_username'];
    _givenName = json['given_name'];
    _familyName = json['family_name'];
    _email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['exp'] = this._exp;
    data['iat'] = this._iat;
    data['jti'] = this._jti;
    data['iss'] = this._iss;
    data['aud'] = this._aud;
    data['sub'] = this._sub;
    data['typ'] = this._typ;
    data['azp'] = this._azp;
    data['session_state'] = this._sessionState;
    data['acr'] = this._acr;
    data['allowed-origins'] = this._allowedOrigins;
    if (this._realmAccess != null) {
      data['realm_access'] = this._realmAccess!.toJson();
    }
    if (this._resourceAccess != null) {
      data['resource_access'] = this._resourceAccess!.toJson();
    }
    data['scope'] = this._scope;
    data['sid'] = this._sid;
    data['email_verified'] = this._emailVerified;
    data['name'] = this._name;
    data['preferred_username'] = this._preferredUsername;
    data['given_name'] = this._givenName;
    data['family_name'] = this._familyName;
    data['email'] = this._email;
    return data;
  }
}

class RealmAccess {
  List<String>? _roles;

  RealmAccess({List<String>? roles}) {
    if (roles != null) {
      this._roles = roles;
    }
  }

  List<String>? get roles => _roles;
  set roles(List<String>? roles) => _roles = roles;

  RealmAccess.fromJson(Map<String, dynamic> json) {
    _roles = json['roles'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roles'] = this._roles;
    return data;
  }
}

class ResourceAccess {
  RealmAccess? _account;

  ResourceAccess({RealmAccess? account}) {
    if (account != null) {
      this._account = account;
    }
  }

  RealmAccess? get account => _account;
  set account(RealmAccess? account) => _account = account;

  ResourceAccess.fromJson(Map<String, dynamic> json) {
    _account = json['account'] != null
        ? new RealmAccess.fromJson(json['account'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._account != null) {
      data['account'] = this._account!.toJson();
    }
    return data;
  }
}