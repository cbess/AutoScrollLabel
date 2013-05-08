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
static void each_object(NSArray *objects, void (^block)(id object))
{
    for (id obj in objects)
        block(obj);
}

// shortcut to change each label attribute value
#define EACH_LABEL(ATTR, VALUE) each_object(self.labels, ^(UILabel *label) { label.ATTR = VALUE; });

@interface CBAutoScrollLabel ()

@property (nonatomic, strong) NSArray *labels;
@property (strong, nonatomic, readonly) UILabel *mainLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CBAutoScrollLabel

@synthesize scrollDirection = _scrollDirection;
@synthesize pauseInterval = _pauseInterval;
@synthesize labelSpacing;
@synthesize scrollSpeed = _scrollSpeed;
@synthesize text;
@synthesize labels;
@synthesize mainLabel;
@synthesize animationOptions;
@synthesize shadowColor;
@synthesize shadowOffset;
@synthesize textAlignment;
@synthesize scrolling = _scrolling;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
     	[self commonInit];
    }
    return self;	
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame]))
    {
		[self commonInit];
    }
    return self;
}

- (void)commonInit
{
    // create the labels
    NSMutableSet *labelSet = [[NSMutableSet alloc] initWithCapacity:kLabelCount];
	for (int index = 0 ; index < kLabelCount ; ++index)
    {
		UILabel *label = [[UILabel alloc] init];
		label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = self.autoresizingMask;
        
        // store labels
		[self.scrollView addSubview:label];
        [labelSet addObject:label];
        
        #if ! __has_feature(objc_arc)
        [label release];
        #endif
	}
	
    self.labels = [labelSet.allObjects copy];
    
    #if ! __has_feature(objc_arc)
    [labelSet release];
    #endif
    
    // default values
	_scrollDirection = CBAutoScrollDirectionLeft;
	_scrollSpeed = kDefaultPixelsPerSecond;
	self.pauseInterval = kDefaultPauseTime;
	self.labelSpacing = kDefaultLabelBufferSpace;
    self.textAlignment = UITextAlignmentLeft;
    self.animationOptions = UIViewAnimationOptionCurveEaseIn;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.fadeLength = kDefaultFadeLength;
}

- (void)dealloc 
{
    self.labels = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableShadow) object:nil];
    #if ! __has_feature(objc_arc)
    [super dealloc];
    #endif
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];
}

#pragma mark - Properties

- (UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _scrollView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_scrollView];
        
#if ! __has_feature(objc_arc)
        [_scrollView release];
#endif
    }
    return _scrollView;
}

- (void)setFadeLength:(CGFloat)fadeLength
{
    if (_fadeLength != fadeLength)
    {
        _fadeLength = fadeLength;
        
        [self refreshLabels];
        [self applyGradientMaskForFadeLength:fadeLength enableFade:NO];
    }
}

- (UILabel *)mainLabel
{
    return self.labels[0];
}

- (void)setText:(NSString *)theText
{
    [self setText:theText refreshLabels:YES];
}

- (void)setText:(NSString *)theText refreshLabels:(BOOL)refresh
{
    // ignore identical text changes
	if ([theText isEqualToString:self.text])
		return;
	
    EACH_LABEL(text, theText)
    
    if (refresh)
        [self refreshLabels];
}

- (NSString *)text
{
	return self.mainLabel.text;
}

- (void)setAttributedText:(NSAttributedString *)theText
{
    [self setAttributedText:theText refreshLabels:YES];
}

- (void)setAttributedText:(NSAttributedString *)theText refreshLabels:(BOOL)refresh
{
    // ignore identical text changes
	if ([theText.string isEqualToString:self.attributedText.string])
		return;
	
    EACH_LABEL(attributedText, theText)
    
    if (refresh)
        [self refreshLabels];
}

- (NSAttributedString *)setAttributedText
{
	return self.mainLabel.attributedText;
}

- (void)setTextColor:(UIColor *)color
{
    EACH_LABEL(textColor, color)
}

- (UIColor *)textColor
{
	return self.mainLabel.textColor;
}

- (void)setFont:(UIFont *)font
{
    EACH_LABEL(font, font)
    
	[self refreshLabels];
}

- (UIFont *)font
{
	return self.mainLabel.font;
}

- (void)setScrollSpeed:(float)speed
{
	_scrollSpeed = speed;
    
    [self scrollLabelIfNeeded];
}

- (void)setScrollDirection:(CBAutoScrollDirection)direction
{
	_scrollDirection = direction;
    
    [self scrollLabelIfNeeded];
}

- (void)setShadowColor:(UIColor *)color
{
    EACH_LABEL(shadowColor, color)
}

- (UIColor *)shadowColor
{
    return self.mainLabel.shadowColor;
}

- (void)setShadowOffset:(CGSize)offset
{
    EACH_LABEL(shadowOffset, offset)
}

- (CGSize)shadowOffset
{
    return self.mainLabel.shadowOffset;
}

#pragma mark - Misc

- (void)enableShadow
{
    _scrolling = YES;
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:YES];
}

- (void)scrollLabelIfNeeded
{
    if (!self.text.length)
        return;
    
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
	if (labelWidth <= CGRectGetWidth(self.bounds))
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollLabelIfNeeded) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableShadow) object:nil];
    
    BOOL doScrollLeft = (self.scrollDirection == CBAutoScrollDirectionLeft);
    self.scrollView.contentOffset = (doScrollLeft ? CGPointZero : CGPointMake(labelWidth + self.labelSpacing, 0));
    
    // Add the left shadow after delay
    [self performSelector:@selector(enableShadow) withObject:nil afterDelay:self.pauseInterval];
    
    // animate the scrolling
    NSTimeInterval duration = labelWidth / self.scrollSpeed;
    [UIView animateWithDuration:duration delay:self.pauseInterval options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
        // adjust offset
        self.scrollView.contentOffset = (doScrollLeft ? CGPointMake(labelWidth + self.labelSpacing, 0) : CGPointZero);
    } completion:^(BOOL finished) {
        _scrolling = NO;
        
        // remove the left shadow
        [self applyGradientMaskForFadeLength:self.fadeLength enableFade:NO];
        
        // setup pause delay/loop
        if (finished)
        {
            [self performSelector:@selector(scrollLabelIfNeeded) withObject:nil];
        }
    }];
}

- (void)refreshLabels
{
	__block float offset = 0.0;
	
    // calculate the label size
    CGSize labelSize = [self.mainLabel.text sizeWithFont:self.mainLabel.font
                                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.bounds))];

    each_object(self.labels, ^(UILabel *label) {
        CGRect frame = label.frame;
        frame.origin.x = offset;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.size.width = labelSize.width + 2 /*Magic number*/;
        label.frame = frame;
        
        // Recenter label vertically within the scroll view
        label.center = CGPointMake(label.center.x, roundf(self.center.y - CGRectGetMinY(self.frame)));
        
        offset += CGRectGetWidth(label.bounds) + self.labelSpacing;
    });
    
	self.scrollView.contentOffset = CGPointZero;

	// if the label is bigger than the space allocated, then it should scroll
	if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds) )
    {
        CGSize size;
        size.width = CGRectGetWidth(self.mainLabel.bounds) + CGRectGetWidth(self.bounds) + self.labelSpacing;
        size.height = CGRectGetHeight(self.bounds);
        self.scrollView.contentSize = size;

        EACH_LABEL(hidden, NO)
        
        [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];

		[self scrollLabelIfNeeded];
	}
    else
    {
		// Hide the other labels
        EACH_LABEL(hidden, (self.mainLabel != label))
        
        // adjust the scroll view and main label
        self.scrollView.contentSize = self.bounds.size;
        self.mainLabel.frame = self.bounds;
        self.mainLabel.hidden = NO;
        
        [self applyGradientMaskForFadeLength:0 enableFade:NO];
	}
}

#pragma mark - Gradient

// ref: https://github.com/cbpowell/MarqueeLabel
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength enableFade:(BOOL)fade
{
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
	if (labelWidth <= CGRectGetWidth(self.bounds))
        fadeLength = 0.0;

    if (fadeLength)
    {
        // Recreate gradient mask with new fade length
        CAGradientLayer *gradientMask = [CAGradientLayer layer];
        
        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;
        
        gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(self.frame));

        // setup fade mask colors and location
        id transparent = (id)[UIColor clearColor].CGColor;
        id opaque = (id)[UIColor blackColor].CGColor;
        gradientMask.colors = @[transparent, opaque, opaque, transparent];
        
        // calcluate fade
        CGFloat fadePoint = fadeLength / CGRectGetWidth(self.bounds);
        NSNumber *leftFadePoint = @(fadePoint);
        NSNumber *rightFadePoint = @(1 - fadePoint);
        if (!fade) switch (self.scrollDirection)
        {
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
        
        self.layer.mask = gradientMask;
    }
    else
    {
        // Remove gradient mask for 0.0f lenth fade length
        self.layer.mask = nil;
    }
}

@end
