//
//  DownloadsViewController.m
//  childtalesall
//
//  Created by neko on 06.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "DownloadsViewController.h"
#import "UICustomCell.h"
#import "Tales.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]

@interface DownloadsViewController ()

@end

@implementation DownloadsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize statusToolbar = _statusToolbar;
@synthesize tableView = _tableView;
@synthesize operations = _operations;
@synthesize searchBar = _searchBar;
@synthesize filteredTableData = _filteredTableData;
@synthesize searching = _searching;

- (void)dealloc {
    [_statusToolbar release];
    [_tableView release];
    [_operations release];
    [super dealloc];
}

- (void)reloadTable {
    if (!self.searching) {
        [[self fetchedResultsController] performFetch:nil];
    } else {
        [self filter:self.searchBar.text];
    }
    [self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didCancelButtonPressed:(KKProgressToolbar *)toolbar {
    self.statusToolbar.statusLabel.text = @"Отмена загрузки...";

    [self.statusToolbar.progressBar setProgress:0.0];
    [self.statusToolbar hide:YES completion:^(BOOL finished) {
        [self.operations removeAllObjects];
        [operation cancel];
        CGRect tableFrame = self.tableView.frame;
        float height = tableFrame.size.height + 44.0;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);
        counter = 0;
        totalCounter = 0;
        [SharedAppDelegate restoreState];
        if (!self.searching) {
            [[self fetchedResultsController] performFetch:nil];
        } else {
            [self filter:self.searchBar.text];
        }
        [self.tableView reloadData];
    }];
}

- (void)startNextDownload:(NSNumber *)fileNumber {
    [self downloadFile:fileNumber];
}

- (void)downloadFile:(NSNumber *)fileNumber {
    counter++;
    self.statusToolbar.statusLabel.text = [NSString stringWithFormat:@"Загрузка сказки %i из %i", counter, totalCounter];

    NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
    [request1 setEntity:[NSEntityDescription entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext]];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"rowNumber == %@", fileNumber];
    [request1 setPredicate:predicate1];
    
    NSError *error = nil;
    NSArray *results = [SharedAppDelegate.managedObjectContext executeFetchRequest:request1 error:&error];
    [request1 release];
    Tales *tale = [results objectAtIndex:0];
    tale.existState = @"Downloading";
    UICustomCell *cell = (UICustomCell *)[self.tableView viewWithTag:[fileNumber intValue]];
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    cell.detailTextLabel.text = @"Загрузка...";

    [SharedAppDelegate saveContext];
    
    if (!self.searching) {
        [[self fetchedResultsController] performFetch:nil];
    } else {
        [self filter:self.searchBar.text];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://077support.com/tales/track%@.mp3", fileNumber]]];
    operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"music/track%@.mp3", fileNumber]];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowNumber == %@", fileNumber];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *results = [SharedAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
        [request release];
        Tales *tale = [results objectAtIndex:0];
        tale.existState = @"YES";
        [SharedAppDelegate saveContext];
        UICustomCell *cell = (UICustomCell *)[self.tableView viewWithTag:[fileNumber intValue]];

        if (cell) {
            if (!self.searching) {
                [[self fetchedResultsController] performFetch:nil];
            } else {
                [self filter:self.searchBar.text];
            }
            cell.accessoryView = nil;

            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            if (!self.searching) {
                [[self fetchedResultsController] performFetch:nil];
            } else {
                [self filter:self.searchBar.text];
            }

            cell.accessoryView = nil;
            [self.tableView reloadData];

        }
        [self.operations removeObjectAtIndex:0];
        if ([self.operations count] != 0) {
            self.statusToolbar.progressBar.progress = 0.0;
            [self startNextDownload:[self.operations objectAtIndex:0]];
        }
        else {
            self.statusToolbar.statusLabel.text = @"Загрузка завершена";
            [self.statusToolbar hide:YES completion:^(BOOL finished) {

                CGRect tableFrame = self.tableView.frame;
                float height = tableFrame.size.height + 44.0;
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);
                counter = 0;
                totalCounter = 0;
                [self.statusToolbar.progressBar setProgress:0.0];

            }];
        }
        [SharedAppDelegate.tvc reloadTable];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UICustomCell *cell = (UICustomCell *)[self.tableView viewWithTag:[fileNumber intValue]];

        NSLog(@"Error: %@", error);
        if (self.operations.count != 0) [self.operations removeObjectAtIndex:0];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowNumber == %@", fileNumber];
        [request setPredicate:predicate];
        
        NSError *error1 = nil;
        NSArray *results = [SharedAppDelegate.managedObjectContext executeFetchRequest:request error:&error1];
        [request release];
        Tales *tale = [results objectAtIndex:0];
        tale.existState = @"NO";
        [SharedAppDelegate saveContext];
        [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationNone];
//        CGRect tableFrame = self.tableView.frame;
//        float height = tableFrame.size.height + 44.0;
//        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);
        counter = 0;
        totalCounter = 0;
        [self.statusToolbar.progressBar setProgress:0.0];
        self.statusToolbar.statusLabel.text = @"Файл не загрузился.";
        if ([self.operations count] != 0) [self startNextDownload:[self.operations objectAtIndex:0]];
        else {
//            [self.statusToolbar hide:YES completion:^(BOOL finished) {
                
//            }];
        }
        
        cell.accessoryView = nil;
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progr = ((float)totalBytesRead / (float)totalBytesExpectedToRead);
        //DACircularProgressView *currentProgressView = (DACircularProgressView *)[cell accessoryView];
        [self.statusToolbar.progressBar setProgress:progr animated:YES];
    }];

    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    cell.accessoryView = activityView;
    [activityView startAnimating];
    
    
    self.statusToolbar.statusLabel.text = [NSString stringWithFormat:@"Загрузка сказки %i из %i", counter, totalCounter];
    [self.statusToolbar show:YES completion:^(BOOL finished) {
        [operation start];
    }];
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setSearching:NO];

        counter = 0;
        totalCounter = 0;
        self.operations = [[[NSMutableArray alloc] init] autorelease];
        
        [[self fetchedResultsController] performFetch:nil];

        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.bounds.size.height) style:UITableViewStylePlain] autorelease];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.rowHeight = 60.0;
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = DARK_BACKGROUND_COLOR;
        //        self.tableView.bounces = NO;
        [self.view addSubview:self.tableView];
        
        UIView *tableFooterView = [[[UIView alloc] init] autorelease];
        tableFooterView.backgroundColor = [UIColor whiteColor];
        tableFooterView.frame = (CGRect) {
            .size.width = self.tableView.frame.size.width,
            .size.height = 1.0f
        };
        self.tableView.tableFooterView = tableFooterView;
        
        
        self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)] autorelease];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        //searchBar.tintColor = [UIColor darkGrayColor];
        self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchBar.delegate = self;
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tableView.tableHeaderView = self.searchBar;
        for (UIView *subview in self.searchBar.subviews)
        {
            if ([subview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                [(UITextField *)subview setClearButtonMode:UITextFieldViewModeWhileEditing];
            }
        }

        [self.tableView reloadData];
    }
    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        bgTask = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }

    CGRect statusToolbarFrame = CGRectMake(0, self.view.frame.size.height, self.view.bounds.size.width, 44);
    self.statusToolbar = [[[KKProgressToolbar alloc] initWithFrame:statusToolbarFrame] autorelease];
    self.statusToolbar.actionDelegate = self;
    [self.statusToolbar.progressBar setProgressTintColor:[UIColor colorWithRed:1.0000 green:0.5951 blue:0.0617 alpha:1.0000]];
    [self.view addSubview:self.statusToolbar];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searching) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        int rowCount = self.filteredTableData.count;
        NSLog(@"%i",rowCount);
        return rowCount;
    }
}

- (UICustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Tales *dict = nil;
    if (!self.searching) {
        dict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        dict = [self.filteredTableData objectAtIndex:indexPath.row];
    }
    
    UICustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 20.0)] autorelease];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:14.0];
    timeLabel.text = dict.time;
    
    if (cell == nil)
    {
        cell = [[[UICustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryView = timeLabel;

    } else {
        cell.accessoryView = timeLabel;

        if ([dict.existState isEqualToString:@"NO"]) {
            cell.detailTextLabel.text = @"";
            cell.userInteractionEnabled = YES;
        } else if ([dict.existState isEqualToString:@"Downloading"]) {
            cell.userInteractionEnabled = NO;
            cell.detailTextLabel.text = @"Загрузка...";
            UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            cell.accessoryView = activityView;
            [activityView startAnimating];
        } else if ([dict.existState isEqualToString:@"Waiting"]) {
            cell.userInteractionEnabled = NO;
            cell.detailTextLabel.text = @"В очереди...";
            UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            cell.accessoryView = activityView;
            activityView.hidesWhenStopped = NO;
            [activityView stopAnimating];
        }
    }
    
    cell.textLabel.text = dict.compositionName;
    cell.tag = [dict.rowNumber intValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void) doBackground:(NSNotification *)aNotification {
    UIApplication *myApp = [UIApplication sharedApplication];
    if ([myApp respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
        bgTask = [myApp beginBackgroundTaskWithExpirationHandler:^{
            // Synchronize the cleanup call on the main thread in case
            // the task actually finishes at around the same time.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (bgTask != UIBackgroundTaskInvalid)
                {
                    [myApp endBackgroundTask:bgTask];
                    bgTask = UIBackgroundTaskInvalid;
                }
            });
        }];
    }
}

-(void)filter:(NSString*)text
{
    self.filteredTableData = [[[NSMutableArray alloc] init] autorelease];
    
    // Create our fetch request
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    
    // Define the entity we are looking for
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Define how we want our entities to be sorted
    NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc]
                                        initWithKey:@"rowNumber" ascending:YES] autorelease];
    NSArray* sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // If we are searching for anything...
    if(text.length > 0)
    {
        // Define how we want our entities to be filtered
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(existState = %@ OR existState = %@ OR existState = %@) AND compositionName CONTAINS[c] %@", @"NO", @"Downloading", @"Waiting", text];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    
    // Finally, perform the load
    NSArray* loadedEntities = [SharedAppDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.filteredTableData = [[[NSMutableArray alloc] initWithArray:loadedEntities] autorelease];
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    [self filter:@""];
    [self setSearching:NO];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self setSearching:YES];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self filter:text];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    totalCounter++;
    self.statusToolbar.statusLabel.text = [NSString stringWithFormat:@"Загрузка сказки %i из %i", counter, totalCounter];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tales *dict = nil;
    if (!self.searching) {
        dict = [self.fetchedResultsController objectAtIndexPath:indexPath];        
    } else {
        dict = [self.filteredTableData objectAtIndex:indexPath.row];
    }

    NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
    [request1 setEntity:[NSEntityDescription entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext]];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"rowNumber == %@", dict.rowNumber];
    [request1 setPredicate:predicate1];
    
    NSError *error = nil;
    NSArray *results = [SharedAppDelegate.managedObjectContext executeFetchRequest:request1 error:&error];
    [request1 release];
    Tales *tale = [results objectAtIndex:0];
    tale.existState = @"Waiting";
    UICustomCell *cell = (UICustomCell *)[self.tableView viewWithTag:[dict.rowNumber intValue]];
    cell.detailTextLabel.text = @"В очереди...";
    cell.userInteractionEnabled = NO;
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    cell.accessoryView = activityView;
    activityView.hidesWhenStopped = NO;
    [activityView stopAnimating];

    [SharedAppDelegate saveContext];
    
    if (!self.searching) {
        [[self fetchedResultsController] performFetch:nil];
    } else {
        [self filter:self.searchBar.text];
    }

    
    
    [self.operations addObject:dict.rowNumber];
    

    if ([self.operations count] == 1) {
        CGRect tableFrame = self.tableView.frame;
        float height = tableFrame.size.height - 44.0;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);

        [self downloadFile:dict.rowNumber];

    }
}


- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"rowNumber" ascending:YES selector:@selector(localizedStandardCompare:)] autorelease];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                         managedObjectContext:SharedAppDelegate.managedObjectContext sectionNameKeyPath:nil
                                                    cacheName:nil] autorelease];
    self.fetchedResultsController = theFetchedResultsController;
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"existState = %@ OR existState = %@ OR existState = %@", @"NO", @"Downloading", @"Waiting"];
    [theFetchedResultsController.fetchRequest setPredicate:predicate];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
