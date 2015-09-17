//
//  ArtistCustomTableViewCell.h
//  ArtistGallery
//
//  Created by Kashan Qamar on 9/17/15.
//  Copyright (c) 2015 AskNow Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtistCustomTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *artImageView;
@property (nonatomic, weak) IBOutlet UILabel *genereNameLebl;
@property (nonatomic, weak) IBOutlet UILabel *artistName;

@end
