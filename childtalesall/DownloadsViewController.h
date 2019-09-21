//
//  DownloadsViewController.h
//  childtalesall
//
//  Created by neko on 06.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKProgressToolbar.h"
#import "AFDownloadRequestOperation.h"

@interface DownloadsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, KKProgressToolbarDelegate, UISearchBarDelegate> {
    UITableView *tableView;
    NSMutableArray *operations;
    KKProgressToolbar *statusToolbar;
    int counter;
    int totalCounter;
    AFHTTPRequestOperation *operation;
    UISearchBar *searchBar;
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) KKProgressToolbar *statusToolbar;
@property (nonatomic, strong) NSMutableArray *operations;
@property (strong, nonatomic) NSMutableArray* filteredTableData;
@property (nonatomic) BOOL searching;
@property (strong, nonatomic) UISearchBar *searchBar;

- (void)reloadTable;

@end
