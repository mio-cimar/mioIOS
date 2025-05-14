//
//  MIOTideTableViewCell.h
//  MIO
//
//  Created by Ronny Libardo on 9/24/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIOTideTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIsTideHigh;
@property (weak, nonatomic) IBOutlet UILabel *lblTideTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTideHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imgIsTideHighSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblTideTimeSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblTideHeightSecond;
@property (weak, nonatomic) IBOutlet UIImageView *imgIsTideHighThird;
@property (weak, nonatomic) IBOutlet UILabel *lblTideTimeThird;
@property (weak, nonatomic) IBOutlet UILabel *lblTideHeightThird;
@property (weak, nonatomic) IBOutlet UIImageView *imgIsTideHighFourth;
@property (weak, nonatomic) IBOutlet UILabel *lblTideTimeFourth;
@property (weak, nonatomic) IBOutlet UILabel *lblTideHeightFourth;
@property (weak, nonatomic) IBOutlet UIImageView *imgMoon;
@property (weak, nonatomic) IBOutlet UILabel *lblMoon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cntntMoonImageVerticalAlignment;

@end
