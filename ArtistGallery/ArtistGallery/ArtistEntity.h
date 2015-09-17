//
//  ArtistEntity.h
//  ArtistGallery
//
//  Created by Kashan Qamar on 9/17/15.
//  Copyright (c) 2015 AskNow Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ArtistEntity : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * genres;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * descriptions;

@end
