//
//  ViewController.m
//  ImageFXViewDemo
//
//  Created by Nick Lockwood on 31/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *images;

@end


@implementation ViewController

@synthesize carousel = _carousel;
@synthesize images = _images;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        //self.view.backgroundColor = [UIColor whiteColor];
        //get image paths
        NSArray *imagePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:@"slide_images"];
        //preload images (although FXImageView can actually do this for us on the fly)
        _images = [[NSMutableArray alloc] init];
        for (NSString *path in imagePaths)
        {
            [_images addObject:[UIImage imageWithContentsOfFile:path]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.carousel = [[[iCarousel alloc] initWithFrame:self.view.bounds] autorelease];
	self.carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.carousel.type = iCarouselTypeRotary;
	self.carousel.delegate = self;
	self.carousel.dataSource = self;
    self.carousel.backgroundColor = [UIColor clearColor];
	//add carousel to view
	[self.view addSubview:self.carousel];
}
/*
- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}
*/
- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_images count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
            {
                imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 400.0f, 400.0f)];
            } else {
                imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 270.0f, 270.0f)];
            }

        } else {
                imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 700.0f, 700.0f)];

        }
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            imageView.reflectionAlpha = 0.0f;
        } else {
            imageView.reflectionAlpha = 0.25f;
        }

        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        view = imageView;
    }
    
    //show placeholder
    ((FXImageView *)view).processedImage = [UIImage imageNamed:@"placeholder.png"];
    
    //set image
    ((FXImageView *)view).image = [_images objectAtIndex:index];
    
    return view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [imageView release];
    [_carousel release];
    [_images release];
    [super dealloc];
}

@end
