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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#   define CB_IS_IOS 1
#   define CB_IF_MAC(T_BLOCK, F_BLOCK) F_BLOCK
#else
#   define CB_IS_MAC 1
#   define CB_IF_MAC(T_BLOCK, F_BLOCK) T_BLOCK
#endif

#if CB_IS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

typedef enum  {
	CBAutoScrollDirectionRight,
	CBAutoScrollDirectionLeft,
} CBAutoScrollDirection;

@interface CBAutoScrollLabel : CB_IF_MAC(NSView, UIView <UIScrollViewDelegate>)
@property (nonatomic) CBAutoScrollDirection scrollDirection;
@property (nonatomic) float scrollSpeed; // pixels per second
@property (nonatomic) NSTimeInterval pauseInterval;
@property (nonatomic) NSInteger labelSpacing; // pixels
#if CB_IS_IOS
/**
 * The animation options used when scrolling the UILabels.
 * @discussion UIViewAnimationOptionAllowUserInteraction is always applied to the animations.
 */
@property (nonatomic) UIViewAnimationOptions animationOptions;
#endif
/**
 * Returns YES, if it is actively scrolling, NO if it has paused or if text is within bounds (disables scrolling).
 */
@property (nonatomic, readonly) BOOL scrolling;
@property (nonatomic, assign) CGFloat fadeLength;

// UILabel properties
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, strong) CB_IF_MAC(NSColor, UIColor) *textColor;
@property (nonatomic, strong) CB_IF_MAC(NSFont, UIFont) *font;
@property (nonatomic, strong) CB_IF_MAC(NSColor, UIColor) *shadowColor;
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
- (void)setText:(NSString *)text refreshLabels:(BOOL)refresh;
- (void)setAttributedText:(NSAttributedString *)theText refreshLabels:(BOOL)refresh;

/**
 * Initiates auto-scroll if the label width exceeds the bounds of the scrollview.
 */
- (void)scrollLabelIfNeeded;
@end
