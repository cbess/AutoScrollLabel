##AutoScrollLabel

A UILabel with auto scrolling for text that may be clipped by the view. Provides edge fading, speed adjustment, scroll direction, etc.  

CocoaPod: `AutoScrollLabel`

iOS 7, tvOS 9 and greater. For Non-ARC use v0.2.1.

```objc
#import <AutoScrollLabel/CBAutoScrollLabel.h>
```

```swift
import AutoScrollLabel
```

![screenshot](https://github.com/cbess/AutoScrollLabel/raw/master/AutoScrollLabelDemo/screenshot.png)
![image](http://a549.phobos.apple.com/us/r1000/071/Purple/v4/19/6f/c4/196fc40b-2fb4-975b-5abe-ea42850a061e/mzl.kpehwyik.320x480-75.jpg)

#### Real world use:

![app](http://static.solatunes.com//images/app/app-stage.jpg)

[Sola Tunes App (Free)](http://www.solatunes.com/app)

Usage:
    
    autoScrollLabel.text = @"This text may be clipped, but now it will be scrolled.";
    autoScrollLabel.textColor = [UIColor blueColor];
    autoScrollLabel.labelSpacing = 35; // distance between start and end labels
    autoScrollLabel.pauseInterval = 3.7; // seconds of pause before scrolling starts again
    autoScrollLabel.scrollSpeed = 30; // pixels per second
    autoScrollLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
    autoScrollLabel.fadeLength = 12.f; // length of the left and right edge fade, 0 to disable

#### License

MIT - Copyright (c) 2013 Christopher Bess
