//
//  MIOTideForecastViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/24/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOTideForecastViewController.h"
#import "MIOLocalForecastHeaderView.h"

#import "TideEntry.h"
#import "Tide.h"
#import "TideRegion.h"
#import "TideEntrySearchResult.h"

#import "MIOTideTableViewCell.h"
#import "MIOAPI.h"

#import <DateTools/DateTools.h>
#import "ActionSheetDatePicker.h"
//#import <ActionSheetPicker-3.0/ActionSheetDatePicker.h>

@interface MIOTideForecastViewController () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *searchTidesButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) APIClient *apiClient;
@property (strong, nonatomic) NSFetchRequest *request;
@property (nonatomic, strong) NSMutableDictionary *forecasts;
@property (strong, nonatomic) NSDate * selectedDate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblTideTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblHeightTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMoonPhaseTitle;
@property (weak, nonatomic) IBOutlet UIView *noDataAvailableView;
@property (nonatomic) MIOSettingsHeightMeasureUnits selectedHeightMeasureUnit;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblNoDataAvailable;
@property RLMResults<Tide *> *tideEntries ;

@end

@implementation MIOTideForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblNoDataAvailable.text    = LocalizedString(@"no-data-available-message");
    
    self.selectedDate = [NSDate date];
    
    self.apiClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    
    self.tableView.tableFooterView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 48)];
    
    NSDate *start           = [[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]] dateBySubtractingWeeks:1];
    
    NSDateComponents *components    = [NSDateComponents new];
    components.day                  = 1;
    components.second               = -1;

    NSDate *end             = [[[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0] dateByAddingMonths:1];
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tideRegion == %@ AND date >= %@ AND date <= %@", self.tideRegion.identifier, start, end];
    self.tideEntries  = [[TideEntry objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"date" ascending:YES];

    self.activityIndicator.hidden   = YES;
    
    [self setupLocalizedStrings];
    self.selectedHeightMeasureUnit  = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOHeightMeasureUnitKey] integerValue];

    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = self.title;
        self.navigationItem.titleView = [[UIView alloc] init];
    }
    
    if (self.tideRegion.isPerformingFetch) {
        [self presentLoadingView];
    }
    
    [self updateViewData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tideEntryDataArrived:) name:TideEntryDataArrived object:nil];
    
    [MIOAnalyticsManager trackScreen:@"Tide entries" screenClass:[self.classForCoder description]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
}

- (void)languageChanged:(NSNotification *)notification {
    [self setupLocalizedStrings];
    [self.tableView reloadData];
}

-(void)setupLocalizedStrings {
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    self.lblTideTitle.text      = LocalizedString(@"tide-tide-column");
    self.lblTimeTitle.text      = LocalizedString(@"tide-time-column");
    self.lblHeightTitle.text    = LocalizedString(@"tide-height-column");
    self.lblMoonPhaseTitle.text = LocalizedString(@"tide-moon-phase-column");
    self.title = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.tideRegion.englishName : self.tideRegion.name;
    [self.searchTidesButton setTitle:LocalizedString(@"tide-search") forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)tideEntryDataArrived:(NSNotification *)notification {
    NSNumber *tideRegion    = [notification.userInfo objectForKey:@"tideRegion"];
    
    NSDate *start           = [[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]] dateBySubtractingWeeks:1];
    
    NSDateComponents *components    = [NSDateComponents new];
    components.day                  = 1;
    components.second               = -1;

    NSDate *end             = [[[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0] dateByAddingMonths:1];
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tideRegion == %@ AND date >= %@ AND date <= %@", self.tideRegion.identifier, start, end];

    self.tideEntries  = [[TideEntry objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"date" ascending:YES];

    if ([tideRegion integerValue] == [self.tideRegion.identifier integerValue]) {
        [self dismissLoadingView];
        
        [self updateViewData];
    }
}

- (void)updateViewData {

    self.forecasts = [NSMutableDictionary dictionary];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.locale = [NSLocale localeWithLocaleIdentifier: @"en_US"];
    formatter.dateFormat = @"yyyy/MM/dd";
    for(Tide *forecast in self.tideEntries) {
        NSString *dateKey = [formatter stringFromDate: forecast.date];
        NSString *dataForDay = [self.forecasts objectForKey:dateKey];
        [self.forecasts setObject:@([dataForDay integerValue]) forKey:dateKey];
    }

    [self.tableView reloadData];

    if (self.tideEntries.count) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
//                                                                  inSection:self.forecasts.count >= 7 ? 6 : self.forecasts.count - 1] atScrollPosition:UITableViewScrollPositionTop animated:NO];

        self.noDataAvailableView.hidden = YES;
    }
    else {
        self.noDataAvailableView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Obtener llaves del diccionario y ordenarlas
    NSArray *dates              = [[self.forecasts allKeys] mutableCopy];
    dates                       = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *fecha             = dates[indexPath.section];


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.locale = [NSLocale localeWithLocaleIdentifier: @"en_US"];
    formatter.dateFormat = @"YYYY/MM/dd";
    NSDate *forecastDate = [formatter dateFromString: fecha];

    NSPredicate *predicate      = [NSPredicate predicateWithFormat:@"date.year == %@ AND date.month == %@ AND date.day == %@", @(forecastDate.year), @(forecastDate.month), @(forecastDate.day)];
    NSMutableArray *arrayData = [[NSMutableArray alloc] init];
    for(TideEntry *tide in self.tideEntries) {
        [arrayData addObject:tide];
    }
    NSArray *data               = [arrayData filteredArrayUsingPredicate:predicate];

    CGFloat height              = data.count == 3 ? 137.0f : 174.0f;

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Obtener llaves del diccionario y ordenarlas
    NSArray *dates = [[self.forecasts allKeys] mutableCopy];
    dates = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *fecha = dates[indexPath.section];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.locale = [NSLocale localeWithLocaleIdentifier: @"en_US"];
    formatter.dateFormat = @"YYYY/MM/dd";
    NSDate *forecastDate = [formatter dateFromString: fecha];


    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date.year == %@ AND date.month == %@ AND date.day == %@", @(forecastDate.year), @(forecastDate.month), @(forecastDate.day)];

    NSMutableArray *arrayData = [[NSMutableArray alloc] init];
    for(TideEntry *tide in self.tideEntries) {
        [arrayData addObject:tide];
    }
    NSArray *data               = [arrayData filteredArrayUsingPredicate:predicate];

    MIOTideTableViewCell *cell; 
    switch (data.count) {
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier: @"Tide2ItemsCell"];
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier: @"Tide3ItemsCell"];
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier: @"Tide4ItemsCell"];
            break;
        default:
            break;
    }
    
    for (int i = 0; i < data.count; i++) {
        switch (i) {
            case 0:{
                Tide *entry = data[i];
                
                cell.imgIsTideHigh.image    = [UIImage imageNamed:[entry.isHighTide boolValue] ? @"icon-high-tide" : @"icon-low-tide"];
                cell.lblTideTime.text       = [entry.date formattedDateWithFormat:@"HH:mm" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
                cell.lblTideHeight.text     = [NSString stringWithFormat:@"%g %@", (floorf(([entry.tideHeight doubleValue] * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier)) * 100 + 0.5) / 100), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? @"m" : @"ft"];
                
                break;
            }
                
            case 1: {
                Tide *entry = data[i];
                
                cell.imgIsTideHighSecond.image    = [UIImage imageNamed:[entry.isHighTide boolValue] ? @"icon-high-tide" : @"icon-low-tide"];
                cell.lblTideTimeSecond.text       = [entry.date formattedDateWithFormat:@"HH:mm" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
                cell.lblTideHeightSecond.text     = [NSString stringWithFormat:@"%g %@", (floorf(([entry.tideHeight doubleValue] * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier)) * 100 + 0.5) / 100), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? @"m" : @"ft"];
                
                break;
            }
            case 2: {
                Tide *entry = data[i];
                
                cell.imgIsTideHighThird.image    = [UIImage imageNamed:[entry.isHighTide boolValue] ? @"icon-high-tide" : @"icon-low-tide"];
                cell.lblTideTimeThird.text       = [entry.date formattedDateWithFormat:@"HH:mm" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
                cell.lblTideHeightThird.text     = [NSString stringWithFormat:@"%g %@", (floorf(([entry.tideHeight doubleValue] * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier)) * 100 + 0.5) / 100), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? @"m" : @"ft"];
                
                break;
            }
            case 3: {
                Tide *entry = data[i];
                
                cell.imgIsTideHighFourth.image    = [UIImage imageNamed:[entry.isHighTide boolValue] ? @"icon-high-tide" : @"icon-low-tide"];
                cell.lblTideTimeFourth.text       = [entry.date formattedDateWithFormat:@"HH:mm" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
                cell.lblTideHeightFourth.text     = [NSString stringWithFormat:@"%g %@", (floorf(([entry.tideHeight doubleValue] * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier)) * 100 + 0.5) / 100), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? @"m" : @"ft"];
                
                break;
            }
                
            default:
                break;
        }
    }
    
    Tide *entry = data[0];
    NSInteger moon = [entry.moon integerValue];
    if(moon == 1) {
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-new-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Bold" size:12.0];
    } else if(moon > 1 && moon < 9) {
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-waxing-crescent-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    } else if (moon == 9 ) {
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-growing-quarter-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Bold" size:12.0];
    } else if (moon > 9  && moon < 17) {
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-waxing-gibbous-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    } else if (moon == 17 ){
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-full-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Bold" size:12.0];
    } else if(moon > 17 && moon < 25){
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-waning-gibbous-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    } else if(moon == 25) {
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-fading-quarter-moon");
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Bold" size:12.0];
    }else if (moon > 25 && moon <= 32) {
        cell.lblMoon.hidden = NO;
        cell.cntntMoonImageVerticalAlignment.constant = -15;
        cell.lblMoon.text   = LocalizedString(@"tide-waning-crescent-moon");;
        cell.lblMoon.font = [UIFont fontWithName:@"SFUIText-Regular" size:12.0];
    } else {
        cell.cntntMoonImageVerticalAlignment.constant = 0;
        cell.lblMoon.hidden = YES;
    }

    cell.imgMoon.image = [UIImage imageNamed:[NSString stringWithFormat:@"luna-%@", entry.moon]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.forecasts count] - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.forecasts.count > 0 ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //Obtener llaves del diccionario y ordenarlas
    NSArray *dates = [[self.forecasts allKeys] mutableCopy];
    dates = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *fecha = dates[section]; //Obtener la fecha que corresponde a la sección

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];
    formatter.dateFormat = @"YYYY/MM/dd";
    NSDate *forecastDate = [formatter dateFromString: fecha];

    formatter.dateFormat = self.selectedLanguage == MIOSettingsLanguageEnglish ? @"EEEE, MMMM d, YYYY" : @"EEEE d, MMMM, YYYY";
    MIOLocalForecastHeaderView *header = [self.tableView dequeueReusableCellWithIdentifier:@"TideHeader"];
    
    [header.label setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:forecastDate]]];

    NSDate *today = [NSDate date];
    
    if (today.day == forecastDate.day && today.month  == forecastDate.month && today.year == forecastDate.year) {
        header.backgroundColor  = [UIColor blackColor];
    }
    else {
        header.backgroundColor  = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
    }
    
    return header;
}

- (IBAction)onPresentDatePicker:(UIButton *)sender {
    NSDate *minimumDate = [NSDate dateWithYear:1950 month:1 day:1 hour:0 minute:0 second:0];
    NSDate *maximumDate = [NSDate dateWithYear:2050 month:12 day:31 hour:0 minute:0 second:0];
    
    ActionSheetDatePicker *datePicker   = [[ActionSheetDatePicker alloc] initWithTitle:LocalizedString(@"tide-search") datePickerMode: UIDatePickerModeDate selectedDate: self.selectedDate minimumDate:minimumDate maximumDate:
                                           maximumDate target: self
                                                                                action:@selector(actionSheetDatePickerDidFinishSelectingDate:) cancelAction:nil origin:self.view];
    datePicker.toolbarButtonsColor  = self.view.tintColor;
    datePicker.locale               = [NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];
    
    [datePicker setDoneButton:[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"tide-search-done-title")  style:UIBarButtonItemStyleDone target:nil action:nil]];
    
    [datePicker setCancelButton:[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"tide-search-cancel-title")  style:UIBarButtonItemStylePlain target:nil action:nil]];
    
    [datePicker showActionSheetPicker];
}

- (void)actionSheetDatePickerDidFinishSelectingDate:(NSDate *)selectedDate {
    
    [self presentLoadingView];
    
    [MIOAnalyticsManager trackEventWithCategory:@"Tides" action:@"Search"];
    
    [self.forecasts removeAllObjects];
    
    self.tideEntries = nil;
    
    [_tableView reloadData];
    
    self.selectedDate   = selectedDate;
    
    NSDate *start   = [self.selectedDate dateBySubtractingWeeks:1];
    NSDate *end     = [self.selectedDate dateByAddingMonths:2];

    [self.tideRegion apiClient:self.apiClient tideEntriesFromDate:start toDate:end withCallback:^(APIResponse * _Nonnull response) {
        if (response.success) {
            [self dismissLoadingView];
            RLMRealm *realm = [RLMRealm defaultRealm];
            RLMResults<TideEntrySearchResult *> *searchEntries = [TideEntrySearchResult allObjects];
            [realm beginWriteTransaction];
            [realm deleteObjects:searchEntries];
            [realm commitWriteTransaction];

            [TideRegion saveTideEntriesSearchResultsDictionaryRepresentationToStorage:response.mappedResponse];

            NSDate *start           = [self.selectedDate dateBySubtractingWeeks:1];
            NSDate *end             = [self.selectedDate dateByAddingMonths:1];

            NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"tideRegion == %@ AND date >= %@ AND date <= %@", self.tideRegion.identifier, start, end];

            self.tideEntries = [[TideEntrySearchResult objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"date" ascending:YES];

            [self updateViewData];
        }
        else if (response.statusCode == APIResponseStatusCodeNotConnectedToInternet) {
            [self dismissLoadingView];
            [self presentInformationMessage:LocalizedString(@"no-internet-connectivity-message")];
        }
    }];
}

- (void)presentLoadingView {
    [self.searchTidesButton setTitle:@"" forState:UIControlStateNormal];
    self.searchTidesButton.userInteractionEnabled   = NO;
    self.activityIndicator.hidden   = NO;
    [self.activityIndicator startAnimating];
}

- (void)dismissLoadingView {
    self.activityIndicator.hidden   = YES;
    self.searchTidesButton.userInteractionEnabled   = YES;
    [self.activityIndicator stopAnimating];
    [self.searchTidesButton setTitle:LocalizedString(@"tide-search") forState:UIControlStateNormal];
}

- (void)presentInformationMessage:(NSString *)message {
    self.searchTidesButton.tintColor        = [UIColor whiteColor];
    self.searchTidesButton.backgroundColor  = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self.searchTidesButton setTitle:message forState:UIControlStateNormal];
    
    self.searchTidesButton.userInteractionEnabled   = NO;
    
    self.activityIndicator.hidden   = YES;
    [self.activityIndicator stopAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(dismissLoadingView) userInfo:nil repeats:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
