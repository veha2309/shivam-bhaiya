# Google Play Photo and Video Permissions Fix

## Issue Summary

Google Play rejected the app due to the use of `READ_MEDIA_IMAGES` permission, which is now restricted and only allowed for apps with core functionality requiring persistent access to all photo/video files.

## Changes Made

### 1. AndroidManifest.xml

- **Removed**: `READ_MEDIA_IMAGES` permission
- **Kept**:
  - `CAMERA` permission (still needed for taking photos)
  - `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` (limited to Android 12 and below with `maxSdkVersion="32"`)

### 2. Code Changes

Updated `lib/document/view/upload_document_screen.dart`:

- Added comments explaining that the app now uses Android Photo Picker (Android 13+)
- Both `image_picker` and `file_picker` packages automatically use the system photo picker on Android 13+ when accessing gallery
- No permission dialogs will be shown to users on Android 13+ for one-time file/photo access

## How It Works Now

### For Android 13 (API 33) and Above:

- **Photo Picker**: The system's built-in photo picker is automatically used when users select "GALLERY" or "CHOOSE FILE"
- **No Permissions Required**: Users grant access to individual files through the photo picker UI
- **Compliant**: Fully compliant with Google Play's Photo and Video Permissions policy

### For Android 12 and Below (API 32 and below):

- **Legacy Permissions**: Uses `READ_EXTERNAL_STORAGE` with runtime permission requests
- **Backward Compatible**: The app will continue to work on older Android versions

### Camera Functionality:

- **Unchanged**: Camera functionality still works with the `CAMERA` permission
- **No Gallery Permission Needed**: Photos taken with camera are directly accessible by the app

## Testing Recommendations

1. **Test on Android 13+**: Verify that the photo picker UI appears when selecting gallery/files
2. **Test on Android 12 and below**: Verify that permission requests work correctly
3. **Test Camera**: Ensure camera capture still works correctly
4. **Test File Upload**: Verify document upload functionality works end-to-end

## Dependencies

The following packages handle the photo picker automatically:

- `image_picker`: Latest versions support Android Photo Picker
- `file_picker`: Latest versions support Android Photo Picker

No additional dependencies or configuration needed.

## Compliance

✅ Removed `READ_MEDIA_IMAGES` permission  
✅ Using Android Photo Picker for one-time access  
✅ Backward compatible with Android 12 and below  
✅ Camera functionality preserved  
✅ Compliant with Google Play's Photo and Video Permissions policy

## Next Steps

1. Build a new APK/AAB with these changes
2. Increment the version code (currently 15) to version code 16 or higher
3. Upload to Google Play Console
4. Submit for review with a note explaining the permission removal and photo picker implementation
