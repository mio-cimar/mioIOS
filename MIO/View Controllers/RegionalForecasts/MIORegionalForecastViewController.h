//
//  MIORegionalForecasViewController.h
//  MIO
//
//  Created by Ronny Libardo on 9/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegionalForecastType;
@protocol MIORegionalForecastViewControllerDelegate;

@interface MIORegionalForecastViewController : UIViewController

@property (strong, nonatomic) RegionalForecastType *forecast;
@property (weak, nonatomic) id<MIORegionalForecastViewControllerDelegate> delegate;

@end

@protocol MIORegionalForecastViewControllerDelegate <NSObject>

@required

- (NSArray *)updatedSlidesForRegionalForecastType:(RegionalForecastType *)regionalForecastType;

@end
