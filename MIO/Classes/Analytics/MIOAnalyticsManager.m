//
//  MIOAnalyticsManager.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 24/9/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "MIOAnalyticsManager.h"
//@import Firebase;

static int const kGAIDispatchPeriod = 30;

@implementation MIOAnalyticsManager


+ (void)trackScreen:(NSString *)details screenClass: (NSString *)screenClass{
//    [FIRAnalytics setScreenName:details screenClass:screenClass];
}

+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action {
//    [FIRAnalytics logEventWithName:category parameters:@{ kFIRParameterItemName: action}];
}


@end
