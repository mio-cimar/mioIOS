//
//  MIOLocalForecastRegionTableViewCell.h
//  MIO
//
//  Created by Alonso Vega on 6/24/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsyncImageView;

@interface MIOLocalForecastRegionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIView *divider;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end
