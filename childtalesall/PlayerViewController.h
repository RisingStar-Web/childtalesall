//
//  PlayerViewController.h
//  childtalesall
//
//  Created by neko on 29.04.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerControlsView.h"
#import "PlayerControlsTopView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class ViewController;

@interface PlayerViewController : UIViewController <PlayerControlsViewDelegate, PlayerControlsTopViewDelegate, AVAudioPlayerDelegate, NSFetchedResultsControllerDelegate> {
    PlayerControlsView *playerControlsView;
    PlayerControlsTopView *playerControlsTopView;
    NSArray *currentList;
    UILabel *titleLabel;
    NSNumber *currentTrack;
    
    AVAudioPlayer *audioPlayer;
    MPVolumeView *volumeView;
    NSTimer *sliderTimer;
    BOOL shuffleState;
    int repeatState;
    NSString *listName;
}

@property (nonatomic, strong) NSArray *currentList;
@property (nonatomic, strong) NSNumber *currentTrack;
@property (nonatomic, strong) PlayerControlsView *playerControlsView;
@property (nonatomic, strong) PlayerControlsTopView *playerControlsTopView;
@property (nonatomic, strong) NSTimer *sliderTimer;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BOOL shuffleState;
@property (nonatomic) int repeatState;

@property (nonatomic, strong) ViewController *viewController;

@property (nonatomic, strong) NSString *listName;

- (void)prepareTrack:(NSNumber *)trackNumber;
- (void)newTrackLoad:(NSNumber *)trackNumber;
- (void)initRestoredTrack;

@end
