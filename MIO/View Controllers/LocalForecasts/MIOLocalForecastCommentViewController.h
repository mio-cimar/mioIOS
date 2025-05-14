//
//  MIOLocalForecastCommentViewController.h
//  MIO
//
//  Created by Ronny Libardo on 9/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalForecastRegion;

@interface MIOLocalForecastCommentViewController : UIViewController

@property (strong, nonatomic) NSString *commentContent;
@property (strong, nonatomic) LocalForecastRegion *forecastRegion;
@property (strong, nonatomic) NSDate *validThruStart;
@property (strong, nonatomic) NSDate *validThruEnd;

@end
