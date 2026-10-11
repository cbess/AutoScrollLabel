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

@property (nonatomic, strong) NSArray<UILabel *> *labels;
@property (nonatomic, strong, readonly) UILabel *mainLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
// monotonically increasing token identifying the current scroll cycle; never reset, only
// incremented, so scheduleBlock:afterDelay:generation: can detect and ignore stale callbacks.
// unsigned overflow is well-defined (wraps to 0) and still yields a value distinct
// from any in-flight generation, so no overflow guard is needed; reaching NSUIntegerMax would
// also take many years of continous scrolling at one increment per scroll cycle
@property (nonatomic) NSUInteger scrollGeneration;

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
    NSMutableArray<UILabel *> *labels = [[NSMutableArray alloc] initWithCapacity:kLabelCount];

    for (int index = 0; index < kLabelCount; ++index) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = self.autoresizingMask;
        label.isAccessibilityElement = NO;

        // store labels
        [self.scrollView addSubview:label];
        [labels addObject:label];
    }

    self.labels = [labels copy];

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
    self.isAccessibilityElement = YES;
}

- (void)dealloc {
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

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window) {
        [self scrollLabelIfNeeded];
    }
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
    return [self.labels firstObject];
}

- (void)setText:(NSString *)theText {
    [self setText:theText refreshLabels:YES];
}

- (void)setText:(NSString *)theText refreshLabels:(BOOL)refresh {
    // ignore identical text changes
    if ([theText isEqualToString:self.text]) {
        return;
    }

    EACH_LABEL(text, theText)

    if (refresh) {
        [self refreshLabels];
    }
}

- (NSString *)text {
    return self.mainLabel.text;
}

- (void)setAttributedText:(NSAttributedString *)theText {
    [self setAttributedText:theText refreshLabels:YES];
}

- (void)setAttributedText:(NSAttributedString *)theText refreshLabels:(BOOL)refresh {
    // ignore identical text changes
    if ([theText.string isEqualToString:self.attributedText.string]) {
        return;
    }

    EACH_LABEL(attributedText, theText)

    if (refresh) {
        [self refreshLabels];
    }
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
    if (self.mainLabel.font == font) {
        return;
    }

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

- (NSInteger)scrollDirectionValue {
    return self.scrollDirection;
}

- (void)setScrollDirectionValue:(NSInteger)scrollDirectionValue {
    self.scrollDirection = (CBAutoScrollDirection)scrollDirectionValue;
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
    return CGSizeMake(0, [self.mainLabel intrinsicContentSize].height);
}

#pragma mark - Accessibility

- (NSString *)accessibilityLabel {
    return self.text;
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitStaticText;
}

#pragma mark - Scheduling

// invokes action on the main queue after delay; safely no-ops if the receiver has
// already been deallocated by the time the block runs
- (void)scheduleBlock:(void (^)(CBAutoScrollLabel *strongSelf))action afterDelay:(NSTimeInterval)delay {
    __weak typeof(self) weakSelf = self;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));

    dispatch_after(when, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (!strongSelf) {
            return;
        }

        action(strongSelf);
    });
}

// same as scheduleBlock:afterDelay:, but also no-ops if a newer scroll cycle has
// started since this block was scheduled
- (void)scheduleBlock:(void (^)(CBAutoScrollLabel *strongSelf))action afterDelay:(NSTimeInterval)delay generation:(NSUInteger)generation {
    [self scheduleBlock:^(CBAutoScrollLabel *strongSelf) {
        if (strongSelf.scrollGeneration != generation) {
            return;
        }

        action(strongSelf);
    } afterDelay:delay];
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
    if (!self.text.length) {
        return;
    }

    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
    if (labelWidth <= CGRectGetWidth(self.bounds)) {
        return;
    }

    NSUInteger generation = ++self.scrollGeneration;

    [self.scrollView.layer removeAllAnimations];

    BOOL doScrollLeft = (self.scrollDirection == CBAutoScrollDirectionLeft);
    self.scrollView.contentOffset = (doScrollLeft ? CGPointZero : CGPointMake(labelWidth + self.labelSpacing, 0));

    // Add the left shadow after delay
    [self scheduleBlock:^(CBAutoScrollLabel *strongSelf) {
        [strongSelf enableShadow];
    } afterDelay:self.pauseInterval generation:generation];

    // animate the scrolling
    NSTimeInterval duration = labelWidth / self.scrollSpeed;
    [UIView animateWithDuration:duration delay:self.pauseInterval options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
         // adjust offset
         self.scrollView.contentOffset = (doScrollLeft ? CGPointMake(labelWidth + self.labelSpacing, 0) : CGPointZero);
     } completion:^(BOOL finished) {
         self->_scrolling = NO;

         // remove the left shadow
         [self applyGradientMaskForFadeLength:self.fadeLength enableFade:NO];

         // setup pause delay/loop
         if (finished) {
             [self scheduleBlock:^(CBAutoScrollLabel *strongSelf) {
                 [strongSelf scrollLabelIfNeeded];
             } afterDelay:0 generation:generation];
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

// bounds or frame has been changed
- (void)didChangeFrame {
    [self refreshLabels];
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];
}

#pragma mark - Gradient

// ref: https://github.com/cbpowell/MarqueeLabel
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength enableFade:(BOOL)fade {
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);

    if (labelWidth <= CGRectGetWidth(self.bounds)) {
        fadeLength = 0;
    }

    if (!fadeLength) {
        // Remove gradient mask for 0.0f length fade length
        self.layer.mask = nil;
        return;
    }
    
    // Recreate gradient mask with new fade length
    CAGradientLayer *gradientMask = [CAGradientLayer layer];

    gradientMask.bounds = self.layer.bounds;
    gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    gradientMask.shouldRasterize = YES;
    gradientMask.rasterizationScale = [UIScreen mainScreen].scale;

    gradientMask.startPoint = CGPointMake(0, CGRectGetMidY(self.frame));
    gradientMask.endPoint = CGPointMake(1, CGRectGetMidY(self.frame));

    // setup fade mask colors and location
    id transparent = (__bridge id)[UIColor clearColor].CGColor;
    id opaque = (__bridge id)[UIColor blackColor].CGColor;
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
}

#pragma mark - Notifications

- (void)onUIApplicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification {
    // delay to have it re-calculate on next runloop
    [self scheduleBlock:^(CBAutoScrollLabel *strongSelf) {
        [strongSelf refreshLabels];
    } afterDelay:.1f];

    NSUInteger generation = self.scrollGeneration;
    [self scheduleBlock:^(CBAutoScrollLabel *strongSelf) {
        [strongSelf scrollLabelIfNeeded];
    } afterDelay:.1f generation:generation];
}

@end
