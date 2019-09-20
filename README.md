## AutoScrollLabel

A `UILabel` with auto scrolling for text that may be clipped by the view. Provides edge fading, speed adjustment, scroll direction, etc.  

![screenshot](https://github.com/cbess/AutoScrollLabel/raw/master/AutoScrollLabelDemo/screenshot.png)
![screenshot2](https://github.com/cbess/AutoScrollLabel/raw/master/AutoScrollLabelDemo/screenshot2.png)

CocoaPod: `AutoScrollLabel`

iOS 12, tvOS 12 and greater. For Non-ARC use v0.2.1.

```objc
#import <AutoScrollLabel/CBAutoScrollLabel.h>
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

#### Real world use:

![app](http://static.solatunes.com//images/app/app-stage.jpg)

[Sola Tunes iOS App (Free)](https://itunes.apple.com/us/app/sola-tunes-free-music-for-all/id554537542?mt=8)

#### License

MIT - Copyright (c) 2019 Christopher Bess
