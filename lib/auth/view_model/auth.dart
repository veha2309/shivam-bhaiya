import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/model/user_profile.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/utils/device_utils.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';

class AuthViewModel extends ChangeNotifier {
  static final AuthViewModel _instance = AuthViewModel._internal();

  static AuthViewModel get instance => _instance;

  AuthViewModel._internal();
  HomeModel? homeModel;

  void setHomeModel(HomeModel homeModel) {
    this.homeModel = homeModel;
  }

  User? getLoggedInUser() {
    return LocalStorage.getLoggedInUser();
  }

  User? userGettingLoggedIn;

  Future<ApiResponse<String>> authenticateWithEmailAndPassword(String username,
      String password, String userType, String affiliationCode) async {
    return NetworkManager.instance.makeRequest(Endpoints.otpLogin,
        (dynamic json) async {
      String accessToken = json as String;

      userGettingLoggedIn?.accessToken = accessToken;
      userGettingLoggedIn?.isLogged = true;
      if (userGettingLoggedIn != null) {
        await LocalStorage.updateUserStatus(userGettingLoggedIn!);
      }
      userGettingLoggedIn = null;
      return accessToken;
    }, method: HttpMethod.post, body: {
      'username': "$affiliationCode@$username",
      'password': password,
      "usertype": userType,
      'affiliationcode': affiliationCode,
      "authenticationtype": 1,
    });
  }

  Future<ApiResponse<UserProfileModel>> getUserProfileImage(
      String userId, String affiliationCode) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getUserProfileImage(userId, affiliationCode),
      (json) async {
        if (json != null) {
          final userProfile = UserProfileModel.fromJson(json);
          if (userGettingLoggedIn != null) {
            userGettingLoggedIn?.profileImageUrl = userProfile.userImage;
            userGettingLoggedIn?.classCode = userProfile.classCode;
            userGettingLoggedIn?.sectionCode = userProfile.sectionCode;
            userGettingLoggedIn?.className = userProfile.className;
            userGettingLoggedIn?.sectionName = userProfile.sectionName;
            userGettingLoggedIn?.affiliationCode = affiliationCode;
          }
          return userProfile;
        }
        return UserProfileModel(
          userImage: '',
          classCode: '',
          sectionCode: '',
          className: '',
          sectionName: '',
        );
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<User>> getUserDetailsFromEmail(
      String userId, String affiliationCode) async {
    ApiResponse<User> response = await NetworkManager.instance.makeRequest(
      Endpoints.login,
      (json) async {
        userGettingLoggedIn = User.fromJson(json);
        userGettingLoggedIn?.affiliationCode = affiliationCode;

        // Call profile image API after successful login
        await getUserProfileImage(userId, affiliationCode);
        await LocalStorage.addUser(userGettingLoggedIn!);

        return userGettingLoggedIn!;
      },
      method: HttpMethod.post,
      body: {
        'userid': userId,
        'affiliationcode': affiliationCode,
      },
    );
    return response;
  }

  Future<ApiResponse<void>> logout(BuildContext context) async {
    debugPrint("AuthViewModel: Logging out...");
    final user = getLoggedInUser();
    String? uuid = user?.username;
    String? deviceId = DeviceInfoService.deviceId;

    // Notify server asynchronously (don't await)
    if (uuid != null && deviceId != null) {
      NetworkManager.instance.makeRequest(
        Endpoints.logoutEndpoint(uuid, deviceId),
        (json) async => null,
        method: HttpMethod.post, // Changed from HttpMethod.option
      ).catchError((e) => debugPrint("Server logout failed: $e"));
    }

    // Always clear local session and restart app to ensure clean state
    await LocalStorage.logoutCurrentUser();
    notifyListeners();
    
    if (context.mounted) {
      Phoenix.rebirth(context);
    }

    return ApiResponse.success();
  }

  Future<ApiResponse<void>> changePassword(
      String password, String newPassword, String newVerifyPassword) async {
    String? userId = getLoggedInUser()?.username;

    if (userId == null) {
      return ApiResponse.failure("User is not logged in");
    }

    return NetworkManager.instance
        .makeRequest(Endpoints.getChangePasswordEndpoint, (json) async {
      return;
    }, method: HttpMethod.post, body: {
      'password': password,
      'newpassword': newPassword,
      'newverifypassword': newVerifyPassword,
    });
  }

  Future<ApiResponse> refreshToken() async {
    try {
      User? loggedInUser = getLoggedInUser();

      String? userId = loggedInUser?.username;

      String? affiliationCode = loggedInUser?.affiliationCode;

      if (userId == null || affiliationCode == null) {
        return ApiResponse.failure("User is not logged in");
      }

      return NetworkManager.instance.makeRequest(
        Endpoints.refreshToken(userId, affiliationCode),
        (json) async {
          if (json != null &&
              json.runtimeType == String &&
              (json as String).isNotEmpty) {
            // Call profile image API after successful login
            loggedInUser?.accessToken = json;
            await LocalStorage.addUser(loggedInUser!);
          }
        },
        removeHeaders: true,
      );
    } catch (e) {
      return ApiResponse.failure("An error occurred");
    }
  }
  Future<bool> loginAsDummyAdmin() async {
    try {
      // 1. Create a dummy JSON payload that matches what your API usually returns
      // You may need to adjust these keys based on your actual User.fromJson factory
      final Map<String, dynamic> dummyAdminJson = {
        'userid': 'admin_001',
        'username': 'System Admin',
        'usertype': 'Admin', // Set to whatever your app checks for admin rights
        'email': 'admin@school.com',
      };

      // 2. Instantiate the user
      User dummyAdmin = User.fromJson(dummyAdminJson);
      
      // 3. Set the required session variables
      dummyAdmin.accessToken = "mock_admin_access_token_12345";
      dummyAdmin.isLogged = true;
      dummyAdmin.affiliationCode = "TEST_SCHOOL_01";
      dummyAdmin.profileImageUrl = "https://i.pravatar.cc/150?u=admin";
      
      // Clear out student-specific fields
      dummyAdmin.classCode = "";
      dummyAdmin.sectionCode = "";
      dummyAdmin.className = "Administration";
      dummyAdmin.sectionName = "";

      // 4. Save to local storage to persist the session
      await LocalStorage.addUser(dummyAdmin);
      
      // 5. Update state
      notifyListeners();
      
      return true; // Success
    } catch (e) {
      debugPrint("Dummy Admin Login Failed: $e");
      return false; // Failed
    }
  }
}
