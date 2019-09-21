//
//  PlayerControlsView.m
//  childtalesall
//
//  Created by neko on 13.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "PlayerControlsView.h"

@implementation PlayerControlsView

@synthesize previousTrackButton = _previousTrackButton;
@synthesize nextTrackButton = _nextTrackButton;
@synthesize playPauseButton = _playPauseButton;
@synthesize playState = _playState;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<PlayerControlsViewDelegate>)theDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        controlsView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height / 2.0)] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            controlsView.backgroundColor = [UIColor colorWithRed:0.3882 green:0.4902 blue:0.6235 alpha:1.0000];
        } else {
            controlsView.backgroundColor = [UIColor colorWithRed:0.3882 green:0.4902 blue:0.6235 alpha:0.8000];
        }

        
        controlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:controlsView];
        
        volumeView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height / 2.0, self.frame.size.width, self.frame.size.height / 2.0)] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            volumeView.backgroundColor = [UIColor colorWithRed:0.3397 green:0.4310 blue:0.5519 alpha:1.0000];
        } else {
            volumeView.backgroundColor = [UIColor colorWithRed:0.3882 green:0.4902 blue:0.6235 alpha:0.8000];
        }

        volumeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:volumeView];
        
        MPVolumeView *volumeSlider = [[[MPVolumeView alloc] initWithFrame:CGRectMake(20.0, 12.0, self.frame.size.width - 40.0, 20.0)] autorelease];
        //volumeSlider.showsRouteButton = YES;
        volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [volumeSlider setMinimumTrackTintColor:[UIColor colorWithRed:1.0000 green:0.5951 blue:0.0617 alpha:1.0000]];
//        [volumeSlider setM]
        //[volumeSlider setVolumeThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
        [volumeView addSubview:volumeSlider];

        self.delegate = theDelegate;
        [self setPlayState:NO];
        
        self.previousTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.previousTrackButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.previousTrackButton.frame = CGRectMake(0.0, 0.0, self.frame.size.width / 3, 44.0);
        self.previousTrackButton.showsTouchWhenHighlighted = YES;
        self.previousTrackButton.backgroundColor = [UIColor clearColor];
        UIImage *buttonImageNormal = [UIImage imageNamed:@"previous.png"];
        [self.previousTrackButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.previousTrackButton addTarget:self action:@selector(previousTrackAction:) forControlEvents:UIControlEventTouchUpInside];
        [controlsView addSubview:self.previousTrackButton];

        self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playPauseButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.playPauseButton.frame = CGRectMake(self.previousTrackButton.frame.size.width, 0.0, self.frame.size.width / 3, 44.0);
        self.playPauseButton.backgroundColor = [UIColor clearColor];
        self.playPauseButton.showsTouchWhenHighlighted = YES;
        buttonImageNormal = [UIImage imageNamed:@"play.png"];
        [self.playPauseButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.playPauseButton addTarget:self action:@selector(playPauseAction:) forControlEvents:UIControlEventTouchUpInside];
        [controlsView addSubview:self.playPauseButton];

        self.nextTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nextTrackButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nextTrackButton.frame = CGRectMake(self.previousTrackButton.frame.size.width * 2, 0.0, self.frame.size.width / 3, 44.0);
        self.nextTrackButton.backgroundColor = [UIColor clearColor];
        self.nextTrackButton.showsTouchWhenHighlighted = YES;
        buttonImageNormal = [UIImage imageNamed:@"next.png"];
        [self.nextTrackButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.nextTrackButton addTarget:self action:@selector(nextTrackAction:) forControlEvents:UIControlEventTouchUpInside];
        [controlsView addSubview:self.nextTrackButton];

        // Initialization code
    }
    return self;
}
- (void)playPauseAction {
    [self playPauseAction:self];
}

- (void)playPauseAction:(PlayerControlsView *)playerControls {
    if ([SharedAppDelegate.pvc.currentTrack intValue] != -1) {
        if (self.playState) {
            [self setPlayState:NO];
            UIImage *buttonImageNormal = [UIImage imageNamed:@"play.png"];
            [self.playPauseButton setImage:buttonImageNormal forState:UIControlStateNormal];
        } else {
            [self setPlayState:YES];
            UIImage *buttonImageNormal = [UIImage imageNamed:@"pause.png"];
            [self.playPauseButton setImage:buttonImageNormal forState:UIControlStateNormal];
        }
        [self.delegate playPauseAction:self];
    }
}

- (void)nextTrackAction:(PlayerControlsView *)playerControls {
    [self.delegate nextTrackAction:self];
    
}

- (void)previousTrackAction:(PlayerControlsView *)playerControls {
    [self.delegate previousTrackAction:self];
    
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
