## AutoScrollLabel

A `UILabel` with auto scrolling for text that may be clipped by the view. Provides edge fading, speed adjustment, scroll direction, etc.  

![screenshot](https://github.com/cbess/AutoScrollLabel/raw/master/AutoScrollLabelDemo/screenshot.png)
![screenshot2](https://github.com/cbess/AutoScrollLabel/raw/master/AutoScrollLabelDemo/screenshot2.png)

iOS 12, tvOS 12 and greater.

### Installation

#### Swift Package Manager

In Xcode, choose **File > Add Package Dependencies...** and enter the repository URL:

```
https://github.com/cbess/AutoScrollLabel.git
```

Or add it to the `dependencies` of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/cbess/AutoScrollLabel.git", commit: "<HASH>")
]
```

Then add `"AutoScrollLabel"` to your target's dependencies.

### Usage

```objc
// swift package manager
@import AutoScrollLabel;
```

```swift
import AutoScrollLabel
```
    
```objc
autoScrollLabel.text = @"This text may be clipped, but now it will be scrolled.";
autoScrollLabel.textColor = [UIColor systemBlueColor];
autoScrollLabel.labelSpacing = 35; // distance between start and end labels
autoScrollLabel.pauseInterval = 3.7; // seconds of pause before scrolling starts again
autoScrollLabel.scrollSpeed = 30; // pixels per second
autoScrollLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
autoScrollLabel.fadeLength = 12.f; // length of the left and right edge fade, 0 to disable
```

[Soli Deo gloria](https://perfectGod.com)

#### Real world use:
[Sola Tunes iOS App (Free)](https://apps.apple.com/us/app/sola-tunes-music-for-all/id554537542)
[VerseCloud (Free)](https://apps.apple.com/us/app/versecloud-bible-study-tool/id1092932080)
#### License

MIT - Copyright (c) 2019 Christopher Bess
