//
//  MainViewController.m
//  childtalesall
//
//  Created by neko on 14.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)dealloc {
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"Сказки";

    UIButton *myListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *myListButtonImage = [UIImage imageNamed:@"player.png"];
    myListButton.frame = CGRectMake(0.f, 0.f, 44.f, 44.f);
    [myListButton setBackgroundImage:myListButtonImage forState:UIControlStateNormal];
    myListButton.showsTouchWhenHighlighted = YES;
    [myListButton addTarget:self action:@selector(goPlayer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *playerButton = [[[UIBarButtonItem alloc] initWithCustomView:myListButton] autorelease];
    self.navigationItem.rightBarButtonItem = playerButton;

    [super viewDidLoad];
    
    [self addChildViewController:SharedAppDelegate.controlViewController];
    [SharedAppDelegate.controlViewController didMoveToParentViewController:self];
    
    [self addChildViewController:SharedAppDelegate.pvc];
    [SharedAppDelegate.pvc didMoveToParentViewController:self];
    
    // let's add the first view and update our navigation bar title and the label of the button accordingly
    
    currentChildController = SharedAppDelegate.controlViewController;
    [self.view addSubview:currentChildController.view];
}

- (void)transitionFrom:(UIViewController *)oldController To:(UIViewController *)newController
{
    [self transitionFromViewController:oldController
                      toViewController:newController
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                            }
                            completion:^(BOOL finished){
                                currentChildController = newController;
                            }];
}

- (void)goPlayer
{
    UIViewController *newChildController = nil;
    
    if ([currentChildController isKindOfClass:[ControlViewController class]])
    {
        newChildController = SharedAppDelegate.pvc;
        UIButton *myListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *myListButtonImage;

        myListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myListButtonImage = [UIImage imageNamed:@"list.png"];
        myListButton.frame = CGRectMake(0.f, 0.f, 44.f, 44.f);
        [myListButton setBackgroundImage:myListButtonImage forState:UIControlStateNormal];
        myListButton.showsTouchWhenHighlighted = YES;
        [myListButton addTarget:self action:@selector(goPlayer) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *playerButton = [[[UIBarButtonItem alloc] initWithCustomView:myListButton] autorelease];
        self.navigationItem.rightBarButtonItem = playerButton;

    }
    else if ([currentChildController isKindOfClass:[PlayerViewController class]])
    {
        newChildController = SharedAppDelegate.controlViewController;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
        UIButton *myListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *myListButtonImage = [UIImage imageNamed:@"player.png"];
        myListButton.frame = CGRectMake(0.f, 0.f, 44.f, 44.f);
        [myListButton setBackgroundImage:myListButtonImage forState:UIControlStateNormal];
        myListButton.showsTouchWhenHighlighted = YES;
        [myListButton addTarget:self action:@selector(goPlayer) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *playerButton = [[[UIBarButtonItem alloc] initWithCustomView:myListButton] autorelease];
        self.navigationItem.rightBarButtonItem = playerButton;

    }

    [self transitionFrom:currentChildController To:newChildController];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
