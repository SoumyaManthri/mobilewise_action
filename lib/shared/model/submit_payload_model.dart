
class Datachild {
  String? widgetid;
  String? widgetlabel;
  String? value;

  Datachild({this.widgetid, this.widgetlabel, this.value});

  Datachild.fromJson(Map<String, dynamic> json) {
    widgetid = json['widget_id'];
    widgetlabel = json['widget_label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['widget_id'] = widgetid;
    data['widget_label'] = widgetlabel;
    data['value'] = value;
    return data;
  }
}

class Dataroot {
  String? entityid;
  List<Datachild?>? datachild;

  Dataroot({this.entityid, this.datachild});

  Dataroot.fromJson(Map<String, dynamic> json) {
    entityid = json['entity_id'];
    if (json['data'] != null) {
      datachild = <Datachild>[];
      json['data'].forEach((v) {
        datachild!.add(Datachild.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['entity_id'] = entityid;
    if (datachild != null) {
      data['data'] = datachild!.map((v) => v?.toJson()).toList();
    } else {
      data['data'] = null;
    }
    return data;
  }
}

class SubmitApiModel {
  String? appuuid;
  List<Dataroot?>? dataroot;

  SubmitApiModel({this.appuuid, this.dataroot});

  SubmitApiModel.fromJson(Map<String, dynamic> json) {
    appuuid = json['app_uuid'];
    if (json['data'] != null) {
      dataroot = <Dataroot>[];
      json['data'].forEach((v) {
        dataroot!.add(Dataroot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['app_uuid'] = appuuid;
    data['data'] =dataroot != null ? dataroot!.map((v) => v?.toJson()).toList() : null;
    return data;
  }
}

