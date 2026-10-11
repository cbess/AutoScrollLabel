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
    /// Scrolls the text from left to right.
    CBAutoScrollDirectionRight,
    /// Scrolls the text from right to left. This is the default direction.
    CBAutoScrollDirectionLeft
};

/**
 * A UIView that behaves like a UILabel, except it automatically scrolls its text
 * horizontally whenever the text does not fit within the view's bounds.
 */
@interface CBAutoScrollLabel : UIView <UIScrollViewDelegate>

/// The direction the text scrolls in, defaults to CBAutoScrollDirectionLeft.
@property (nonatomic) CBAutoScrollDirection scrollDirection;
/// Scroll speed in pixels per second, defaults to 30
@property (nonatomic) float scrollSpeed;
/// The amount of time, in seconds, the label pauses before/after each scroll, defaults to 1.5.
@property (nonatomic) NSTimeInterval pauseInterval;
/// The spacing, in pixels, between the end of the text and the start of its repeated copy, defaults to 20.
@property (nonatomic) NSInteger labelSpacing;

/**
 * The animation options used when scrolling the UILabels.
 * @discussion UIViewAnimationOptionAllowUserInteraction is always applied to the animations.
 */
@property (nonatomic) UIViewAnimationOptions animationOptions;

/**
 * Returns YES, if it is actively scrolling, NO if it has paused or if text is within bounds (disables scrolling).
 */
@property (nonatomic, readonly) BOOL scrolling;
/// The length, in points, of the fade gradient applied to the leading/trailing edges while scrolling, defaults to 7.
@property (nonatomic) CGFloat fadeLength;

// UILabel properties
/// The font used to render the text.
@property (nonatomic, strong, nonnull) UIFont *font;
/// The text displayed by the label.
@property (nonatomic, copy, nullable) NSString *text;
/// The styled text displayed by the label.
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
/// The color of the text.
@property (nonatomic, strong, nonnull) UIColor *textColor;
/// The alignment of the text, only applies when not auto-scrolling.
@property (nonatomic) NSTextAlignment textAlignment;
/// The color of the text's shadow.
@property (nonatomic, strong, nullable) UIColor *shadowColor;
/// The offset of the text's shadow.
@property (nonatomic) CGSize shadowOffset;

/**
 * Lays out the scrollview contents, enabling text scrolling if the text will be clipped.
 * @discussion Uses [scrollLabelIfNeeded] internally.
 */
- (void)refreshLabels;

/**
 * Set the text to the label and refresh labels, if needed.
 * @discussion Useful when you have a situation where you need to layout the scroll label after it's text is set.
 * @param text The text to display in the label.
 * @param refresh Pass YES to lay out and refresh the scrolling labels after setting the text.
 */
- (void)setText:(nullable NSString *)text refreshLabels:(BOOL)refresh;

/**
 Set the attributed text and refresh labels, if needed.
 * @param theText The attributed text to display in the label.
 * @param refresh Pass YES to lay out and refresh the scrolling labels after setting the text.
 */
- (void)setAttributedText:(nullable NSAttributedString *)theText refreshLabels:(BOOL)refresh;

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
