class CSRFModel {
  Tokens? tokens;
  String? token;
  String? expirationTime;
  UserDetails? userDetails;
  bool? promptForChangePassword;
  bool? promptForVerificationCode;

  CSRFModel(
      {this.tokens,
      this.token,
      this.expirationTime,
      this.userDetails,
      this.promptForChangePassword,
      this.promptForVerificationCode});

CSRFModel.fromJson(Map<String, dynamic> json) {
    tokens =
        json['tokens'] != null ? new Tokens.fromJson(json['tokens']) : null;
    token = json['token'];
    expirationTime = json['expirationTime'];
    userDetails = json['userDetails'] != null
        ? new UserDetails.fromJson(json['userDetails'])
        : null;
    promptForChangePassword = json['promptForChangePassword'];
    promptForVerificationCode = json['promptForVerificationCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tokens != null) {
      data['tokens'] = this.tokens!.toJson();
    }
    data['token'] = this.token;
    data['expirationTime'] = this.expirationTime;
    if (this.userDetails != null) {
      data['userDetails'] = this.userDetails!.toJson();
    }
    data['promptForChangePassword'] = this.promptForChangePassword;
    data['promptForVerificationCode'] = this.promptForVerificationCode;
    return data;
  }
}

class Tokens {
  String? jit;
  String? csrf;

  Tokens({this.jit, this.csrf});

  Tokens.fromJson(Map<String, dynamic> json) {
    jit = json['jit'];
    csrf = json['csrf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jit'] = this.jit;
    data['csrf'] = this.csrf;
    return data;
  }
}

class UserDetails {
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  // Null? roles;
  // Null? permissions;
  // Null? applications;
  // Null? userDetailsJson;
  // Null? approver;
  // Null? passwordHash;
  // String? lastLoginTs;
  // Null? createdTs;
  // Null? updatedTs;
  // Null? deleted;
  // Null? token;
  // bool? status;
  // Null? title;
  // bool? userInfoEncrypted;
  // Null? customerName;
  // Null? customerId;
  // bool? enabled;
  // String? userId;

  UserDetails(
      {this.username,
      this.firstName,
      this.lastName,
      this.email,
      this.mobileNo,
      // this.roles,
      // this.permissions,
      // this.applications,
      // this.userDetailsJson,
      // this.approver,
      // this.passwordHash,
      // this.lastLoginTs,
      // this.createdTs,
      // this.updatedTs,
      // this.deleted,
      // this.token,
      // this.status,
      // this.title,
      // this.userInfoEncrypted,
      // this.customerName,
      // this.customerId,
      // this.enabled,
      // this.userId
      });

  UserDetails.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    mobileNo = json['mobileNo'];
    // roles = json['roles'];
    // permissions = json['permissions'];
    // applications = json['applications'];
    // userDetailsJson = json['userDetailsJson'];
    // approver = json['approver'];
    // passwordHash = json['passwordHash'];
    // lastLoginTs = json['lastLoginTs'];
    // createdTs = json['createdTs'];
    // updatedTs = json['updatedTs'];
    // deleted = json['deleted'];
    // token = json['token'];
    // status = json['status'];
    // title = json['title'];
    // userInfoEncrypted = json['userInfoEncrypted'];
    // customerName = json['customerName'];
    // customerId = json['customerId'];
    // enabled = json['enabled'];
    // userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['mobileNo'] = this.mobileNo;
    // data['roles'] = this.roles;
    // data['permissions'] = this.permissions;
    // data['applications'] = this.applications;
    // data['userDetailsJson'] = this.userDetailsJson;
    // data['approver'] = this.approver;
    // data['passwordHash'] = this.passwordHash;
    // data['lastLoginTs'] = this.lastLoginTs;
    // data['createdTs'] = this.createdTs;
    // data['updatedTs'] = this.updatedTs;
    // data['deleted'] = this.deleted;
    // data['token'] = this.token;
    // data['status'] = this.status;
    // data['title'] = this.title;
    // data['userInfoEncrypted'] = this.userInfoEncrypted;
    // data['customerName'] = this.customerName;
    // data['customerId'] = this.customerId;
    // data['enabled'] = this.enabled;
    // data['userId'] = this.userId;
    return data;
  }
}