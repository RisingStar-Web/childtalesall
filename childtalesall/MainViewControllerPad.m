//
//  MainViewControllerPad.m
//  childtalesall
//
//  Created by neko on 22.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "MainViewControllerPad.h"
#import "ViewController.h"
#import "Tales.h"

@interface MainViewControllerPad ()

@end

@implementation MainViewControllerPad

@synthesize currentList = _currentList;
@synthesize currentTrack = _currentTrack;
@synthesize audioPlayer = _audioPlayer;
@synthesize playerControlsView = _playerControlsView;
@synthesize playerControlsTopView = _playerControlsTopView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize sliderTimer = _sliderTimer;
@synthesize repeatState = _repeatState;
@synthesize shuffleState = _shuffleState;
@synthesize viewController = _viewController;
@synthesize listName = _listName;
@synthesize cNavController = _cNavController;

- (void)dealloc {
    [_cNavController release];
    [_playerControlsTopView release];
    [_playerControlsView release];
    [_viewController release];
    [super dealloc];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popover = nil;
    [self.popover release];
}

- (void)repeatAction:(PlayerControlsTopView *)playerControls {
    switch (self.repeatState) {
        case 0: {
            UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-on.png"];
            [playerControls.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
            self.repeatState = 1;
        }
            break;
        case 1: {
            UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-1.png"];
            [playerControls.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
            self.repeatState = 2;
            
        }
            break;
        case 2: {
            UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-off.png"];
            [playerControls.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
            self.repeatState = 0;
            
        }
            break;
    }
}

- (void)shuffleAction:(PlayerControlsTopView *)playerControls {
    if (self.shuffleState) {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"shuffle-off.png"];
        [self setShuffleState:NO];
        [playerControls.shuffleButton setImage:buttonImageNormal forState:UIControlStateNormal];
    } else {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"shuffle-on.png"];
        [self setShuffleState:YES];
        [playerControls.shuffleButton setImage:buttonImageNormal forState:UIControlStateNormal];
    }
}

- (void)calculateTimeLabel {
    int durationMinutes = floor((self.audioPlayer.duration - self.audioPlayer.currentTime)/60);
    int durationSeconds = trunc((self.audioPlayer.duration - self.audioPlayer.currentTime) - durationMinutes * 60);
    int currentMinutes = floor(self.audioPlayer.currentTime/60);
    int currentSeconds = trunc(self.audioPlayer.currentTime - currentMinutes * 60);
    self.playerControlsTopView.timeLeftLabel.text = [[[NSString stringWithFormat:@"%i",currentMinutes] stringByAppendingString:@":"] stringByAppendingString:[NSString stringWithFormat:@"%.2i",currentSeconds]];
    self.playerControlsTopView.timeRightLabel.text = [[[NSString stringWithFormat:@"-%i",durationMinutes] stringByAppendingString:@":"] stringByAppendingString:[NSString stringWithFormat:@"%.2i",durationSeconds]];
}

- (void)updateSlider {
    self.playerControlsTopView.timeSlider.value = self.audioPlayer.currentTime;
    [self calculateTimeLabel];
}

- (void)prepareTrack:(NSNumber *)trackNumber {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"music/track%@.mp3", trackNumber]];
    NSString* stringURL = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* file = [NSURL URLWithString:stringURL];
    
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil] autorelease];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    self.playerControlsTopView.timeSlider.maximumValue = self.audioPlayer.duration;
    self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    self.playerControlsTopView.trackNumberLabel.text = [NSString stringWithFormat:@"%i из %i", [self.currentList indexOfObject:self.currentTrack] + 1, [self.currentList count]];
    if ([self.currentTrack intValue] == - 1) self.playerControlsTopView.trackNumberLabel.text = @"";
    
}

- (void)newTrackLoad:(NSNumber *)trackNumber {
    self.playerControlsTopView.timeSlider.value = 0.0;
    self.playerControlsTopView.timeLeftLabel.text = @"0:00";
    self.playerControlsTopView.timeRightLabel.text = @"0:00";
    
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        [self.playerControlsView setPlayState:NO];
        UIImage *buttonImageNormal = [UIImage imageNamed:@"play.png"];
        [self.playerControlsView.playPauseButton setImage:buttonImageNormal forState:UIControlStateNormal];
    }
    [self.playerControlsView setPlayState:YES];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"pause.png"];
    [self.playerControlsView.playPauseButton setImage:buttonImageNormal forState:UIControlStateNormal];
    
    Tales *dict = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[self.currentList indexOfObject:trackNumber] inSection:0]];
    titleLabel.text = dict.compositionName;
    
    [self prepareTrack:trackNumber];
    [self.audioPlayer play];
}

- (void)playPauseAction:(PlayerControlsView *)playerControls {
    if ([self.currentTrack intValue] != -1) {
        if ([self.audioPlayer isPlaying]) {
            [self.audioPlayer pause];
            if (self.sliderTimer) {[self.sliderTimer invalidate]; self.sliderTimer = nil;}
            
        } else {
            self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            [self.audioPlayer play];
        }
        
    }
}

- (void)nextTrackAction:(PlayerControlsView *)playerControls {
    if ([self.currentTrack intValue] == -1) return;
    
    self.playerControlsTopView.timeSlider.userInteractionEnabled = YES;
    
    if (self.sliderTimer) {[self.sliderTimer invalidate]; self.sliderTimer = nil;}
    
    int currentNumber = [self.currentList indexOfObject:self.currentTrack];
    if (self.shuffleState) {
        currentNumber = arc4random() % ([self.currentList count] - 1);
    } else if (currentNumber + 1 == [self.currentList count]) {
        currentNumber = 0;
    } else {
        currentNumber++;
    }
    
    NSNumber *nextTrackNumber = [self.currentList objectAtIndex:currentNumber];
    self.currentTrack = nextTrackNumber;
    [self newTrackLoad:nextTrackNumber];

}

- (void)previousTrackAction:(PlayerControlsView *)playerControls {
    if ([self.currentTrack intValue] == -1) return;
    if (self.sliderTimer) {[self.sliderTimer invalidate]; self.sliderTimer = nil;}
    int currentNumber = [self.currentList indexOfObject:self.currentTrack];
    if (currentNumber == 0) {
        currentNumber = [self.currentList count] - 1;
    } else {
        currentNumber--;
    }
    
    NSNumber *previousTrackNumber = [self.currentList objectAtIndex:currentNumber];
    self.currentTrack = previousTrackNumber;
    [self newTrackLoad:previousTrackNumber];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:0.9294 green:0.9294 blue:0.9294 alpha:1.0000];
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 88.0)];
        topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topView.backgroundColor = [UIColor colorWithRed:0.3397 green:0.4310 blue:0.5519 alpha:1.0000];
        [self.view addSubview:topView];
        
        topView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        topView.layer.shadowRadius = 1.0;
        topView.layer.shadowOpacity = 0.5;
        topView.layer.shadowColor = [UIColor blackColor].CGColor;
        topView.layer.masksToBounds = NO;
        
        self.playerControlsView = [[[PlayerControlsView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 88.0) delegate:self] autorelease];
        self.playerControlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        self.playerControlsView.layer.shadowOffset = CGSizeMake(1.0, 0.0);
        self.playerControlsView.layer.shadowRadius = 1.0;
        self.playerControlsView.layer.shadowOpacity = 1.0;
        self.playerControlsView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.playerControlsView.layer.masksToBounds = NO;

        [topView addSubview:self.playerControlsView];
        
        self.playerControlsTopView = [[[PlayerControlsTopView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 250.0, 0.0, 250.0, 88.0)delegate:self] autorelease];
        self.playerControlsTopView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        self.playerControlsTopView.layer.shadowOffset = CGSizeMake(-1.0, 0.0);
        self.playerControlsTopView.layer.shadowRadius = 1.0;
        self.playerControlsTopView.layer.shadowOpacity = 1.0;
        self.playerControlsTopView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.playerControlsTopView.layer.masksToBounds = NO;
        [topView addSubview:self.playerControlsTopView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.playerControlsTopView.frame.size.width, 0.0, topView.frame.size.width - self.playerControlsTopView.frame.size.width - self.playerControlsView.frame.size.width, 88.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [topView addSubview:titleLabel];
        
        playListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playListButton.frame = CGRectMake(titleLabel.frame.origin.x, 0.0, 44.0, 44.0);
        playListButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [playListButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
        [playListButton addTarget:self action:@selector(showPlaylist:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:playListButton];

        self.viewController = [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.viewController.view.frame = CGRectMake(0.0, 88.0, self.view.frame.size.width, self.view.frame.size.height - 88.0);
        self.viewController.view.backgroundColor = [UIColor clearColor];
        //self.viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.viewController.view];

        // Custom initialization
    }
    return self;
}

- (void)showPlaylist:(id)sender {
//    ControlViewController *cvc = [[[ControlViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:SharedAppDelegate.controlViewController] autorelease];
    //[cNavController.navigationBar setBarStyle:UIBarStyleBlack];
    navController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    navController.navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    navController.navigationBar.layer.shadowRadius = 2.0f;
    navController.navigationBar.layer.shadowOpacity = 0.8f;
    //[cNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.popover = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    [self.popover setPopoverContentSize:CGSizeMake(320, 520)];
    [self.popover presentPopoverFromRect:playListButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    SharedAppDelegate.controlViewController.view.frame = CGRectMake(0.0, 0.0, 320, 520);

    SharedAppDelegate.dvc.view.frame = CGRectMake(0.0, 0.0, 320, 520 - 37.0);
    SharedAppDelegate.dvc.tableView.frame = CGRectMake(0.0, 44.0, 320, 520 - 37 - 44.0);

    SharedAppDelegate.controlViewController.segmentedControl.frame = CGRectMake(0.0, 520.0 - 37.0, SharedAppDelegate.dvc.tableView.frame.size.width, 37.0);
    
    SharedAppDelegate.lvc.view.frame = CGRectMake(0.0, 0.0, 320, 520 - 37.0);
    SharedAppDelegate.lvc.tableView.frame = CGRectMake(0.0, 44.0, 320, 520 - 37 - 44.0);
    SharedAppDelegate.tvc.view.frame = CGRectMake(0.0, 0.0, 320, 520 - 37.0);
    SharedAppDelegate.tvc.tableView.frame = CGRectMake(0.0, 44.0, 320, 520 - 37 - 44.0);

}

- (void)closeAction:(id)sender {
    [self.cNavController.view removeFromSuperview];
    self.cNavController = nil;
}

- (void)sliderAction:(PlayerControlsTopView *)playerControls {
    if ([self.currentTrack intValue] != -1) {
        self.audioPlayer.currentTime = self.playerControlsTopView.timeSlider.value;
        [self calculateTimeLabel];
    } else {
        self.playerControlsTopView.timeSlider.value = 0.0;;
    }
}

- (void)audioPlayerDidFinishPlaying : (AVAudioPlayer *)player successfully : (BOOL)flag {
    if (flag) {
        self.playerControlsTopView.timeLeftLabel.text = @"0:00";
        self.playerControlsTopView.timeRightLabel.text = @"0:00";
        
        self.playerControlsTopView.timeSlider.value = 0.0;
        int currentNumber = [self.currentList indexOfObject:self.currentTrack];
        if (self.repeatState == 2) {
            NSNumber *nextTrackNumber = [self.currentList objectAtIndex:currentNumber];
            self.currentTrack = nextTrackNumber;
            [self newTrackLoad:nextTrackNumber];
        } else if (self.repeatState == 1 && currentNumber + 1 == [self.currentList count]) {
            NSNumber *nextTrackNumber = [self.currentList objectAtIndex:0];
            self.currentTrack = nextTrackNumber;
            [self newTrackLoad:nextTrackNumber];
        } else if (self.repeatState == 0 && currentNumber + 1 == [self.currentList count]) {
            [self.audioPlayer stop];
            self.audioPlayer = nil;
            [self.playerControlsView setPlayState:NO];
            UIImage *buttonImageNormal = [UIImage imageNamed:@"play.png"];
            [self.playerControlsView.playPauseButton setImage:buttonImageNormal forState:UIControlStateNormal];
            self.currentTrack = [self.currentList objectAtIndex:0];
            [self prepareTrack:[self.currentList objectAtIndex:0]];
        } else [self nextTrackAction:self.playerControlsView];
    }
}

- (void)initRestoredTrack {
    [[self fetchedResultsController] performFetch:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"music/track%@.mp3", self.currentTrack]];
    NSString* stringURL = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* file = [NSURL URLWithString:stringURL];
    
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil] autorelease];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    self.playerControlsTopView.timeSlider.maximumValue = self.audioPlayer.duration;
    self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    [self calculateTimeLabel];
    
    if (self.shuffleState) {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"shuffle-on.png"];
        [self.playerControlsTopView.shuffleButton setImage:buttonImageNormal forState:UIControlStateNormal];
    } else {
        UIImage *buttonImageNormal = [UIImage imageNamed:@"shuffle-off.png"];
        [self.playerControlsTopView.shuffleButton setImage:buttonImageNormal forState:UIControlStateNormal];
    }
    
    switch (self.repeatState) {
        case 0: {
            UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-off.png"];
            [self.playerControlsTopView.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
        }
            break;
        case 1: {
            UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-on.png"];
            [self.playerControlsTopView.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
        }
            break;
        case 2: {
            UIImage *buttonImageNormal = [UIImage imageNamed:@"repeat-1.png"];
            [self.playerControlsTopView.repeatButton setImage:buttonImageNormal forState:UIControlStateNormal];
        }
            break;
    }
    if ([self.currentTrack intValue] != - 1) self.playerControlsTopView.trackNumberLabel.text = @"";
    Tales *dict = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[self.currentList indexOfObject:self.currentTrack] inSection:0]];
    titleLabel.text = dict.compositionName;

}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    //    fetchRequest.fetchLimit = fetchLimit;
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"rowNumber" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //[fetchRequest setFetchBatchSize:20];
    
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mainid = %@", self.mainid];
    
    //    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                         managedObjectContext:SharedAppDelegate.managedObjectContext sectionNameKeyPath:nil
                                                    cacheName:nil] autorelease];
    self.fetchedResultsController = theFetchedResultsController;
    
    NSPredicate *predicate = nil;
    
    if ([self.listName isEqualToString:@"nolist"]) {
        predicate =[NSPredicate predicateWithFormat:@"existState = %@", @"YES"];
    } else {
        predicate =[NSPredicate predicateWithFormat:@"rowNumber IN %@", [SharedAppDelegate.playlistsContent objectForKey:self.listName]];
    }
    [theFetchedResultsController.fetchRequest setPredicate:predicate];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    self.playerControlsTopView.trackNumberLabel.text = [NSString stringWithFormat:@"%i из %i", [self.currentList indexOfObject:self.currentTrack] + 1, [self.currentList count]];
    if ([self.currentTrack intValue] == - 1) self.playerControlsTopView.trackNumberLabel.text = @"";
	[super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.viewController.view removeFromSuperview];
        self.viewController = [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.viewController.view.frame = CGRectMake(0.0, 88.0, 1024.0, 748.0 - 88.0);
        self.viewController.view.backgroundColor = [UIColor whiteColor];
        //self.viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:self.viewController.view];
    } else {
        [self.viewController.view removeFromSuperview];
        self.viewController = [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.viewController.view.frame = CGRectMake(0.0, 88.0, 768.0, 1004 - 88.0);
        self.viewController.view.backgroundColor = [UIColor whiteColor];
        //self.viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:self.viewController.view];
    }

}
*/
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self.playerControlsView playPauseAction];
        }  else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self previousTrackAction:self.playerControlsView];
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self nextTrackAction:self.playerControlsView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
