# DiscordX
![GitHub release (latest by date)](https://img.shields.io/github/v/release/AsadAzam/DiscordX?style=for-the-badge)

![GitHub](https://img.shields.io/github/license/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/issues-raw/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/issues-closed-raw/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/issues-pr/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/last-commit/AsadAzam/DiscordX?style=for-the-badge)
![GitHub All Releases](https://img.shields.io/github/downloads/AsadAzam/Discordx/total?style=for-the-badge)

## New Features
1. Added a simple Status Bar Menu to start, stop or close the App.

## TODOs
1. Keep a log file for time spent on every file

DiscordX adds support for Xcode on Discord, AKA Discord Rich Presence.

<p float="center">
  <img src="https://user-images.githubusercontent.com/32137859/94646396-cc2da880-030b-11eb-9c5a-69ce0fe9a993.png">
  <img src="https://user-images.githubusercontent.com/32137859/94650644-b8d30b00-0314-11eb-94f4-d6434d3d1d76.png">
  <img src="https://user-images.githubusercontent.com/32137859/94650802-05b6e180-0315-11eb-93f0-785db0328552.png">
  <img src="https://user-images.githubusercontent.com/32137859/94650965-46aef600-0315-11eb-84cf-5f1cf3f109f7.png">
  <img src="https://user-images.githubusercontent.com/32137859/94651142-98f01700-0315-11eb-8fdb-c11510aaa59b.png">
  <img src="https://user-images.githubusercontent.com/32137859/94651232-c4730180-0315-11eb-90cd-1ef5af4eacbe.png">
  <img src="https://user-images.githubusercontent.com/32137859/94651330-ef5d5580-0315-11eb-96f8-7b633830f950.png">
</p>

DiscordX displays the current file you are working on and the current workspace in use. It uses the same icons which exist in Xcode 12.0.1 (12A7300)

DIscordX adds support for the current application in use too. Other applications do the exact same thing, but none of them I used supported applications or such a wide variety of file types. Also, none of them are updated for Xcode 13.

The following file type extensions are supported:
- `.swift`
- `.playground`
- `.storyboard`
- `.xcodeproj`
- `.h`
- `.m`
- `.cpp`
- `.c`
- `.sdef`
- `.plist`
- `.md`
- `.appex`
- `.rcproject`
- `.rtf`
- `.rtfd`
- `.pch`
- `.mm`
- `.xcassets`
- `.iig`
- `.metal`
- `.xib`
- `.arobject`
- `.entitlements`

The following applications are supported:
- `Simulator`
- `Instruments`
- `Accessibility Inspector`
- `FileMerge`
- `Create ML`
- `RealityComposer`

## Dependencies
If you are modifying/ tweaking the application, make sure you change the *Team* under *Signing & Capabilities*.

DiscordX uses [PKBeam's Fork](https://github.com/PKBeam/SwordRPC) of [Azoy's SwordRPC](https://github.com/Azoy/SwordRPC).

## System Requirements
- macOS Sierra (10.12) (Minimum)
- Xcode installed

## Usage
1. Download the project, and open it on Xcode.
2. Go to Signing & Capabilities, choose **Team** and Select **Sign to Run Locally** in Signing Certificate.
3. Build and Run the App.
4. (Optional) Go to Products under the Navigator, right-click on DiscordX.app, and click on **Show in Finder**. Copy/Cut - Paste in the Applications folder, and it should be easier to launch next time.

After running it, it will ask for two permissions; one is for controlling Xcode, and the other is for System Events. As the app uses Apple script to perform any operation, it would need access to whatever the script will run on.

### Configurable
- You can set the refresh interval of rich presence (by default, it refreshes every 5 seconds) [Note: When strict mode is enabled, it will refresh immediately when switching to and from Xcode]
- Strict Mode (Timer will only keep the time you were active on Xcode)
- Flaunt Mode (Timer will not stop on Sleep and Wakeup of MacOS)

List of Apple Scripts run:
```
tell application "Xcode"
  return name of windows
end tell
```
```
tell application "Xcode"
  return file of documents
end tell
```
```
tell application "Xcode"
  return name of documents
end tell
```
```
tell application "Xcode"
  return active workspace document
end tell
```
```
tell application "System Events"
  get the name of every application process whose frontmost is true
end tell
```
```
tell application (path to frontmost application as Unicode text)
  if name is "Xcode" then
    get version
  end if
end tell
```

You can verify what permissions DiscordX uses by opening System Preferences and looking in Security & Privacy under Privacy, then Automation.
That's it, you're done - DiscordX will now automatically monitor Xcode.

If you like, you can set DiscordX to automatically open on login.

# Note
DiscordX is a fork of [RPFX](https://github.com/PKBeam/RPFX). I didn't contribute to the original as I didn't like the name RPFX.
