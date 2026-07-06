# Social Status Saver
 It's an app designed to browse and save media from social apps without needing to ask for them, especially the videos.

## Supported platforms
 The app is now multi-platform. On the start screen you can pick:

 - **WhatsApp** and **WhatsApp Business** – reads the *viewed* statuses that WhatsApp caches in its public `.Statuses` folder.
 - **Instagram**, **Facebook** and **TikTok** – these apps do **not** expose viewed stories/reels in a public folder, so the app browses the public folders where each app saves the media you download/save from within it (e.g. `Pictures/Instagram`, `DCIM/Facebook`, `DCIM/TikTok`, `Movies/…`, `Download/…`).

 Adding a new platform only requires adding a `MediaPlatform` entry to `SUPPORTED_PLATFORMS` in
 `src/status_saver/lib/constants/app_constants.dart` – no screen or tab code needs to change. Each entry
 declares the candidate folders to scan; every folder that exists is scanned and its images/videos are merged.

# Knowed Issues

## Android 11+ scoped storage:
With the privacy updates the rules to access those folders changed. The app now also scans the newer scoped
location (`Android/media/com.whatsapp/WhatsApp/Media/.Statuses`) and declares the granular media permissions
(`READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`) for Android 13+, which improves access. On Android 11/12, full access
to every folder may still require `MANAGE_EXTERNAL_STORAGE` ("All files access"), which is not requested here.

## Bulk delete is not really deleting well: 
On saved status if you press for 2 seconds, the bulk delete its enabled, but, apparently it work, it remove it from the screen, but, when you close the app, the deleted status are still there.

## When a video is saved or shared it creates a picture for the watermark, but it doesn't be deleted: 
This problem can be solved only by removing the watermark signal, but, will be great to solve the correct deletion of this issue. (In Production Version the AddWatermark method was disabled)

## Notifications are not working
There's a configuration of a reminder that is supposed to be executed daily, on production is not working but on debug mode yes

# Feature wanted

## Floating button to download
I want a floating button than if I am seen the status from my friend I hit it and immediately start the download of that status.

