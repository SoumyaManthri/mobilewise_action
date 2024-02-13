class UserPermissionsModel {
  Meta meta;
  Map<String, ApplicationPermission> permissions;

  UserPermissionsModel({
    required this.meta,
    required this.permissions,
  });

  factory UserPermissionsModel.fromJson(Map<String, dynamic> json) {
    return UserPermissionsModel(
      meta: Meta.fromJson(json['meta']),
      permissions: Map.from(json['permissions'])
          .map((key, value) =>
          MapEntry(key, ApplicationPermission.fromJson(value))),
    );
  }
}

class Meta {
  String userId;
  String username;
  String firstName;
  String lastName;
  String email;
  String mobileNo;
  String userDetailsJson;
  String createdTs;
  String updatedTs;
  String lastLoginTs;
  bool status;
  String title;
  String customerId;
  String customerName;
  String customAttributes;

  Meta({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.userDetailsJson,
    required this.createdTs,
    required this.updatedTs,
    required this.lastLoginTs,
    required this.status,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.customAttributes,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      userId: json['userId'] ?? "",
      username: json['username'] ?? "",
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      email: json['email'] ?? "",
      mobileNo: json['mobileNo'] ?? "",
      userDetailsJson: json['userDetailsJson'] ?? "",
      createdTs: json['createdTs'] ?? "",
      updatedTs: json['updatedTs'] ?? "",
      lastLoginTs: json['lastLoginTs'] ?? "",
      status: json['status'] ?? false,
      title: json['title'] ?? "",
      customerId: json['customerId'] ?? "",
      customerName: json['customerName'] ?? "",
      customAttributes: json['customAttributes'] ?? "",
    );
  }
}

class ApplicationPermission {
  String applicationId;
  String applicationName;
  String roleId;
  String roleName;
  UserRoleScope userRoleScope;
  Map<String, ResourcePermission> resources;

  ApplicationPermission({
    required this.applicationId,
    required this.applicationName,
    required this.roleId,
    required this.roleName,
    required this.userRoleScope,
    required this.resources,
  });

  factory ApplicationPermission.fromJson(Map<String, dynamic> json) {
    return ApplicationPermission(
      applicationId: json['applicationId'] ?? "",
      applicationName: json['applicationName'] ?? "",
      roleId: json['roleId'] ?? "",
      roleName: json['roleName'] ?? "",
      userRoleScope: UserRoleScope.fromJson(json['userRoleScope']),
      resources: Map.from(json['resources'])
          .map((key, value) =>
          MapEntry(key, ResourcePermission.fromJson(value))),
    );
  }
}

class UserRoleScope {
  dynamic data;
  List<dynamic> scope;

  UserRoleScope({
    required this.data,
    required this.scope,
  });

  factory UserRoleScope.fromJson(Map<String, dynamic> json) {
    return UserRoleScope(
      data: json['data'],
      scope: List<dynamic>.from(json['scope']),
    );
  }
}

class ResourcePermission {
  String resourceId;
  String resourceName;
  List<String> actions;
  dynamic actionsInfo;
  String resourceTypeName;

  ResourcePermission({
    required this.resourceId,
    required this.resourceName,
    required this.actions,
    required this.actionsInfo,
    required this.resourceTypeName,
  });

  factory ResourcePermission.fromJson(Map<String, dynamic> json) {
    return ResourcePermission(
      resourceId: json['resourceId'] ?? "",
      resourceName: json['resourceName'] ?? "",
      actions: List<String>.from(json['actions']),
      actionsInfo: json['actionsInfo'] ?? "",
      resourceTypeName: json['resourceTypeName'] ?? "",
    );
  }
}