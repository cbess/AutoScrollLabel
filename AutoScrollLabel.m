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
#define kDefaultLabelBufferSpace 20   // pixel buffer space between scrolling label
#define kDefaultPixelsPerSecond 30
#define kDefaultPauseTime 1.5f

// shortcut method for NSArray iterations
static void each_object(NSArray *objects, void (^block)(id object))
{
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

@interface AutoScrollLabel ()
{
	bool _isScrolling;
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
        NSRelease(label)
	}
	
    self.labels = [labelSet.allObjects copy];
    NSRelease(labelSet)
    
    // default values
	_scrollDirection = AutoScrollDirectionLeft;
	_scrollSpeed = kDefaultPixelsPerSecond;
	_pauseInterval = kDefaultPauseTime;
	_labelSpacing = kDefaultLabelBufferSpace;
    self.textAlignment = UITextAlignmentLeft;
    self.animationOptions = UIViewAnimationCurveEaseIn;
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
    NO_ARC([super dealloc]);
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
	
    each_object(self.labels, ^(UILabel *label) {
        label.text = theText;
	});
    
	[self refreshLabels];
}

- (NSString *)text
{
	return self.mainLabel.text;
}

- (void)setTextColor:(UIColor *)color
{
    each_object(self.labels, ^(UILabel *label) {
        label.textColor = color;
	});
}

- (UIColor *)textColor
{
	return self.mainLabel.textColor;
}

- (void)setFont:(UIFont *)font
{
    each_object(self.labels, ^(UILabel *label) {
		label.font = font;
	});
    
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
    each_object(self.labels, ^(UILabel *label) {
        label.shadowColor = color;
    });
}

- (UIColor *)shadowColor
{
    return self.mainLabel.shadowColor;
}

- (void)setShadowOffset:(CGSize)offset
{
    each_object(self.labels, ^(UILabel *label) {
        label.shadowOffset = offset;
    });
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
    [UIView animateWithDuration:duration delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
        // adjust offset
        self.contentOffset = (doScrollLeft ? CGPointMake(labelWidth + _labelSpacing, 0) : CGPointZero);
    } completion:^(BOOL finished) {
        _isScrolling = NO;
        
        // setup pause delay/loop
        if (finished)
        {
            [self performSelector:@selector(scrollLabelIfNeeded) 
                       withObject:nil
                       afterDelay:self.pauseInterval];
        }
    }];
}

- (void)refreshLabels
{
	__block float offset = 0;
	
    // calculate the label size
    CGSize labelSize = [self.mainLabel.text sizeWithFont:self.mainLabel.font
                                       constrainedToSize:CGSizeMake(9999, CGRectGetHeight(self.bounds))
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
        each_object(self.labels, ^(UILabel *label) {
            label.hidden = NO;
		});
        
		[self scrollLabelIfNeeded];
	}
    else
    {
		// Hide the other labels out of view
		each_object(self.labels, ^(UILabel *label) {
            if (self.mainLabel != label)
                label.hidden = YES;
		});
        
        // adjust the scroll view
        self.contentSize = self.bounds.size;
        
		// adjust label alignment
        switch (self.textAlignment)
        {
            case UITextAlignmentCenter:
                self.mainLabel.center = CGPointMake(self.center.x, CGRectGetMidY(self.bounds));
                break;
                
            case UITextAlignmentLeft:
                self.mainLabel.frame = self.bounds;
                break;
                
            default:
                //TODO: implement right alignment support
                break;
        }
        
        self.mainLabel.hidden = NO;
	}
}
@end
