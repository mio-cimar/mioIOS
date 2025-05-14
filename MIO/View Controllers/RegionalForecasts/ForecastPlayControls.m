//
//  ForecastPlayControls.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 7/9/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "ForecastPlayControls.h"

@interface ForecastPlayControls ()

@property (strong, nonatomic) IBOutlet UIView *content;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIImageView *rewindImage;
@property (weak, nonatomic) IBOutlet UIButton *playPause;
@property (weak, nonatomic) IBOutlet UIImageView *forwardImage;
@property (weak, nonatomic) IBOutlet UIImageView *playPauseImage;
@end

@implementation ForecastPlayControls

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.slider.minimumValue    = 0;
    self.slider.maximumValue    = 1;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ForecastPlayControls class]) owner:self options:nil];
        CGRect frame            = self.frame;
        
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }
    
    return self;
}

- (void)setMaximun:(NSInteger)maximun {
    _maximun                    = maximun;
    self.slider.minimumValue = 0;
    self.slider.maximumValue    = maximun;
    
    [self.slider setValue:0];
}

- (IBAction)rewind:(UIButton *)sender {
    [self pause];
    
    if (self.slider.value > self.minimun) {
        CGFloat remainder   = ((int)self.slider.value % (int)self.trigger);
        CGFloat rewindValue = 0;
        
        if (remainder != 0) {
            rewindValue = self.slider.value - remainder;
        }
        else {
            rewindValue = self.slider.value - self.trigger;
        }
        
        [self.slider setValue:rewindValue animated:YES];
        [self triggerFromPosition:(int)self.slider.value triggerType:ForecastPlayControlsTriggerTypeManual];
    }
}

- (void)play {
    [self.playPause sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)play:(UIButton *)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        
        [self pause];
    }
    else {
        [sender setSelected:YES];
        [self setPlayIndicator:NO];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.playInterval target:self selector:@selector(moveForward) userInfo:nil repeats:YES];
    }
}

- (IBAction)forward:(UIButton *)sender {
    [self pause];
    
    if (self.slider.value <= self.maximun) {
        CGFloat remainder       = ((int)self.slider.value % (int)self.trigger);
        CGFloat forwardValue    = 0;
        
        if (remainder != 0) {
            forwardValue = self.slider.value + self.trigger - remainder;
        }
        else {
            forwardValue = self.slider.value + self.trigger;
        }
        
        [self.slider setValue:forwardValue animated:YES];
        [self triggerFromPosition:(int)self.slider.value triggerType:ForecastPlayControlsTriggerTypeManual];
    }
}

- (void)moveForward {
    if (self.slider.value == self.maximun) {
        if (self.loops) {
            [self.slider setValue:0.0f animated:YES];
        }
        else {
            [self pause];
        }
    }
    else {
        [self.slider setValue:self.slider.value + self.playSpeed animated:YES];
    }
    
    if ((int)self.slider.value % (int)self.trigger == 0) {
        [self triggerFromPosition:(int)self.slider.value triggerType:ForecastPlayControlsTriggerTypeAutomatic];
    }
}

- (IBAction)didSlide:(UISlider *)sender {
    [self pause];
    
    NSLog(@"Sliding from %@", @(sender.value));
    
    if ((int)sender.value % (int)self.trigger == 0) {
        [self triggerFromPosition:sender.value triggerType:ForecastPlayControlsTriggerTypeManual];
    }
}

- (void)pause {
    [self.timer invalidate];
    self.timer = nil;
    
    [self setPlayIndicator:YES];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)resume {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.playInterval target:self selector:@selector(moveForward) userInfo:nil repeats:YES];
}

- (void)triggerFromPosition:(NSInteger)position triggerType:(ForecastPlayControlsTriggerType)triggerType {
    NSInteger actualPosition = position / self.trigger;
    
    [self.delegate forecastPlayControls:self triggeredOnPosition:actualPosition triggerType:triggerType];
}

- (void)setPlayIndicator:(BOOL)set {
    if (set) {
        self.playPauseImage.image   = [UIImage imageNamed:@"regionals-play"];
        self.playPause.selected     = NO;
    }
    else {
        self.playPauseImage.image   = [UIImage imageNamed:@"regionals-pause"];
        
        self.playPause.selected     = YES;
    }
}

- (void)setEnabled:(BOOL)enabled {
    self.slider.enabled         = enabled;
    self.userInteractionEnabled = enabled;
    
    if (enabled) {
        [self.slider addTarget:self action:@selector(didSlide:) forControlEvents:UIControlEventValueChanged];
        
        self.forwardImage.image     = [UIImage imageNamed:@"regionals-forward"];
        self.rewindImage.image      = [UIImage imageNamed:@"regionals-rewind"];
        self.playPauseImage.image   = [UIImage imageNamed:self.playPause.selected ? @"regionals-pause" : @"regionals-play"];
    }
    else {
        [self.slider removeTarget:self action:@selector(didSlide:) forControlEvents:UIControlEventValueChanged];
        
        self.forwardImage.image     = [UIImage imageNamed:@"regionals-forward-disabled"];
        self.rewindImage.image      = [UIImage imageNamed:@"regionals-rewind-disabled"];
        self.playPauseImage.image   = [UIImage imageNamed:self.playPause.selected ? @"regionals-pause-disabled" : @"regionals-play-disabled"];
    }
}

- (void)reset {
    [self stop];
    self.slider.value       = 0;
    
    if ([self isPlaying]) {
        [self setPlayIndicator:YES];
        
        self.playPause.selected = NO;
    }
}

- (BOOL)isPlaying {
    return self.playPause.selected;
}

@end
