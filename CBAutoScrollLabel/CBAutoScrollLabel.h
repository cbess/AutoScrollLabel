//
//  CBAutoScrollLabel.h
//  CBAutoScrollLabel
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

/// Specifies the direction of the scroll
typedef NS_ENUM(NSInteger, CBAutoScrollDirection) {
    CBAutoScrollDirectionRight,
    CBAutoScrollDirectionLeft
};

@interface CBAutoScrollLabel : UIView <UIScrollViewDelegate>

@property (nonatomic) CBAutoScrollDirection scrollDirection;
@property (nonatomic) float scrollSpeed; // pixels per second, defaults to 30
@property (nonatomic) NSTimeInterval pauseInterval; // defaults to 1.5
@property (nonatomic) NSInteger labelSpacing; // pixels, defaults to 20

/**
 * The animation options used when scrolling the UILabels.
 * @discussion UIViewAnimationOptionAllowUserInteraction is always applied to the animations.
 */
@property (nonatomic) UIViewAnimationOptions animationOptions;

/**
 * Returns YES, if it is actively scrolling, NO if it has paused or if text is within bounds (disables scrolling).
 */
@property (nonatomic, readonly) BOOL scrolling;
@property (nonatomic) CGFloat fadeLength; // defaults to 7

// UILabel properties
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nonnull) UIColor *textColor;
@property (nonatomic, strong, nonnull) UIFont *font;
@property (nonatomic, strong, nullable) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) NSTextAlignment textAlignment; // only applies when not auto-scrolling

/**
 * Lays out the scrollview contents, enabling text scrolling if the text will be clipped.
 * @discussion Uses [scrollLabelIfNeeded] internally.
 */
- (void)refreshLabels;

/**
 * Set the text to the label and refresh labels, if needed.
 * @discussion Useful when you have a situation where you need to layout the scroll label after it's text is set.
 */
- (void)setText:(NSString * __nullable)text refreshLabels:(BOOL)refresh;

/**
 Set the attributed text and refresh labels, if needed.
 */
- (void)setAttributedText:(NSAttributedString * __nullable)theText refreshLabels:(BOOL)refresh;

/**
 * Initiates auto-scroll, if the label width exceeds the bounds of the scrollview.
 */
- (void)scrollLabelIfNeeded;

/**
 * Observes UIApplication state notifications to auto-restart scrolling and watch for 
 * orientation changes to refresh the labels.
 * @discussion Must be called to observe the notifications. Calling multiple times will still only
 * register the notifications once.
 */
- (void)observeApplicationNotifications;

@end
