//
//  AppDelegate.h
//  childtalesall
//
//  Created by neko on 29.04.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

@class PlayerViewController;
@class ControlViewController;

#import <UIKit/UIKit.h>
#import "DownloadsViewController.h"
#import "ListViewController.h"
#import "TalesListViewController.h"
#import "PlayerViewController.h"
#import "ControlViewController.h"
#import "MainViewControllerPad.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSMutableArray *playlists;
    NSMutableDictionary *playlistContent;
    UINavigationController *navigationController;
    ControlViewController *controlViewController;
    UIViewController *someVC;
    MainViewControllerPad *mvcp;
    NSData *myDevToken;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PlayerViewController *playerViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) DownloadsViewController *dvc;
@property (nonatomic, strong) ListViewController *lvc;
@property (nonatomic, strong) TalesListViewController *tvc;
@property (nonatomic, strong) PlayerViewController *pvc;
@property (nonatomic, strong) ControlViewController *controlViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (retain, nonatomic) NSMutableArray *playlists;
@property (retain, nonatomic) NSMutableDictionary *playlistsContent;
@property (nonatomic, strong) MainViewControllerPad *mvcp;
@property (strong, nonatomic) NSData *myDevToken;
@property (nonatomic) BOOL fullScreenImage;

- (NSString *)getDBPath;
- (void)saveContext;
- (void)restoreState;
//- (void)changeController;
//- (void)changeControllerBack;

@end
