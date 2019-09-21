//
//  Tales.h
//  childtalesall
//
//  Created by neko on 30.04.13.
//  Copyright (c) 2013 Lev Natalya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tales : NSManagedObject

@property (nonatomic, retain) NSString * compositionName;
@property (nonatomic, retain) NSString * existState;
@property (nonatomic, retain) NSNumber * rowNumber;
@property (nonatomic, retain) NSString * time;

@end
