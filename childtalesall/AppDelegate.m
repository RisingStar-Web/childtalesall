//
//  AppDelegate.m
//  childtalesall
//
//  Created by neko on 29.04.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "Tales.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize playerViewController = _playerViewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize dvc = _dvc;
@synthesize lvc = _lvc;
@synthesize tvc = _tvc;
@synthesize pvc = _pvc;
@synthesize controlViewController = _controlViewController;
@synthesize playlists = _playlists;
@synthesize playlistsContent = _playlistsContent;
@synthesize navigationController = _navigationController;
@synthesize mvcp = _mvcp;
@synthesize myDevToken;

- (void)dealloc
{
    [_navigationController release];
    [_playlists release];
    [_playlistsContent release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_playerViewController release];
    [_dvc release];
    [_lvc release];
    [_tvc release];
    [_mvcp release];
    [_window release];
    [super dealloc];
}

- (void)playlistInit {
    NSString *downloadsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/playlistContent.plist"];
    BOOL mainList = [[NSFileManager defaultManager] fileExistsAtPath:downloadsPath];
    if (mainList) {
        self.playlistsContent = [[[NSMutableDictionary alloc] initWithContentsOfFile:downloadsPath] autorelease];
    } else {
        self.playlistsContent = [[[NSMutableDictionary alloc] init] autorelease];
    }
    NSString *playlistsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/playlists.plist"];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:playlistsPath];
    if (fileExist) {
        self.playlists = [[[NSMutableArray alloc] initWithContentsOfFile:playlistsPath] autorelease];
    } else {
        self.playlists = [[[NSMutableArray alloc] init] autorelease];
    }
}

- (void)restoreState {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tales" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // Set the predicate -- much like a WHERE statement in a SQL database
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(existState == %@) OR (existState == %@)", @"Waiting", @"Downloading"];
    [request setPredicate:predicate];
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rowNumber" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    NSError *error;
    NSArray *temparray = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([temparray count] != 0) {
        for (int i = 0; i < temparray.count; i++) {
            Tales *tale = [temparray objectAtIndex:i];
            tale.existState = @"NO";
        }
        [self saveContext];
    }
    [request release];
    [sortDescriptor release];
    [sortDescriptors release];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *newFilesString = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/music"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:newFilesString])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:newFilesString withIntermediateDirectories:YES attributes:nil error:nil];
    }

    [self copyDatabaseIfNeeded];
    [self restoreState];
    [self playlistInit];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.pvc = [[[PlayerViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.pvc.view.frame = CGRectMake(0.0, 0.0, self.window.frame.size.width, self.window.frame.size.height);
        [self playerStatesRestore];
        
        self.dvc = [[[DownloadsViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.lvc = [[[ListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        
        self.tvc = [[[TalesListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        
        self.controlViewController = [[[ControlViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.controlViewController.view.frame = CGRectMake(0.0, 0.0, self.window.frame.size.width, self.window.frame.size.height);
        
        MainViewController *mvc = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:mvc] autorelease];
        
        self.window.rootViewController = self.navigationController;
    } else {
        self.dvc = [[[DownloadsViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.lvc = [[[ListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        
        self.tvc = [[[TalesListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        
        self.controlViewController = [[[ControlViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.controlViewController.view.frame = CGRectMake(0.0, 0.0, self.window.frame.size.width, self.window.frame.size.height);

        self.mvcp = [[[MainViewControllerPad alloc] initWithNibName:nil bundle:nil] autorelease];
        [self playerStatesRestorePad];

        self.window.rootViewController = self.mvcp;
    }

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)playerStatesRestore {
    NSString *myPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"talesopt.plist"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    if (fileExists)
    {
        
        NSArray *values = [[NSArray alloc] initWithContentsOfFile:myPath];
        self.pvc.currentList = [values objectAtIndex:0];
        self.pvc.currentTrack = [values objectAtIndex:1];
        self.pvc.shuffleState = [[values objectAtIndex:4] boolValue];
        self.pvc.repeatState = [[values objectAtIndex:3] intValue];
        self.pvc.listName = [values objectAtIndex:5];
        if ([self.pvc.currentTrack intValue] != -1) {

            [self.pvc initRestoredTrack];
        }

        [self.pvc.audioPlayer setCurrentTime: [[values objectAtIndex:2] floatValue]];
        [values release];
    }
    
    else {
        self.pvc.currentTrack = [NSNumber numberWithInt:-1];
        self.pvc.currentList = [NSMutableArray array];
        [self.pvc.audioPlayer setCurrentTime:0.0];
        NSArray *values = [[NSArray alloc] initWithObjects:
                           self.pvc.currentList,
                           self.pvc.currentTrack,
                           [NSNumber numberWithFloat:self.pvc.audioPlayer.currentTime],
                           [NSNumber numberWithInt:0],
                           [NSNumber numberWithBool:NO],
                           @"nolist"
                           ,nil];
        [values writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"talesopt.plist"] atomically:YES];
        [values release];
        
    }

}

- (void)playerStatesRestorePad {
    NSString *myPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"talesopt.plist"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    if (fileExists)
    {
        NSArray *values = [[NSArray alloc] initWithContentsOfFile:myPath];
        self.mvcp.currentList = [values objectAtIndex:0];
        self.mvcp.currentTrack = [values objectAtIndex:1];
        self.mvcp.shuffleState = [[values objectAtIndex:4] boolValue];
        self.mvcp.repeatState = [[values objectAtIndex:3] intValue];
        self.mvcp.listName = [values objectAtIndex:5];
        
        if ([self.mvcp.currentTrack intValue] != -1) {
            
            [self.mvcp initRestoredTrack];
        }
        
        [self.mvcp.audioPlayer setCurrentTime: [[values objectAtIndex:2] floatValue]];
        [values release];
    }
    
    else {
        self.mvcp.currentTrack = [NSNumber numberWithInt:-1];
        self.mvcp.currentList = [NSMutableArray array];
        [self.mvcp.audioPlayer setCurrentTime:0.0];
        NSArray *values = [[NSArray alloc] initWithObjects:
                           self.mvcp.currentList,
                           self.mvcp.currentTrack,
                           [NSNumber numberWithFloat:self.mvcp.audioPlayer.currentTime],
                           [NSNumber numberWithInt:0],
                           [NSNumber numberWithBool:NO],
                           @"nolist"
                           ,nil];
        [values writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"talesopt.plist"] atomically:YES];
        [values release];
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSArray *values = [[NSArray alloc] initWithObjects:
                           self.pvc.currentList,
                           self.pvc.currentTrack,
                           [NSNumber numberWithFloat:self.pvc.audioPlayer.currentTime],
                           [NSNumber numberWithInt:self.pvc.repeatState],
                           [NSNumber numberWithBool:self.pvc.shuffleState],
                           self.pvc.listName
                           ,nil];
        [values writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"talesopt.plist"] atomically:YES];
        [values release];
    } else {
        NSArray *values = [[NSArray alloc] initWithObjects:
                           self.mvcp.currentList,
                           self.mvcp.currentTrack,
                           [NSNumber numberWithFloat:self.mvcp.audioPlayer.currentTime],
                           [NSNumber numberWithInt:self.mvcp.repeatState],
                           [NSNumber numberWithBool:self.mvcp.shuffleState],
                           self.mvcp.listName
                           ,nil];
        [values writeToFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"talesopt.plist"] atomically:YES];
        [values release];
    }
    NSLog(@"States saved sucessed on terminate");

}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tales" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tales.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) copyDatabaseIfNeeded {
	
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getDBPath];
	BOOL success = [fileManager fileExistsAtPath:dbPath];
	
	if(!success) {
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Tales.sqlite"];
		[fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
	}
}

- (NSString *) getDBPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"Tales.sqlite"];
}

- (UIInterfaceOrientationMask) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll;
    return self.fullScreenImage ?
    UIInterfaceOrientationMaskAllButUpsideDown :
    UIInterfaceOrientationMaskPortrait;
}

@end
