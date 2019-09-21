//
//  PlaylistEditor.m
//  childtalesall
//
//  Created by neko on 08.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "PlaylistEditor.h"
#import "UICustomCell.h"
#import "Tales.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]

@interface PlaylistEditor ()

@end

@implementation PlaylistEditor

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize playlistContentArray = _playlistContentArray;

- (void)dealloc {
    [_playlistContentArray release];
    [super dealloc];
}

- (void)reloadTable {
    [[self fetchedResultsController] performFetch:nil];
    [self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)doneAction:(id)sender {
    
    NSString *playlistsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/playlists.plist"];
    NSString *downloadsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/playlistContent.plist"];
    
    [SharedAppDelegate.playlists writeToFile:playlistsPath atomically: YES];
    [self.tempDict writeToFile:downloadsPath atomically: YES];
    [SharedAppDelegate.lvc.tableView reloadData];
//    ListViewController *lvc = (ListViewController *)[[(UINavigationController *)self.parentViewController viewControllers] objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
/*    [lvc.tableView beginUpdates];
    [lvc.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[SharedAppDelegate.playlists count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [lvc.tableView endUpdates];
*/
}

- (void)cancelAction:(id)sender {
    NSString *className = [NSString stringWithFormat:@"%@",[[[(UINavigationController *)self.parentViewController viewControllers] objectAtIndex:0] class]];
    if ([className isEqualToString:@"ListViewController"]) {
        [SharedAppDelegate.playlists removeObject:self.currentList];
        [self.tempDict removeObjectForKey:self.currentList];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style contentArray:(NSMutableArray *)contentArray listName:(NSString *)listName
{
    self = [super initWithStyle:style];
    if (self) {
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];

        UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];

        self.navigationItem.rightBarButtonItem = doneButton;
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        self.tempDict = SharedAppDelegate.playlistsContent;
        self.currentList = listName;
        self.playlistContentArray = contentArray;
        self.title = listName;
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    Tales *dict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UICustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];


    if (cell == nil)
    {
        cell = [[[UICustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"] autorelease];
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.backgroundColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    UIImageView *statusImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.f, 30.f)];
    if ([self.playlistContentArray containsObject:dict.rowNumber]) {
        statusImage.image = [UIImage imageNamed:@"checkBox.png"];
    } else {
        statusImage.image = [UIImage imageNamed:@"checkBoxEmpty.png"];
    }
    cell.accessoryView = statusImage;
    [statusImage release];

    cell.textLabel.text = dict.compositionName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //cell.accessoryView = statusImage;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tales *dict = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *statusImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.f, 30.f)] autorelease];
    if ([self.playlistContentArray containsObject:dict.rowNumber]) {
        [[self.tempDict objectForKey:self.currentList] removeObject:dict.rowNumber];
        statusImage.image = [UIImage imageNamed:@"checkBoxEmpty.png"];
    } else {
        [[self.tempDict objectForKey:self.currentList] addObject:dict.rowNumber];
        statusImage.image = [UIImage imageNamed:@"checkBox.png"];
    }
    cell.accessoryView = statusImage;
    //[(UIImageView *)[cell.accessoryView.subviews objectAtIndex:0] setImage:statusImage.image];

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
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
