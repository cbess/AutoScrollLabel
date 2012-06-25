//
//  AutoScrollLabel.h
//  AutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Updated/Modernized by Christopher Bess on 2/5/12
//
//  Copyright 2009 Stormy Productions. All rights reserved.
//
//  Originally from: http://blog.stormyprods.com/2009/10/simple-scrolling-uilabel-for-iphone.html
//
//  Permission is granted to use this code free of charge for any project.
//

#import <UIKit/UIKit.h>

typedef enum  {
	AutoScrollDirectionRight,
	AutoScrollDirectionLeft,
} AutoScrollDirection;

@interface AutoScrollLabel : UIScrollView <UIScrollViewDelegate>
@property (nonatomic) AutoScrollDirection scrollDirection;
@property (nonatomic) float scrollSpeed; // pixels per second
@property (nonatomic) NSTimeInterval pauseInterval;
@property (nonatomic) NSInteger labelSpacing; // pixels
/**
 * The animation options used when scrolling the UILabels.
 * @discussion UIViewAnimationOptionAllowUserInteraction is always applied to the animations.
 */
@property (nonatomic) UIViewAnimationOptions animationOptions;
/**
 * Returns YES, if it is actively scrolling, NO if it has paused or if text is within bounds (disables scrolling).
 */
@property (nonatomic, readonly) BOOL scrolling;

// UILabel properties
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) UITextAlignment textAlignment; // only applies when not auto-scrolling

/**
 * Lays out the scrollview contents, enabling text scrolling if the text will be clipped.
 * @discussion Uses [scrollLabelIfNeeded] internally, if needed.
 */
- (void)refreshLabels;

/**
 * Initiates auto-scroll if the labels width exceeds the bounds of the scrollview.
 */
- (void)scrollLabelIfNeeded;
@end
