//
//  PlayerControlsView.h
//  childtalesall
//
//  Created by neko on 13.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerControlsViewDelegate;

@interface PlayerControlsView : UIView {
    UIButton *previousTrackButton;
    UIButton *nextTrackButton;
    UIButton *playPauseButton;
    BOOL playState;
    id<PlayerControlsViewDelegate> delegate;
    UIView *controlsView;
    UIView *volumeView;
}

@property (nonatomic, strong) UIButton *previousTrackButton;
@property (nonatomic, strong) UIButton *nextTrackButton;
@property (nonatomic, strong) UIButton *playPauseButton;

@property (nonatomic) BOOL playState;

@property (nonatomic, strong) id<PlayerControlsViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<PlayerControlsViewDelegate>)theDelegate;
- (void)playPauseAction;

@end

@protocol PlayerControlsViewDelegate<NSObject>

@required

- (void)playPauseAction:(PlayerControlsView *)playerControls;
- (void)nextTrackAction:(PlayerControlsView *)playerControls;
- (void)previousTrackAction:(PlayerControlsView *)playerControls;

@end