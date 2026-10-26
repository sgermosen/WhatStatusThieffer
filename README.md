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
 opens the "Download from link" screen with the URL prefilled. This uses `receive_sharing_intent` (`getInitialMedia` /
 `getMediaStream`, keeping only text/url items) wired in `start_screen.dart`, plus a `text/*` `SEND`
 intent-filter in `AndroidManifest.xml`.

 - **Android**: works out of the box with the intent-filter above.
 - **iOS**: receiving shares additionally requires adding a *Share Extension* target in Xcode (not configured
   here). Without it, iOS builds fine but won't appear in the iOS share sheet.

# Building

Requires a recent **Flutter stable (3.47+)** and **JDK 17+**.

```bash
cd src/status_saver
flutter pub get
flutter test
flutter build appbundle --release
```

See `docs/GUIA_PUBLICACION_PLAYSTORE.md` for signing, Play Console, AdMob and subscriptions.

# Known Issues

## Fixed
- **Android 11+ WhatsApp statuses:** Android no longer allows reading the `.Statuses` folder directly. The app now asks
  the user once (system folder picker) for access to that folder and keeps the permission. No "All files access" needed.
- **Android 13+ permissions:** the app requests photo/video access instead of the removed storage permission.
- **Bulk delete:** the list didn't refresh on selection and a failed delete hid files that were still on disk.
- **Watermark leftovers:** the watermark feature (and its ffmpeg dependency) was removed.
- **Notifications:** the broken daily reminder was removed.

## Open
- Not tested on a physical device yet: please test status access, saving, sharing, ads and purchases before release.
- iOS is not set up (the app targets Android).

# Feature wanted

## Floating button to download
I want a floating button than if I am seen the status from my friend I hit it and immediately start the download of that status.

