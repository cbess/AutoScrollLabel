//
//  ASLViewController.m
//  AutoScrollLabelDemo
//
//  Created by Christopher Bess on 6/25/12.
//  Copyright (c) 2012 C. Bess. All rights reserved.
//

#import "ASLViewController.h"
#import "CBAutoScrollLabel.h"

@interface ASLViewController ()
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *autoScrollLabel;
@end

@implementation ASLViewController
@synthesize autoScrollLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup the auto scroll label
    self.autoScrollLabel.text = @"This text may be clipped, but now it will be scrolled.";
    self.autoScrollLabel.textColor = [UIColor blueColor];
    self.autoScrollLabel.labelSpacing = 35; // distance between start and end labels
    self.autoScrollLabel.pauseInterval = 1.7; // seconds of pause before scrolling starts again
    self.autoScrollLabel.scrollSpeed = 30; // pixels per second
    self.autoScrollLabel.textAlignment = NSTextAlignmentCenter; // centers text when no auto-scrolling is applied
    self.autoScrollLabel.fadeLength = 12.f;
    self.autoScrollLabel.scrollDirection = CBAutoScrollDirectionLeft;
}

@end
