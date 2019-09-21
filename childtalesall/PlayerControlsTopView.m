//
//  PlayerControlsTopView.m
//  childtalesall
//
//  Created by neko on 13.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "PlayerControlsTopView.h"

@implementation PlayerControlsTopView

@synthesize timeSlider = _timeSlider;
@synthesize shuffleButton = _shuffleButton;
@synthesize repeatButton = _repeatButton;
@synthesize timeLeftLabel = _timeLeftLabel;
@synthesize timeRightLabel = _timeRightLabel;
@synthesize trackNumberLabel = _trackNumberLabel;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<PlayerControlsTopViewDelegate>)theDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.3882 green:0.4902 blue:0.6235 alpha:0.8000];
        
        self.delegate = theDelegate;

        self.trackNumberLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, self.frame.size.width, 20.0)] autorelease];
        self.trackNumberLabel.backgroundColor = [UIColor clearColor];
        self.trackNumberLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.trackNumberLabel.textColor = [UIColor whiteColor];
        self.trackNumberLabel.textAlignment = NSTextAlignmentCenter;
        self.trackNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.trackNumberLabel];

        self.timeLeftLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, 50.0, 15.0)] autorelease];
        self.timeLeftLabel.backgroundColor = [UIColor clearColor];
        self.timeLeftLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.timeLeftLabel.textColor = [UIColor whiteColor];
        self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLeftLabel];
        
        self.timeRightLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0, 30.0, 50.0, 15.0)] autorelease];
        self.timeRightLabel.backgroundColor = [UIColor clearColor];
        self.timeRightLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.timeRightLabel.textColor = [UIColor whiteColor];
        self.timeRightLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.timeRightLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeRightLabel];
        
        self.timeSlider = [[[UISlider alloc] initWithFrame:CGRectMake(50.0, 25.0, self.frame.size.width - 100.0, 20.0)] autorelease];
        self.timeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.timeSlider setMinimumTrackTintColor:[UIColor colorWithRed:1.0000 green:0.5951 blue:0.0617 alpha:1.0000]];
        [self.timeSlider setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
        [self.timeSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

        [self addSubview:self.timeSlider];
        
        self.repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.repeatButton.frame = CGRectMake(0.0, 40.0, 50.0, 40.0);
        self.repeatButton.showsTouchWhenHighlighted = YES;
        self.repeatButton.backgroundColor = [UIColor clearColor];
        UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-off.png"];
        [self.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.repeatButton addTarget:self action:@selector(repeatAction:) forControlEvents:UIControlEventTouchUpInside];
        //self.repeatButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.repeatButton];

        self.shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shuffleButton.frame = CGRectMake(self.frame.size.width - 50.0, 40.0, 50.0, 40.0);
        self.shuffleButton.backgroundColor = [UIColor clearColor];
        self.shuffleButton.showsTouchWhenHighlighted = YES;
        buttonImageNormal = [UIImage imageNamed:@"shuffle-off.png"];
        [self.shuffleButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.shuffleButton addTarget:self action:@selector(shuffleAction:) forControlEvents:UIControlEventTouchUpInside];
        self.shuffleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.shuffleButton];

        
        // Initialization code
    }
    return self;
}

- (void)repeatAction:(PlayerControlsTopView *)playerControls {
    [self.delegate repeatAction:self];
}

- (void)shuffleAction:(PlayerControlsTopView *)playerControls {
    [self.delegate shuffleAction:self];
}

- (void)sliderAction:(PlayerControlsTopView *)playerControls {
    [self.delegate sliderAction:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
