//
//  DeviceInformationCell.h
//  nRF Loader
//
//  Created by Ole Morten on 11/6/13.
//  Copyright (c) 2013 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceInformationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rssiImage;

@end
