//
//  ListViewController.h
//  childtalesall
//
//  Created by neko on 29.04.13.
//
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
