//
//  MIORegionalForecasViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIORegionalForecastViewController.h"
#import "MIORegionalForecastCommentViewController.h"

#import "RegionalForecastType.h"
#import "RegionalForecastTypeSlide.h"

#import "ForecastPlayControls.h"
#import "MIOAPI.h"
#import <AsyncImageView/AsyncImageView.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImagePrefetcher.h>
#import <Haneke/Haneke.h>
#import <DateTools/DateTools.h>

NSInteger const kImagePrefetchConnectionTooSlowTrigger = 15;

@interface MIORegionalForecastViewController () <ForecastPlayControlsDelegate>

@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imgAnimatedGIF;
@property (weak, nonatomic) IBOutlet UIImageView *imgScaleBar;
@property (weak, nonatomic) IBOutlet UIImageView *forecastImage;
@property (weak, nonatomic) IBOutlet UILabel *lblValidThru;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *hours;
@property (weak, nonatomic) IBOutlet UIButton *btnSeeComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstntGIFTopSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *GIFBottomSpacing;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet NSArray *orderedSlides;
@property (weak, nonatomic) IBOutlet ForecastPlayControls *forecastPlayControls;
@property (nonatomic) NSInteger currentlyDisplayedSlide;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessage;
@property (nonatomic) BOOL finishedLoadingSlides;
@property (strong, nonatomic) NSTimer *slowTrigger;
@property (strong, nonatomic) APIClient *apiClient;

@end

@implementation MIORegionalForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    [self setupLocalizedStrings];
    self.apiClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.forecastPlayControls.delegate  = self;
    self.forecastPlayControls.maximun       = (self.orderedSlides.count - 1) * self.forecastPlayControls.trigger;
    self.currentlyDisplayedSlide            = -1;

    NSArray *slidesImageUrls                = [self slideImagesURLsFromSlides:self.orderedSlides];
    
    SDWebImagePrefetcher *imagePrefetcher   = [SDWebImagePrefetcher sharedImagePrefetcher];
    
    [self.forecastPlayControls setEnabled:NO];
    [self.activityIndicator startAnimating];
    
    [self displayLoadingMessage:LocalizedString(@"regional-forecast-loading-message-1")];
    
    self.slowTrigger = [NSTimer scheduledTimerWithTimeInterval:kImagePrefetchConnectionTooSlowTrigger target:self selector:@selector(triggerImagePrefetchTooSlow) userInfo:nil repeats:NO];
    
    @weakify(self);
    [imagePrefetcher prefetchURLs:slidesImageUrls progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
    } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        @strongify(self);
        [self.forecastPlayControls setEnabled:YES];
        
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            
            [self.activityIndicator stopAnimating];
            [self.forecastPlayControls play];
            self.loadingMessage.hidden  = YES;
        });
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
    [MIOAnalyticsManager trackScreen:@"Regional forecast category list" screenClass:[self.classForCoder description]];
    [self fetchSlides];
}

- (void) fetchSlides {
    [RegionalForecastType apiClient:self.apiClient regionalForecastSlidesFor:self.forecast with:^(APIResponse * _Nonnull callback) {
        [RegionalForecastType saveRegionalForecastSlidesDictionaryRepresentationToStorage:callback.mappedResponse with:^(NSArray * _Nonnull slides) {
            [self regionalForecastTypesDataArrived:slides];
        }];
    }];
}

- (void)languageChanged:(NSNotification *)notification {
    [self setupLocalizedStrings];
}

- (void) setupLocalizedStrings {
    self.selectedLanguage               = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.btnSeeComment setTitle:LocalizedString(@"local-forecast-comment") forState:UIControlStateNormal];
    self.title = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.forecast.englishName : self.forecast.name;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.slowTrigger invalidate];
    self.slowTrigger = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RegionalForecastComment"]) {
        ((MIORegionalForecastCommentViewController *)segue.destinationViewController).forecast = self.forecast;
    }
}

- (void)regionalForecastTypesDataArrived:(NSArray *)slides {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.forecastPlayControls reset];
        [self.forecastPlayControls setEnabled:NO];

        self.date.text                          = @"";
        self.hours.text                         = @"";
        self.loadingMessage.hidden              = NO;
        self.forecastImage.image                = nil;

        [self.activityIndicator startAnimating];
        [self displayLoadingMessage:LocalizedString(@"regional-forecast-loading-message-1")];

        self.orderedSlides                      = [slides sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
        NSArray *slidesImageUrls                = [self slideImagesURLsFromSlides:self.orderedSlides];

        self.forecastPlayControls.maximun       = (self.orderedSlides.count - 1) * self.forecastPlayControls.trigger;
        self.currentlyDisplayedSlide            = -1;


        SDWebImagePrefetcher *imagePrefetcher   = [SDWebImagePrefetcher sharedImagePrefetcher];

        [NSTimer scheduledTimerWithTimeInterval:kImagePrefetchConnectionTooSlowTrigger target:self selector:@selector(triggerImagePrefetchTooSlow) userInfo:nil repeats:NO];

        @weakify(self);
        [imagePrefetcher prefetchURLs:slidesImageUrls progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
        } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
            @strongify(self);
            [self.forecastPlayControls setEnabled:YES];

            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);

                [self.activityIndicator stopAnimating];
                [self.forecastPlayControls play];
                self.loadingMessage.hidden  = YES;
            });
        }];
    });

}

- (void)triggerImagePrefetchTooSlow {
    [self displayLoadingMessage:LocalizedString(@"regional-forecast-loading-message-2")];
    
    NSLog(@"Triggered slow");
}

- (void)displayLoadingMessage:(NSString *)message {
    self.loadingMessage.text = message;
}

#pragma mark - ForecastPlayControlsDelegate

- (void)forecastPlayControls:(ForecastPlayControls *)forecastPlayControls triggeredOnPosition:(NSInteger)position triggerType:(ForecastPlayControlsTriggerType)triggerType {
    [self presentSlide:position triggerType:triggerType];
}

- (void)presentSlide:(NSInteger)slide triggerType:(ForecastPlayControlsTriggerType)triggerType {
    if (slide != self.currentlyDisplayedSlide) {
        if(self.orderedSlides == nil || self.orderedSlides.count == 0) {
            return;
        }
        RegionalForecastTypeSlide *slideToPresent   = self.orderedSlides[slide];
        
        NSLog(@"%@, %@", @(slide), @(self.currentlyDisplayedSlide));
        
        self.currentlyDisplayedSlide                = slide;
        
        NSInteger order = 0;
        
        for (RegionalForecastTypeSlide *slide in self.orderedSlides) {
            NSLog(@"%@, %@, %@, %@", @(order), slide.identifier, slide.image, slide.date);
            
            order++;
        }
        
        NSURL *imageURL = [NSURL URLWithString:slideToPresent.image];
        
        [self.forecastPlayControls stop];
        
        if (slideToPresent.image == nil) {
            return;
        }
        
        @weakify(self);
        [[[SDWebImageManager alloc] init] loadImageWithURL:imageURL options:SDWebImageRetryFailed
                                                  progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                  }
                                                 completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                     @strongify(self);
                                                     
                                                     if (image) {
                                                         if (triggerType == ForecastPlayControlsTriggerTypeAutomatic) {
                                                             [self setupForecastWithImage:image andSlide:slideToPresent];
                                                             
                                                             RegionalForecastTypeSlide *nextSlide   = [self nextSlideForSlideAtIndex:slide];
                                                             NSURL *nextSlideImageURL               = [NSURL URLWithString:nextSlide.image];
                                                             
                                                             @weakify(self);
                                                             [[[SDWebImageManager alloc] init] loadImageWithURL:nextSlideImageURL options:SDWebImageRetryFailed
                                                                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                                                                       }
                                                                                                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                                                                          @strongify(self);
                                                                                                          
                                                                                                          if (image) {
                                                                                                              [self.forecastPlayControls resume];
                                                                                                          }
                                                                                                          else {
                                                                                                              NSLog(@"WOOOPPSSS, NEXT IMAGE NOT FOUND");
                                                                                                              
                                                                                                              @weakify(self);
                                                                                                              [self retryImageURL:imageURL completion:^(UIImage *image) {
                                                                                                                  @strongify(self);
                                                                                                                  
                                                                                                                  @weakify(self);
                                                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                      @strongify(self);
                                                                                                                      
                                                                                                                      [self.forecastPlayControls resume];
                                                                                                                  });
                                                                                                              }];
                                                                                                          }
                                                                                                      }];
                                                         }
                                                         else {
                                                             if (self.currentlyDisplayedSlide == slide) {
                                                                 [self setupForecastWithImage:image andSlide:slideToPresent];
                                                             }
                                                         }
                                                     }
                                                     else {
                                                         NSLog(@"WOOOPPSSS, NO IMAGE FOUND");
                                                         
                                                         @weakify(self);
                                                         [self retryImageURL:imageURL completion:^(UIImage *image) {
                                                             @strongify(self);
                                                             
                                                             @weakify(self);
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 @strongify(self);
                                                                 
                                                                 if (triggerType == ForecastPlayControlsTriggerTypeAutomatic) {
                                                                     [self setupForecastWithImage:image andSlide:slideToPresent];
                                                                     
                                                                     [self.forecastPlayControls resume];
                                                                 }
                                                                 else {
                                                                     if (self.currentlyDisplayedSlide == slide) {
                                                                         [self setupForecastWithImage:image andSlide:slideToPresent];
                                                                     }
                                                                 }
                                                             });
                                                         }];
                                                     }
                                                 }];
    }
}

- (void)retryImageURL:(NSURL *)imageURL completion:(void(^)(UIImage *image))completion {
    @weakify(self);
    [[SDWebImageManager sharedManager] loadImageWithURL:imageURL options:SDWebImageRetryFailed
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                               }
                                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                  @strongify(self);
                                                  
                                                  if (image) {
                                                      completion(image);
                                                  }
                                                  else {
                                                      NSLog(@"Image still not found, retrying again");
                                                      
                                                      return [self retryImageURL:imageURL completion:completion];
                                                  }
                                              }];
}

- (void)setupForecastWithImage:(UIImage *)image andSlide:(RegionalForecastTypeSlide *)slide {
//    YLMoment *slideMoment           = [YLMoment momentWithDate:slide.date];
//    slideMoment.timeZone            = [NSTimeZone localTimeZone];
//    slideMoment.locale              = [NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.locale = [NSLocale localeWithLocaleIdentifier: self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];
    formatter.dateFormat = self.selectedLanguage == MIOSettingsLanguageEnglish ? @"E MM/dd - HH:00" : @"E dd/MM - HH:00";
//    NSDate *forecastDate = [formatter dateFromString: fecha]; viene del copy paste

    RegionalForecastTypeSlide *startingSlide    = [self.orderedSlides firstObject];
    NSDate *startingDate                        = startingSlide.date;
    NSTimeInterval intervalFromStartingDate     = [slide.date timeIntervalSinceDate:startingDate];
    NSInteger intervalInHours                   = intervalFromStartingDate / 3600;
    
    self.forecastImage.image   = image;
    NSString *dateString = [formatter stringFromDate: slide.date];
    self.date.text             = [NSString stringWithFormat:@"%@ (%@)", dateString.lowercaseString , LocalizedString(@"regional-forecast-local-time")];
    self.hours.text            = [NSString stringWithFormat:@"+%@ %@", @(intervalInHours), LocalizedString(@"regional-forecast-hours")];
}

- (RegionalForecastTypeSlide *)nextSlideForSlideAtIndex:(NSInteger)index {
    if (index == self.orderedSlides.count - 1) {
        return self.orderedSlides[0];
    }
    else {
        return self.orderedSlides[index + 1];
    }
    
    return nil;
}

- (NSArray *)slidesByRemovingOutdatedSlides:(NSArray *)outdatedSlides fromRegionalForecastType:(RegionalForecastType *)regionalForecastType {
    NSMutableArray *nonOutdatedSlides = [NSMutableArray arrayWithArray:@[]];
    
    for (RegionalForecastTypeSlide *slide in regionalForecastType.slides) {
        if (![outdatedSlides containsObject:slide.identifier]) {
            [nonOutdatedSlides addObject:slide];
        }
    }
    return nonOutdatedSlides;
}

- (NSArray *)slideImagesURLsFromSlides:(NSArray *)slides {
    NSArray *slidesImageUrlStrings  = [slides valueForKey:@"image"];
    NSMutableArray *slidesImageUrls = [NSMutableArray arrayWithArray:@[]];
    
    for (NSString *imageUrlString in slidesImageUrlStrings) {
        [slidesImageUrls addObject:[NSURL URLWithString:imageUrlString]];
    }
    
    return slidesImageUrls;
}

- (void)dealloc
{
    NSLog(@"Dealloced forecast detail");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
