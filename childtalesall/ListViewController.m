//
//  ListViewController.m
//  childtalesall
//
//  Created by neko on 29.04.13.
//
//

#import "ListViewController.h"
#import "UICustomCell.h"
#import "Tales.h"
#import "PlaylistContent.h"
#import "PlaylistEditor.h"
#import "MainViewController.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]

@interface ListViewController ()

@end

@implementation ListViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (![SharedAppDelegate.playlists containsObject:[alertView textFieldAtIndex: 0].text]) {
            [SharedAppDelegate.playlists addObject:[alertView textFieldAtIndex: 0].text];
            [SharedAppDelegate.playlistsContent setObject:[NSMutableArray array] forKey:[alertView textFieldAtIndex: 0].text];
            
            PlaylistEditor *ple = [[[PlaylistEditor alloc] initWithStyle:UITableViewStylePlain contentArray:[SharedAppDelegate.playlistsContent objectForKey:[alertView textFieldAtIndex: 0].text] listName:[alertView textFieldAtIndex: 0].text] autorelease];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [[(MainViewController *)[[(UINavigationController *)SharedAppDelegate.window.rootViewController viewControllers] objectAtIndex:0] navigationController] pushViewController:ple animated:YES];
            } else {
                [SharedAppDelegate.controlViewController.navigationController pushViewController:ple animated:YES];
            }
        } else {
            UIAlertView *addFolderAlert = [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Плейлист с таким названием уже существует." delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:nil, nil] autorelease];
            //addFolderAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            addFolderAlert.delegate = nil;
            [addFolderAlert show];
        }
    }
}

- (void)addFolder:(id)sender {
    UIAlertView *addFolderAlert = [[[UIAlertView alloc] initWithTitle:@"Создать плейлист" message:nil delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Готово", nil] autorelease];
    addFolderAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addFolderAlert show];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Плейлисты";
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFolder:)] autorelease];
        [(MainViewController *)[[(UINavigationController *)SharedAppDelegate.window.rootViewController viewControllers] objectAtIndex:0] navigationItem].leftBarButtonItem = addButton;
    } else {
        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFolder:)] autorelease];
        SharedAppDelegate.controlViewController.navigationItem.leftBarButtonItem = addButton;
    }
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
    return [SharedAppDelegate.playlists count];
}

- (UICustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
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
    cell.textLabel.text = [SharedAppDelegate.playlists objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate


// Override to support conditional editing of the table view.
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
        [SharedAppDelegate.playlistsContent removeObjectForKey:[SharedAppDelegate.playlists objectAtIndex:indexPath.row]];
        [SharedAppDelegate.playlists removeObjectAtIndex:indexPath.row];
        NSString *playlistsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/playlists.plist"];
        NSString *downloadsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/playlistContent.plist"];
        
        [SharedAppDelegate.playlists writeToFile:playlistsPath atomically: YES];
        [SharedAppDelegate.playlistsContent writeToFile:downloadsPath atomically: YES];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistContent *detailViewController = [[PlaylistContent alloc] initWithStyle:UITableViewStylePlain contentArray:[SharedAppDelegate.playlistsContent objectForKey:[SharedAppDelegate.playlists objectAtIndex:indexPath.row]] listName:[SharedAppDelegate.playlists objectAtIndex:indexPath.row]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[(MainViewController *)[[(UINavigationController *)SharedAppDelegate.window.rootViewController viewControllers] objectAtIndex:0] navigationController] pushViewController:detailViewController animated:YES];
    } else {
        [SharedAppDelegate.controlViewController.navigationController pushViewController:detailViewController animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [detailViewController release];
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
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"existState = %@", @"NO"];
    [theFetchedResultsController.fetchRequest setPredicate:predicate];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
