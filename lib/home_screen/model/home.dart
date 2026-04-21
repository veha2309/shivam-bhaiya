final class HomeModel {
  final String? affiliationCode;
  final String? latitude;
  final String? photo;
  final String? language;
  final String? sessionCode;
  final String? groupCode;
  final String? token;
  final String? className;
  final String? profilePhoto;
  final String? schoolId;
  final String? studentName;
  final String? classCode;
  final String? name;
  final String? sectionCode;
  final String? id;
  final String? isDefault;
  final String? userType;
  final String? longitude;
  final List<Category>? categories;
  final List<MenuDetail>? menuDetails;

  HomeModel({
    this.affiliationCode,
    this.latitude,
    this.photo,
    this.language,
    this.sessionCode,
    this.groupCode,
    this.token,
    this.className,
    this.profilePhoto,
    this.schoolId,
    this.studentName,
    this.classCode,
    this.name,
    this.sectionCode,
    this.id,
    this.isDefault,
    this.userType,
    this.longitude,
    this.categories,
    this.menuDetails,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      affiliationCode: json['affiliationcode'],
      latitude: json['latitude'],
      photo: json['photo'],
      language: json['language'],
      sessionCode: json['sessioncode'],
      groupCode: json['groupcode'],
      token: json['token'],
      className: json['classname'],
      profilePhoto: json['profilephoto'],
      schoolId: json['schoolid'],
      studentName: json['studentName'],
      classCode: json['classcode'],
      name: json['name'],
      sectionCode: json['sectioncode'],
      id: json['id'],
      isDefault: json['isdefault'],
      userType: json['userType'],
      longitude: json['longitude'],
      categories: (json['categories'] as List?)
          ?.map((e) => Category.fromJson(e))
          .toList(),
      menuDetails: (json['menuDetails'] as List?)
          ?.map((e) => MenuDetail.fromJson(e))
          .toList(),
    );
  }
}

class Category {
  final String? name;
  final String? id;

  Category({this.name, this.id});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      id: json['id'],
    );
  }
}

class MenuDetail {
  final String? mobileMenuId;
  final String? categoryId;
  final String? menuName;
  final String? menuId;
  final String? moduleIcon;
  final String? url;

  MenuDetail({
    this.mobileMenuId,
    this.categoryId,
    this.menuName,
    this.menuId,
    this.moduleIcon,
    this.url,
  });

  factory MenuDetail.fromJson(Map<String, dynamic> json) {
    return MenuDetail(
      mobileMenuId: json['mobile_menu_id'],
      categoryId: json['category_id'],
      menuName: json['menu_name'],
      menuId: json['menu_id'],
      moduleIcon: json['moduleicon'],
      url: json['url'],
    );
  }
}
