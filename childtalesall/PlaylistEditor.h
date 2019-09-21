//
//  PlaylistEditor.h
//  childtalesall
//
//  Created by neko on 08.05.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistEditor : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSMutableDictionary *playlistContentArray;
}

@property (nonatomic, retain) NSMutableArray *playlistContentArray;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *currentList;
@property (nonatomic, strong) NSMutableDictionary *tempDict;

- (void)reloadTable;
- (id)initWithStyle:(UITableViewStyle)style contentArray:(NSMutableArray *)contentArray listName:(NSString *)listName;

@end
