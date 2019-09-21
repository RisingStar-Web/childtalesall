//
//  ControlViewController.m
//  childtalesall
//
//  Created by neko on 29.04.13.
//
//

#import "ControlViewController.h"
#import "ListViewController.h"
#import "TalesListViewController.h"
#import "AKSegmentedControl.h"

@interface ControlViewController () {

}

@end

@implementation ControlViewController

@synthesize segmentedControl = _segmentedControl;

- (void)dealloc {
    [_segmentedControl release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.segmentedControl = [[[AKSegmentedControl alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - 37.0, self.view.frame.size.width, 37.0)] autorelease];

        [self.segmentedControl addTarget:self action:@selector(segmentedViewController:) forControlEvents:UIControlEventValueChanged];
        [self.segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
        [self.segmentedControl setBackgroundColor:[UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]];
        
        SharedAppDelegate.dvc.view.frame = CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height - self.segmentedControl.frame.size.height - 64.0);
        SharedAppDelegate.dvc.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        SharedAppDelegate.lvc.view.frame = CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height - self.segmentedControl.frame.size.height - 64.0);
        SharedAppDelegate.lvc.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        SharedAppDelegate.tvc.view.frame = CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height - self.segmentedControl.frame.size.height - 64.0);
        SharedAppDelegate.tvc.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        [self setupSegmentedControl];
        [self updateOnSegmentChange];

        // Custom initialization
    
    }
    return self;
}

- (void)setupSegmentedControl
{
    [self.segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
    [self.segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.segmentedControl setSegmentedControlMode:AKSegmentedControlModeSticky];
    [self.segmentedControl setSelectedIndex:1];
//    self.navBar.topItem.title = @"Сказки";

    [self.segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"segmented-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    [self.segmentedControl setBackgroundImage:backgroundImage];
    [self.segmentedControl setContentEdgeInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
    [self.segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    
    [self.segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    UIImage *buttonBackgroundImagePressedLeft = [[UIImage imageNamed:@"segmented-bg-pressed-left.png"]
                                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 1.0)];
    UIImage *buttonBackgroundImagePressedCenter = [[UIImage imageNamed:@"segmented-bg-pressed-center.png"]
                                                   resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 1.0)];
    UIImage *buttonBackgroundImagePressedRight = [[UIImage imageNamed:@"segmented-bg-pressed-right.png"]
                                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 4.0)];
    // Button 1
    UIButton *buttonSocial = [[[UIButton alloc] init] autorelease];
    [buttonSocial setBackgroundImage:buttonBackgroundImagePressedLeft forState:UIControlStateHighlighted];
    [buttonSocial setBackgroundImage:buttonBackgroundImagePressedLeft forState:UIControlStateSelected];
    [buttonSocial setBackgroundImage:buttonBackgroundImagePressedLeft forState:(UIControlStateHighlighted|UIControlStateSelected)];

    [buttonSocial setTitle:@"Загрузки" forState:UIControlStateNormal];
    [buttonSocial setTitleColor:[UIColor colorWithRed:82.0/255.0 green:113.0/255.0 blue:131.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [buttonSocial setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSocial.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [buttonSocial.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
    [buttonSocial setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    
    // Button 2
    UIButton *buttonStar = [[[UIButton alloc] init] autorelease];
    [buttonStar setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateHighlighted];
    [buttonStar setBackgroundImage:buttonBackgroundImagePressedCenter forState:UIControlStateSelected];
    [buttonStar setBackgroundImage:buttonBackgroundImagePressedCenter forState:(UIControlStateHighlighted|UIControlStateSelected)];

    [buttonStar setTitle:@"Сказки" forState:UIControlStateNormal];
    [buttonStar setTitleColor:[UIColor colorWithRed:82.0/255.0 green:113.0/255.0 blue:131.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [buttonStar setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonStar.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [buttonStar.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
    [buttonStar setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    
    // Button 3
    UIButton *buttonSettings = [[[UIButton alloc] init] autorelease];
    [buttonSettings setBackgroundImage:buttonBackgroundImagePressedRight forState:UIControlStateHighlighted];
    [buttonSettings setBackgroundImage:buttonBackgroundImagePressedRight forState:UIControlStateSelected];
    [buttonSettings setBackgroundImage:buttonBackgroundImagePressedRight forState:(UIControlStateHighlighted|UIControlStateSelected)];

    [buttonSettings setTitle:@"Плейлист" forState:UIControlStateNormal];
    [buttonSettings setTitleColor:[UIColor colorWithRed:82.0/255.0 green:113.0/255.0 blue:131.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [buttonSettings setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSettings.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [buttonSettings.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0]];
    [buttonSettings setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
    
    [self.segmentedControl setButtonsArray:@[buttonSocial, buttonStar, buttonSettings]];
    [self.view addSubview:self.segmentedControl];
}

- (void)updateOnSegmentChange {
    for (UIView *view in [self.view subviews])
    {
        if (![view isKindOfClass:[AKSegmentedControl class]] && ![view isKindOfClass:[UINavigationBar class]]) [view removeFromSuperview];
    }
    switch ([self.segmentedControl selectedIndexes].lastIndex) {
        case 0:
            [self.view insertSubview:SharedAppDelegate.dvc.view belowSubview:self.segmentedControl];
            self.parentViewController.title = @"Загрузки";
            self.parentViewController.navigationItem.leftBarButtonItem = nil;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                SharedAppDelegate.controlViewController.navigationItem.leftBarButtonItem = nil;
            }

            break;
        case 1:
            [self.view insertSubview:SharedAppDelegate.tvc.view belowSubview:self.segmentedControl];
            self.parentViewController.title = @"Сказки";
            self.parentViewController.navigationItem.leftBarButtonItem = nil;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                SharedAppDelegate.controlViewController.navigationItem.leftBarButtonItem = nil;
            }
            break;
        case 2:
            [self.view insertSubview:SharedAppDelegate.lvc.view belowSubview:self.segmentedControl];
            self.parentViewController.title = @"Плейлисты";
            break;
            
        default:
            break;
    }
}

- (void)segmentedViewController:(id)sender
{
    [self updateOnSegmentChange];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    SharedAppDelegate.fullScreenImage = FALSE;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
