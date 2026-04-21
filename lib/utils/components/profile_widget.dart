import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';

DecorationImage getProfilePicture(String profilePicture) {
  return DecorationImage(
      image: (profilePicture.isEmpty == true)
          ? const AssetImage(ImageConstants.placeHolder)
              as ImageProvider<Object>
          : NetworkImage(profilePicture) as ImageProvider<Object>);
}
