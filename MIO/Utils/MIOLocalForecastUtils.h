//
//  MIOLocalForecastUtils.h
//  MIO
//
//  Created by Alonso Vega on 7/8/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIOLocalForecastUtils : NSObject

+ (NSString *)imageNameForWaveWithHeight: (NSNumber *)heigth;
+ (NSString *)imageNameForWindWithSpeed:(NSNumber *)speed;

@end
