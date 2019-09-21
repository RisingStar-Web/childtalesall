//
//  UICustomCell.m
//  supplements
//
//  Created by neko on 26.04.13.
//  Copyright (c) 2013 denisalfa. All rights reserved.
//

#import "UICustomCell.h"

@implementation UICustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
/*        innerView = [[[UIView alloc] init] autorelease];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView = innerView;
  */      // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* backgroundGradientColor = [UIColor colorWithRed: 0.98 green: 0.98 blue: 0.98 alpha: 1];
    UIColor* backgroundGradientColor2 = [UIColor colorWithRed: 0.96 green: 0.96 blue: 0.96 alpha: 1];
    UIColor* backgroundGradientColor3 = [UIColor colorWithRed: 0.94 green: 0.94 blue: 0.94 alpha: 1];
    UIColor* backgroundGradientColor4 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Gradient Declarations
    NSArray* backgroundGradientColors = [NSArray arrayWithObjects:
                                         (id)backgroundGradientColor4.CGColor,
                                         (id)backgroundGradientColor.CGColor,
                                         (id)backgroundGradientColor2.CGColor,
                                         (id)backgroundGradientColor3.CGColor, nil];
    CGFloat backgroundGradientLocations[] = {0, 0.02, 0.98, 1};
    CGGradientRef backgroundGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)backgroundGradientColors, backgroundGradientLocations);
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, self.frame.size.width, 60)];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, backgroundGradient, CGPointMake(160, -0), CGPointMake(160, 60), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(backgroundGradient);
    CGColorSpaceRelease(colorSpace);
}
/*
- (void)layoutSubviews {
    [super layoutSubviews];
            [innerView setFrame: self.contentView.frame];
            
            //        [self.middleLine setFrame:CGRectMake(5.0, self.contentView.frame.size.height - 50.0, self.frame.size.width - 10.0, 1.0)];
            
            CAGradientLayer *colorGradient = [CAGradientLayer layer];
            [colorGradient setFrame:innerView.frame];
            colorGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0000].CGColor, [UIColor colorWithRed:0.9846 green:0.9846 blue:0.9846 alpha:1.0000].CGColor, [UIColor colorWithRed:0.9750 green:0.9827 blue:0.9827 alpha:1.0000].CGColor , nil];
            colorGradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];
            //colorGradient.cornerRadius = 4.0;
            colorGradient.needsDisplayOnBoundsChange = YES;
            [innerView.layer addSublayer:colorGradient];
}
*/
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
