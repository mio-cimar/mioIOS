//
//  ForecastPlayControls.h
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 7/9/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ForecastPlayControlsTriggerType) {
    ForecastPlayControlsTriggerTypeManual,
    ForecastPlayControlsTriggerTypeAutomatic
};

@protocol ForecastPlayControlsDelegate;

@interface ForecastPlayControls : UIView

@property (nonatomic) IBInspectable NSInteger minimun;
@property (nonatomic) IBInspectable NSInteger maximun;
@property (nonatomic) IBInspectable NSInteger playSpeed;
@property (nonatomic) IBInspectable CGFloat playInterval;
@property (nonatomic) IBInspectable BOOL loops;
@property (nonatomic) IBInspectable NSInteger trigger;
@property (weak, nonatomic) id<ForecastPlayControlsDelegate> delegate;

- (void)play;
- (void)stop;
- (void)resume;
- (void)reset;

- (void)setEnabled:(BOOL)enabled;

@end

@protocol ForecastPlayControlsDelegate <NSObject>

@required
- (void)forecastPlayControls:(ForecastPlayControls *)forecastPlayControls triggeredOnPosition:(NSInteger)position triggerType:(ForecastPlayControlsTriggerType)triggerType;

@end
