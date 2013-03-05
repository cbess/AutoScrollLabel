##AutoScrollLabel

Provides auto scrolling for text that may be clipped by the view. iOS 4.3 and greater, works with ARC and non-ARC projects.

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
    autoScrollLabel.textAlignment = UITextAlignmentCenter; // centers text when no auto-scrolling is applied
    autoScrollLabel.fadeLength = 12.f; // length of the left and right edge fade, 0 to disable
    
[http://blog.stormyprods.com/2009/10/more-details-on-autoscrolllabel-usage.html](http://blog.stormyprods.com/2009/10/more-details-on-autoscrolllabel-usage.html) - Old, but still relevant example usage.
