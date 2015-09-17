//
//  ArtistTableViewController.h
//  ArtistGallery
//
//  Created by Kashan Qamar on 9/17/15.
//  Copyright (c) 2015 AskNow Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ArtistTableViewController : UITableViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
