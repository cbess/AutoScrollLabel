//
//  AutoScrollLabel.m
//  AutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Updated by Christopher Bess on 2/5/12
//
//  Copyright 2009 Stormy Productions. 
//
//  Permission is granted to use this code free of charge for any project.
//

#import "AutoScrollLabel.h"

#define kLabelCount 2
// pixel buffer space between scrolling label
#define kDefaultLabelBufferSpace 20
#define kDefaultPixelsPerSecond 30
#define kDefaultPauseTime 1.5f

// shortcut method for NSArray iterations
static void each_object(NSArray *objects, void (^block)(id object))
{
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

// shortcut to change each label attribute value
#define EACH_LABEL(ATTR, VALUE) each_object(self.labels, ^(UILabel *label) { label.ATTR = VALUE; });

@interface AutoScrollLabel ()
{
	BOOL _isScrolling;
}
@property (nonatomic, retain) NSArray *labels;
@property (strong, nonatomic, readonly) UILabel *mainLabel;
- (void)commonInit;
@end

@implementation AutoScrollLabel
@synthesize scrollDirection = _scrollDirection;
@synthesize pauseInterval = _pauseInterval;
@synthesize labelSpacing = _labelSpacing;
@synthesize scrollSpeed = _scrollSpeed;
@synthesize text;
@synthesize labels;
@synthesize mainLabel;
@synthesize animationOptions;
@synthesize shadowColor;
@synthesize shadowOffset;
@synthesize textAlignment;
@synthesize scrolling = _isScrolling;

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
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
        
        // store labels
		[self addSubview:label];
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
	_scrollDirection = AutoScrollDirectionLeft;
	_scrollSpeed = kDefaultPixelsPerSecond;
	_pauseInterval = kDefaultPauseTime;
	_labelSpacing = kDefaultLabelBufferSpace;
    self.textAlignment = UITextAlignmentLeft;
    self.animationOptions = UIViewAnimationOptionCurveEaseIn;
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
    self.scrollEnabled = NO;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
}

- (void)dealloc 
{
    self.labels = nil;
    #if ! __has_feature(objc_arc)
    [super dealloc];
    #endif
}

#pragma mark - Properties
- (UILabel *)mainLabel
{
    return [self.labels objectAtIndex:0];
}

- (void)setText:(NSString *)theText
{
    // ignore identical text changes
	if ([theText isEqualToString:self.text])
		return;
	
    EACH_LABEL(text, theText)
    
	[self refreshLabels];
}

- (NSString *)text
{
	return self.mainLabel.text;
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
	[self refreshLabels];
}

- (void)setScrollDirection:(AutoScrollDirection)direction
{
	_scrollDirection = direction;
	[self refreshLabels];
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
- (void)scrollLabelIfNeeded
{
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
	if (labelWidth <= CGRectGetWidth(self.bounds))
        return;
    
	_isScrolling = YES;
    BOOL doScrollLeft = (self.scrollDirection == AutoScrollDirectionLeft);   
    self.contentOffset = (doScrollLeft ? CGPointZero : CGPointMake(labelWidth + _labelSpacing, 0));
    
    // animate the scrolling
    NSTimeInterval duration = labelWidth / self.scrollSpeed;
    [UIView animateWithDuration:duration delay:self.pauseInterval options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
        // adjust offset
        self.contentOffset = (doScrollLeft ? CGPointMake(labelWidth + _labelSpacing, 0) : CGPointZero);
    } completion:^(BOOL finished) {
        _isScrolling = NO;
        
        // setup pause delay/loop
        if (finished)
        {
            [self performSelector:@selector(scrollLabelIfNeeded) withObject:nil];
        }
    }];
}

- (void)refreshLabels
{
	__block float offset = 0;
	
    // calculate the label size
    CGSize labelSize = [self.mainLabel.text sizeWithFont:self.mainLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX, CGRectGetHeight(self.bounds))
                                           lineBreakMode:UILineBreakModeClip];
    
    each_object(self.labels, ^(UILabel *label) {
        CGRect frame = label.frame;
        frame.origin.x = offset;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.size.width = labelSize.width;
        label.frame = frame;
        
        // Recenter label vertically within the scroll view
        label.center = CGPointMake(label.center.x, roundf(self.center.y - CGRectGetMinY(self.frame)));
        
        offset += CGRectGetWidth(label.bounds) + _labelSpacing; 
    });
    
	CGSize size;
	size.width = CGRectGetWidth(self.mainLabel.bounds) + CGRectGetWidth(self.bounds) + _labelSpacing;
	size.height = CGRectGetHeight(self.bounds);
	self.contentSize = size;
	self.contentOffset = CGPointZero;
    
	// If the label is bigger than the space allocated, then it should scroll
	if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds))
    {
        EACH_LABEL(hidden, NO)
        
		[self scrollLabelIfNeeded];
	}
    else
    {
		// Hide the other labels
        EACH_LABEL(hidden, (self.mainLabel != label))
        
        // adjust the scroll view and main label
        self.contentSize = self.bounds.size;
        self.mainLabel.frame = self.bounds;
        self.mainLabel.hidden = NO;
        self.mainLabel.textAlignment = self.textAlignment;
	}
}
@end
