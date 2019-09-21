//
//  TalesListViewController.h
//  childtalesall
//
//  Created by neko on 29.04.13.
//
//

#import <UIKit/UIKit.h>

@interface TalesListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)reloadTable;

@end
