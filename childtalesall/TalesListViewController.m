//
//  TalesListViewController.m
//  childtalesall
//
//  Created by neko on 29.04.13.
//
//

#import "TalesListViewController.h"
#import "UICustomCell.h"
#import "Tales.h"
#import "PlayerViewController.h"
#import "MainViewController.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]

@interface TalesListViewController ()

@end

@implementation TalesListViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)reloadTable {
    [[self fetchedResultsController] performFetch:nil];
    [self.tableView reloadData];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error])
        {
            // Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        self.tableView.rowHeight = 60.0;
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = DARK_BACKGROUND_COLOR;
        //        self.tableView.bounces = NO;
        
        UIView *tableFooterView = [[[UIView alloc] init] autorelease];
        tableFooterView.backgroundColor = [UIColor whiteColor];
        tableFooterView.frame = (CGRect) {
            .size.width = self.tableView.frame.size.width,
            .size.height = 1.0f
        };
        self.tableView.tableFooterView = tableFooterView;
        
        
        [self.tableView reloadData];
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Tales *dict = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"music/track%@.mp3", dict.rowNumber]];

        NSFileManager *filemgr;
        
        filemgr = [NSFileManager defaultManager];
        
        [filemgr removeItemAtPath: path error: NULL];
        
        NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
        [request1 setEntity:[NSEntityDescription entityForName:@"Tales" inManagedObjectContext:SharedAppDelegate.managedObjectContext]];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"rowNumber == %@", dict.rowNumber];
        [request1 setPredicate:predicate1];
        
        NSError *error = nil;
        NSArray *results = [SharedAppDelegate.managedObjectContext executeFetchRequest:request1 error:&error];
        [request1 release];
        Tales *tale = [results objectAtIndex:0];
        tale.existState = @"NO";
        [SharedAppDelegate saveContext];
        [[self fetchedResultsController] performFetch:nil];

        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [SharedAppDelegate.dvc reloadTable];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    Tales *dict = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UICustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 20.0)] autorelease];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:14.0];
    timeLabel.text = dict.time;

    if (cell == nil)
    {
        cell = [[[UICustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"] autorelease];
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    cell.textLabel.text = dict.compositionName;
    cell.accessoryView = timeLabel;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    NSMutableArray *tmpArray = [[[NSMutableArray alloc] initWithCapacity:[sectionInfo numberOfObjects]] autorelease];
    for (int i = 0; i < [sectionInfo numberOfObjects]; i++) {
        Tales *dict = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [tmpArray addObject:dict.rowNumber];
    }
    Tales *dict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        SharedAppDelegate.pvc.currentList = tmpArray;
        
        SharedAppDelegate.pvc.currentTrack = dict.rowNumber;
        SharedAppDelegate.pvc.fetchedResultsController = self.fetchedResultsController;
        [SharedAppDelegate.pvc newTrackLoad:dict.rowNumber];
        SharedAppDelegate.pvc.listName = @"nolist";
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [(MainViewController *)[[(UINavigationController *)SharedAppDelegate.window.rootViewController viewControllers] objectAtIndex:0] goPlayer];
        
    } else {
        SharedAppDelegate.mvcp.currentList = tmpArray;
        
        SharedAppDelegate.mvcp.currentTrack = dict.rowNumber;
        SharedAppDelegate.mvcp.fetchedResultsController = self.fetchedResultsController;
        [SharedAppDelegate.mvcp newTrackLoad:dict.rowNumber];
        SharedAppDelegate.mvcp.listName = @"nolist";
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [SharedAppDelegate.mvcp.popover dismissPopoverAnimated:YES];
        //[self goBack];
    }

    // Navigation logic may go here. Create and push another view controller.
    
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
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"existState = %@", @"YES"];
    [theFetchedResultsController.fetchRequest setPredicate:predicate];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
