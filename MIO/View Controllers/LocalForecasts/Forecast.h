//
//  Forecast.h
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 19/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Forecast : UIView

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
@property (weak, nonatomic) IBOutlet UILabel *waveDirectionText;
@property (weak, nonatomic) IBOutlet UILabel *windDirectionText;

@end
