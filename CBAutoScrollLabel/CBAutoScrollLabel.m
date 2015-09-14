//
//  CBAutoScrollLabel.m
//  CBAutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Updated by Christopher Bess on 2/5/12
//
//  Copyright 2009 Stormy Productions.
//
//  Permission is granted to use this code free of charge for any project.
//

#import "CBAutoScrollLabel.h"
#import <QuartzCore/QuartzCore.h>

#define kLabelCount 2
#define kDefaultFadeLength 7.f
// pixel buffer space between scrolling label
#define kDefaultLabelBufferSpace 20
#define kDefaultPixelsPerSecond 30
#define kDefaultPauseTime 1.5f

// shortcut method for NSArray iterations
static void each_object(NSArray *objects, void (^block)(id object)) {
    for (id obj in objects) {
        block(obj);
    }
}

// shortcut to change each label attribute value
#define EACH_LABEL(ATTR, VALUE) each_object(self.labels, ^(UILabel *label) { label.ATTR = VALUE; });

@interface CBAutoScrollLabel ()

@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong, readonly) UILabel *mainLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CBAutoScrollLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // create the labels
    NSMutableSet *labelSet = [[NSMutableSet alloc] initWithCapacity:kLabelCount];

    for (int index = 0; index < kLabelCount; ++index) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = self.autoresizingMask;

        // store labels
        [self.scrollView addSubview:label];
        [labelSet addObject:label];
    }

    self.labels = [labelSet.allObjects copy];

    // default values
    _scrollDirection = CBAutoScrollDirectionLeft;
    _scrollSpeed = kDefaultPixelsPerSecond;
    self.pauseInterval = kDefaultPauseTime;
    self.labelSpacing = kDefaultLabelBufferSpace;
    self.textAlignment = NSTextAlignmentLeft;
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.fadeLength = kDefaultFadeLength;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self didChangeFrame];
}

// For autolayout
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    [self didChangeFrame];
}

#pragma mark - Properties

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _scrollView.backgroundColor = [UIColor clearColor];

        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setFadeLength:(CGFloat)fadeLength {
    if (_fadeLength != fadeLength) {
        _fadeLength = fadeLength;

        [self refreshLabels];
        [self applyGradientMaskForFadeLength:fadeLength enableFade:NO];
    }
}

- (UILabel *)mainLabel {
    return self.labels[0];
}

- (void)setText:(NSString *)theText {
    [self setText:theText refreshLabels:YES];
}

- (void)setText:(NSString *)theText refreshLabels:(BOOL)refresh {
    // ignore identical text changes
    if ([theText isEqualToString:self.text])
        return;

    EACH_LABEL(text, theText)

    if (refresh)
        [self refreshLabels];
}

- (NSString *)text {
    return self.mainLabel.text;
}

- (void)setAttributedText:(NSAttributedString *)theText {
    [self setAttributedText:theText refreshLabels:YES];
}

- (void)setAttributedText:(NSAttributedString *)theText refreshLabels:(BOOL)refresh {
    // ignore identical text changes
    if ([theText.string isEqualToString:self.attributedText.string])
        return;

    EACH_LABEL(attributedText, theText)

    if (refresh)
        [self refreshLabels];
}

- (NSAttributedString *)attributedText {
    return self.mainLabel.attributedText;
}

- (void)setTextColor:(UIColor *)color {
    EACH_LABEL(textColor, color)
}

- (UIColor *)textColor {
    return self.mainLabel.textColor;
}

- (void)setFont:(UIFont *)font {
    if (self.mainLabel.font == font)
        return;

    EACH_LABEL(font, font)

    [self refreshLabels];
    [self invalidateIntrinsicContentSize];
}

- (UIFont *)font {
    return self.mainLabel.font;
}

- (void)setScrollSpeed:(float)speed {
    _scrollSpeed = speed;

    [self scrollLabelIfNeeded];
}

- (void)setScrollDirection:(CBAutoScrollDirection)direction {
    _scrollDirection = direction;

    [self scrollLabelIfNeeded];
}

- (void)setShadowColor:(UIColor *)color {
    EACH_LABEL(shadowColor, color)
}

- (UIColor *)shadowColor {
    return self.mainLabel.shadowColor;
}

- (void)setShadowOffset:(CGSize)offset {
    EACH_LABEL(shadowOffset, offset)
}

- (CGSize)shadowOffset {
    return self.mainLabel.shadowOffset;
}

#pragma mark - Autolayout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0.0f, [self.mainLabel intrinsicContentSize].height);
}

#pragma mark - Misc

- (void)observeApplicationNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // restart scrolling when the app has been activated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollLabelIfNeeded)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollLabelIfNeeded)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

#ifndef TARGET_OS_TV
    // refresh labels when interface orientation is changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUIApplicationDidChangeStatusBarOrientationNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
#endif

}

- (void)enableShadow {
    _scrolling = YES;
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:YES];
}

- (void)scrollLabelIfNeeded {
    if (!self.text.length)
        return;

    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
    if (labelWidth <= CGRectGetWidth(self.bounds))
        return;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollLabelIfNeeded) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableShadow) object:nil];

    [self.scrollView.layer removeAllAnimations];

    BOOL doScrollLeft = (self.scrollDirection == CBAutoScrollDirectionLeft);
    self.scrollView.contentOffset = (doScrollLeft ? CGPointZero : CGPointMake(labelWidth + self.labelSpacing, 0));

    // Add the left shadow after delay
    [self performSelector:@selector(enableShadow) withObject:nil afterDelay:self.pauseInterval];

    // animate the scrolling
    NSTimeInterval duration = labelWidth / self.scrollSpeed;
    [UIView animateWithDuration:duration delay:self.pauseInterval options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
         // adjust offset
         self.scrollView.contentOffset = (doScrollLeft ? CGPointMake(labelWidth + self.labelSpacing, 0) : CGPointZero);
     } completion: ^(BOOL finished) {
         _scrolling = NO;

         // remove the left shadow
         [self applyGradientMaskForFadeLength:self.fadeLength enableFade:NO];

         // setup pause delay/loop
         if (finished) {
             [self performSelector:@selector(scrollLabelIfNeeded) withObject:nil];
         }
     }];
}

- (void)refreshLabels {
    __block float offset = 0;

    each_object(self.labels, ^(UILabel *label) {
        [label sizeToFit];

        CGRect frame = label.frame;
        frame.origin = CGPointMake(offset, 0);
        frame.size.height = CGRectGetHeight(self.bounds);
        label.frame = frame;

        // Recenter label vertically within the scroll view
        label.center = CGPointMake(label.center.x, roundf(self.center.y - CGRectGetMinY(self.frame)));

        offset += CGRectGetWidth(label.bounds) + self.labelSpacing;
    });

    self.scrollView.contentOffset = CGPointZero;
    [self.scrollView.layer removeAllAnimations];

    // if the label is bigger than the space allocated, then it should scroll
    if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds)) {
        CGSize size;
        size.width = CGRectGetWidth(self.mainLabel.bounds) + CGRectGetWidth(self.bounds) + self.labelSpacing;
        size.height = CGRectGetHeight(self.bounds);
        self.scrollView.contentSize = size;

        EACH_LABEL(hidden, NO)

        [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];

        [self scrollLabelIfNeeded];
    } else {
        // Hide the other labels
        EACH_LABEL(hidden, (self.mainLabel != label))

        // adjust the scroll view and main label
        self.scrollView.contentSize = self.bounds.size;
        self.mainLabel.frame = self.bounds;
        self.mainLabel.hidden = NO;
        self.mainLabel.textAlignment = self.textAlignment;

        // cleanup animation
        [self.scrollView.layer removeAllAnimations];

        [self applyGradientMaskForFadeLength:0 enableFade:NO];
    }
}

// bounds or frame has been changeds
- (void)didChangeFrame {
    [self refreshLabels];
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];
}

#pragma mark - Gradient

// ref: https://github.com/cbpowell/MarqueeLabel
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength enableFade:(BOOL)fade {
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);

    if (labelWidth <= CGRectGetWidth(self.bounds))
        fadeLength = 0;

    if (fadeLength) {
        // Recreate gradient mask with new fade length
        CAGradientLayer *gradientMask = [CAGradientLayer layer];

        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;

        gradientMask.startPoint = CGPointMake(0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1, CGRectGetMidY(self.frame));

        // setup fade mask colors and location
        id transparent = (id)[UIColor clearColor].CGColor;
        id opaque = (id)[UIColor blackColor].CGColor;
        gradientMask.colors = @[transparent, opaque, opaque, transparent];

        // calcluate fade
        CGFloat fadePoint = fadeLength / CGRectGetWidth(self.bounds);
        NSNumber *leftFadePoint = @(fadePoint);
        NSNumber *rightFadePoint = @(1 - fadePoint);
        if (!fade) switch (self.scrollDirection) {
                case CBAutoScrollDirectionLeft:
                    leftFadePoint = @0;
                    break;

                case CBAutoScrollDirectionRight:
                    leftFadePoint = @0;
                    rightFadePoint = @1;
                    break;
            }

        // apply calculations to mask
        gradientMask.locations = @[@0, leftFadePoint, rightFadePoint, @1];

        // don't animate the mask change
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.layer.mask = gradientMask;
        [CATransaction commit];
    } else {
        // Remove gradient mask for 0.0f length fade length
        self.layer.mask = nil;
    }
}

#pragma mark - Notifications

- (void)onUIApplicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification {
    // delay to have it re-calculate on next runloop
    [self performSelector:@selector(refreshLabels) withObject:nil afterDelay:.1f];
    [self performSelector:@selector(scrollLabelIfNeeded) withObject:nil afterDelay:.1f];
}

@end
