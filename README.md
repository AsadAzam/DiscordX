# DiscordX
![GitHub release (latest by date)](https://img.shields.io/github/v/release/AsadAzam/DiscordX?style=for-the-badge)

![GitHub](https://img.shields.io/github/license/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/issues-raw/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/issues-closed-raw/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/issues-pr/AsadAzam/DiscordX?style=for-the-badge)
![GitHub](https://img.shields.io/github/last-commit/AsadAzam/DiscordX?style=for-the-badge)
![GitHub All Releases](https://img.shields.io/github/downloads/AsadAzam/Discordx/total?style=for-the-badge)

DiscordX adds support for Xcode on Discord AKA Discord Rich Presence

<p float="center">
    <img src="https://user-images.githubusercontent.com/32137859/94646396-cc2da880-030b-11eb-9c5a-69ce0fe9a993.png">
    <img src="https://user-images.githubusercontent.com/32137859/94650644-b8d30b00-0314-11eb-94f4-d6434d3d1d76.png">
    <img src="https://user-images.githubusercontent.com/32137859/94650802-05b6e180-0315-11eb-93f0-785db0328552.png">
    <img src="https://user-images.githubusercontent.com/32137859/94650965-46aef600-0315-11eb-84cf-5f1cf3f109f7.png">
    <img src="https://user-images.githubusercontent.com/32137859/94651142-98f01700-0315-11eb-8fdb-c11510aaa59b.png">
    <img src="https://user-images.githubusercontent.com/32137859/94651232-c4730180-0315-11eb-90cd-1ef5af4eacbe.png">
    <img src="https://user-images.githubusercontent.com/32137859/94651330-ef5d5580-0315-11eb-96f8-7b633830f950.png">
</p>

DiscordX displays, the current file you are working on, as well as the current workspace in use. It uses the same icons which exist in Xcode 12.0.1 (12A7300)

DIscordX adds support for current application in use too. There are other applications that do the exact same thing but none of them which I used supported applications or such a wide variety of file types, also none of them are updated for Xcode 12.

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
If you are modifying/ tweaking the application make sure you change the *Team* under *Signing & Capabilities*.

DiscordX uses [PKBeam's Fork](https://github.com/PKBeam/SwordRPC) of [Azoy's SwordRPC](https://github.com/Azoy/SwordRPC).

## System Requirements
- macOS Sierra (10.12) (Minimum)
- Xcode installed

## Usage
Simply place the application under Applications Folder (not mandatory) and it will ask for two permissions, one is for controlling Xcode and other is for System Events,

As the app uses Apple script and to perform any operation it would need access to whatever the script is going to run on. 

List of Apple Scipts run:
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

You can verify what permissions DiscordX uses by opening System Preferences and looking in Security & Privacy under Privacy, then Automation.
That's it, you're done - DiscordX will now automatically monitor Xcode.

If you like, you can set DiscordX to automatically open on login.

# Note
DiscordX is a fork of [RPFX](https://github.com/PKBeam/RPFX) I didn't contribute to the original as I didn't like the name RPFX.
