//
//  LocalForecastCell.h
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 20/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Forecast;

@interface LocalForecastCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lblWaveDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblWavePeriod;
@property (weak, nonatomic) IBOutlet UILabel *lblWindDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblWindBurst;
@property (weak, nonatomic) IBOutlet Forecast *firstForecast;
@property (weak, nonatomic) IBOutlet Forecast *secondForecast;
@property (weak, nonatomic) IBOutlet Forecast *thirdForecast;
@property (weak, nonatomic) IBOutlet Forecast *fourthForecast;

@end
