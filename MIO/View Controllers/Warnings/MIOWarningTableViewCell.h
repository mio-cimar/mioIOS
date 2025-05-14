//
//  MIOWarningTableViewCell.h
//  MIO
//
//  Created by Ronny Libardo on 9/14/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIOWarningTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *warningImage;
@property (weak, nonatomic) IBOutlet UILabel *warningTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningDateLabel;

@end
