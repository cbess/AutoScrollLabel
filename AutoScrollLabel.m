//
//  AutoScrollLabel.m
//  AutoScrollLabel
//
//  Created by Brian Stormont on 10/21/09.
//  Copyright 2009 Stormy Productions. 
//
//  Permission is granted to use this code free of charge for any project.
//

#import "AutoScrollLabel.h"

#define LABEL_BUFFER_SPACE 20   // pixel buffer space between scrolling label
#define DEFAULT_PIXELS_PER_SECOND 30
#define DEFAULT_PAUSE_TIME 0.5f

@implementation AutoScrollLabel
@synthesize pauseInterval;
@synthesize bufferSpaceBetweenLabels;

- (void) commonInit
{
	for (int i=0; i< NUM_LABELS; ++i){
		label[i] = [[UILabel alloc] init];
		label[i].textColor = [UIColor whiteColor];
		label[i].backgroundColor = [UIColor clearColor];
		[self addSubview:label[i]];
	}
	
	scrollDirection = AUTOSCROLL_SCROLL_LEFT;
	scrollSpeed = DEFAULT_PIXELS_PER_SECOND;
	pauseInterval = DEFAULT_PAUSE_TIME;
	bufferSpaceBetweenLabels = LABEL_BUFFER_SPACE;
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.userInteractionEnabled = NO;
}

-(id) init
{
	if (self = [super init]){
        // Initialization code
		[self commonInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
		[self commonInit];
    }
    return self;
	
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		[self commonInit];
    }
    return self;
}


#if 0
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[NSThread sleepForTimeInterval:pauseInterval];

	isScrolling = NO;
	
	if ([finished intValue] == 1 && label[0].frame.size.width > self.frame.size.width){
		[self scroll];
	}	
}
#else
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	isScrolling = NO;

	if ([finished intValue] == 1 && label[0].frame.size.width > self.frame.size.width){
		[NSTimer scheduledTimerWithTimeInterval:pauseInterval target:self selector:@selector(scroll) userInfo:nil repeats:NO];
	}
} 
#endif


- (void) scroll
{
	// Prevent multiple calls
	if (isScrolling){
//		return;
	}
	isScrolling = YES;
	
	if (scrollDirection == AUTOSCROLL_SCROLL_LEFT){
		self.contentOffset = CGPointMake(0,0);
	}else{
		self.contentOffset = CGPointMake(label[0].frame.size.width+LABEL_BUFFER_SPACE,0);
	}
	
	[UIView beginAnimations:@"scroll" context:nil];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:label[0].frame.size.width/(float)scrollSpeed];
	
	if (scrollDirection == AUTOSCROLL_SCROLL_LEFT){
		self.contentOffset = CGPointMake(label[0].frame.size.width+LABEL_BUFFER_SPACE,0);
	}else{
		self.contentOffset = CGPointMake(0,0);
	}		
	
	[UIView commitAnimations];
}


- (void) readjustLabels
{
	float offset = 0.0f;
	
	for (int i = 0; i < NUM_LABELS; ++i){
		[label[i] sizeToFit];
		
		// Recenter label vertically within the scroll view
		CGPoint center;
		center = label[i].center;
		center.y = self.center.y - self.frame.origin.y;
		label[i].center = center;
		
		CGRect frame;
		frame = label[i].frame;
		frame.origin.x = offset;
		label[i].frame = frame;
		
		offset += label[i].frame.size.width + LABEL_BUFFER_SPACE;
	}
	
	CGSize size;
	size.width = label[0].frame.size.width + self.frame.size.width + LABEL_BUFFER_SPACE;
	size.height = self.frame.size.height;
	self.contentSize = size;

	[self setContentOffset:CGPointMake(0,0) animated:NO];
	
	// If the label is bigger than the space allocated, then it should scroll
	if (label[0].frame.size.width > self.frame.size.width){
		for (int i = 1; i < NUM_LABELS; ++i){
			label[i].hidden = NO;
		}
		[self scroll];
	}else{
		// Hide the other labels out of view
		for (int i = 1; i < NUM_LABELS; ++i){
			label[i].hidden = YES;
		}
		// Center this label
		CGPoint center;
		center = label[0].center;
		center.x = self.center.x - self.frame.origin.x;
		label[0].center = center;
	}

}


- (void) setText: (NSString *) text
{
	// If the text is identical, don't reset it, otherwise it causes scrolling jitter
	if ([text isEqualToString:label[0].text]){
		// But if it isn't scrolling, make it scroll
		// If the label is bigger than the space allocated, then it should scroll
		if (label[0].frame.size.width > self.frame.size.width){
			[self scroll];
		}
		return;
	}
	
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].text = text;
	}
	[self readjustLabels];
}	
- (NSString *) text
{
	return label[0].text;
}


- (void) setTextColor:(UIColor *)color
{
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].textColor = color;
	}
}

- (UIColor *) textColor
{
	return label[0].textColor;
}


- (void) setFont:(UIFont *)font
{
	for (int i=0; i<NUM_LABELS; ++i){
		label[i].font = font;
	}
	[self readjustLabels];
}

- (UIFont *) font
{
	return label[0].font;
}


- (void) setScrollSpeed: (float)speed
{
	scrollSpeed = speed;
	[self readjustLabels];
}

- (float) scrollSpeed
{
	return scrollSpeed;
}

- (void) setScrollDirection: (enum AutoScrollDirection)direction
{
	scrollDirection = direction;
	[self readjustLabels];
}

- (enum AutoScrollDirection) scrollDirection
{
	return scrollDirection;
}

- (void)dealloc {
	for (int i=0; i<NUM_LABELS; ++i){
		[label[i] release];
	}
    [super dealloc];
}


@end
