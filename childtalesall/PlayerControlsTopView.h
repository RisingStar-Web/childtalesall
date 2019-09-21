//
//  PlayerControlsTopView.h
//  childtalesall
//
//  Created by neko on 13.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerControlsTopViewDelegate;

@interface PlayerControlsTopView : UIView {
    UISlider *timeSlider;
    UIButton *shuffleButton;
    UIButton *repeatButton;
    UILabel *timeLeftLabel;
    UILabel *timeRightLabel;
    UILabel *trackNumberLabel;
    id<PlayerControlsTopViewDelegate> delegate;
}

@property (nonatomic,strong) UISlider *timeSlider;
@property (nonatomic,strong) UIButton *shuffleButton;
@property (nonatomic,strong) UIButton *repeatButton;
@property (nonatomic,strong) UILabel *timeLeftLabel;
@property (nonatomic,strong) UILabel *timeRightLabel;
@property (nonatomic,strong) UILabel *trackNumberLabel;
@property (nonatomic, strong) id<PlayerControlsTopViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<PlayerControlsTopViewDelegate>)theDelegate;

@end

@protocol PlayerControlsTopViewDelegate<NSObject>

@required

- (void)sliderAction:(PlayerControlsTopView *)playerControls;
- (void)repeatAction:(PlayerControlsTopView *)playerControls;
- (void)shuffleAction:(PlayerControlsTopView *)playerControls;

@end