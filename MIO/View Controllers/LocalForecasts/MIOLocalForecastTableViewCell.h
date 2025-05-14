//
//  MIOLocalForecastTableViewCell.h
//  MIO
//
//  Created by Alonso Vega on 7/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIOLocalForecastTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *hour;
@property (nonatomic, strong) IBOutlet UIImageView *windIcon;
@property (nonatomic, strong) IBOutlet UIImageView *windDirection;
@property (nonatomic, strong) IBOutlet UILabel *windSpeed;
@property (nonatomic, strong) IBOutlet UILabel *windBurst;
@property (nonatomic, strong) IBOutlet UIImageView *waveIcon;
@property (nonatomic, strong) IBOutlet UIImageView *waveDirection;
@property (nonatomic, strong) IBOutlet UILabel *waveSignificative;
@property (nonatomic, strong) IBOutlet UILabel *waveMax;
@property (nonatomic, strong) IBOutlet UILabel *wavePeriod;

@end
