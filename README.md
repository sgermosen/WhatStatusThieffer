# Social Status Saver
 It's an app designed to browse and save media from social apps without needing to ask for them, especially the videos.

## Supported platforms
 The app is now multi-platform. On the start screen you can pick:

 - **WhatsApp** and **WhatsApp Business** – reads the *viewed* statuses that WhatsApp caches in its public `.Statuses` folder.
 - **Instagram**, **Facebook** and **TikTok** – these apps do **not** expose viewed stories/reels in a public folder, so the app browses the public folders where each app saves the media you download/save from within it (e.g. `Pictures/Instagram`, `DCIM/Facebook`, `DCIM/TikTok`, `Movies/…`, `Download/…`).

 Adding a new platform only requires adding a `MediaPlatform` entry to `SUPPORTED_PLATFORMS` in
 `src/status_saver/lib/constants/app_constants.dart` – no screen or tab code needs to change. Each entry
 declares the candidate folders to scan; every folder that exists is scanned and its images/videos are merged.

## Download from a link
 Besides browsing folders, the app can download media directly from a **shared link** (Start screen →
 "Download from a link", also in the side menu). You paste a link and it resolves the direct photo/video and
 saves it to the SAVED tab.

 Resolution happens **entirely on the device, no server** (`lib/services/link_downloader.dart`): a per-platform
 resolver scrapes the public page, with a generic Open Graph (`og:video` / `og:image`) fallback.

 - **TikTok / Facebook** public videos: usually work.
 - **Instagram**: limited – most content now needs a logged-in session, so it often only works for public posts.
 - Because it scrapes public pages, it is **fragile**: expect the per-platform resolvers to need updates when the
   platforms change their markup. It is also each user's responsibility to only download content they own or have
   permission to use, and to respect each platform's Terms of Service.

 To add/repair a platform resolver, implement `PlatformResolver` in `link_downloader.dart`.

### Sharing a link into the app
 You can also **share** a link straight from Instagram / TikTok / Facebook / a browser (Share → this app) and it
 opens the "Download from link" screen with the URL prefilled. This uses `receive_sharing_intent` (pinned to
 `1.4.5`, the classic `getInitialText` / `getTextStream` API) wired in `start_screen.dart`, plus a `text/*`
 `SEND` intent-filter in `AndroidManifest.xml`.

 - **Android**: works out of the box with the intent-filter above.
 - **iOS**: receiving shares additionally requires adding a *Share Extension* target in Xcode (not configured
   here). Without it, iOS builds fine but won't appear in the iOS share sheet.

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

