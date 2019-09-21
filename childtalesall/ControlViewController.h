//
//  ControlViewController.h
//  childtalesall
//
//  Created by neko on 29.04.13.
//
//

#import <UIKit/UIKit.h>
#import "AKSegmentedControl.h"
//@class AKSegmentedControl;

@interface ControlViewController : UIViewController {
    AKSegmentedControl *segmentedControl;
}

@property (nonatomic, strong) AKSegmentedControl *segmentedControl;

@end
