//
//  Common.m
//  MIO
//
//  Created by Ronny Libardo on 10/8/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "Common.h"

#if DEV
NSString *const APIURL = @"hhttps://miocimar-apimovil-8d8acc4c057f-dev.herokuapp.com";
#else
NSString *const APIURL = @"https://miocimar-apimovil-8d8acc4c057f.herokuapp.com/";
#endif


NSString *const kMIOHeightMeasureUnitKey    = @"MIOHeightMeasureUnitKey";
NSString *const kMIOSpeedMeasureUnitKey     = @"MIOSpeedMeasureUnitKey";
NSString *const kMIOLanguageKey             = @"MIOLanguageKey";
NSString *const kMIONotificationsEnabledKey = @"MIONotificationsEnabledKey";
NSString *const kMIOLanguageModifiedKey     = @"MIOLanguageModifiedKey";

double kMeterMultiplier         = 1.0;
double kFeetMultiplier          = 3.28084;
double kKnotMultiplier          = 0.539957;
double kKilometersMultiplier    = 1.0;

double kFirstWindRange          = 40.7;
double kSecondWindRange         = 29.6;
double kThirdWindRange          = 22.2;

double kFirstWaveRange          = 3.0;
double kSecondWaveRange         = 2.0;
double kThirdWaveRange          = 1.0;

@implementation Common

@end
