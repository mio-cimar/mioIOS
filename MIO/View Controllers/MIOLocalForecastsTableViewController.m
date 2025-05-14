//
//  LocalForecastsTableViewController.m
//  MIO
//
//  Created by Alonso Vega on 6/16/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOLocalForecastsTableViewController.h"
#import "MIOLocalForecastCommentViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LocalForecast.h"
#import "MIOLocalForecastHeaderView.h"
#import "MIOLocalForecastTableViewCell.h"
#import "LocalForecastCommentCell.h"
#import "CommentCard.h"
#import "CommentsSlider.h"
#import "LocalForecastCell.h"
#import "Forecast.h"
#import "MIOLocalForecastUtils.h"
#import "MIOAPI.h"
#import <DateTools/DateTools.h>
#import <Haneke/Haneke.h>

NSString *const CommentsHelpSegueIdentifier    = @"CommentsHelp";
NSString *const ForecastsHelpSegueIdentifier   = @"ForecastsHelp";

typedef NS_ENUM(NSInteger, LocalForecastSections) {
    LocalForecastSectionComments,
    LocalForecastSectionForecast,
    LocalForecastSectionRegion
};

@interface MIOLocalForecastsTableViewController () <NSFetchedResultsControllerDelegate> {
    BOOL userInteracting;
}

@property (nonatomic, strong) NSMutableDictionary *forecasts;
@property (nonatomic, strong) NSMutableDictionary *sectionsFromLocationsInArray;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) APIClient *apiClient;
@property (weak, nonatomic) IBOutlet UILabel *lblValidThru;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblWavePeriod;
@property (weak, nonatomic) IBOutlet UILabel *lblWindDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblWindBurst;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *regionWindTitle;
@property (weak, nonatomic) IBOutlet UILabel *regionWind;
@property (weak, nonatomic) IBOutlet UILabel *regionSwellTitle;
@property (weak, nonatomic) IBOutlet UILabel *regionSwell;
@property (weak, nonatomic) IBOutlet UILabel *regionTemperatureTitle;
@property (weak, nonatomic) IBOutlet UILabel *regionTemperature;
@property (weak, nonatomic) IBOutlet UILabel *regionSalinityTitle;
@property (weak, nonatomic) IBOutlet UILabel *regionSalinity;
@property (weak, nonatomic) IBOutlet UILabel *regionTitle;
@property (weak, nonatomic) IBOutlet UILabel *oceanographicCharacteristics;
@property (weak, nonatomic) IBOutlet UIImageView *regionMap;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property RLMResults<LocalForecast *> *localForecasts;

@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (nonatomic) MIOSettingsHeightMeasureUnits selectedHeightMeasureUnit;
@property (nonatomic) MIOSettingsSpeedMeasureUnits selectedSpeedMeasureUnit;

@property (nonatomic) NSInteger todaySection;

@end

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation MIOLocalForecastsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    self.tableView.tableFooterView  = [UIView new];
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    self.selectedSpeedMeasureUnit   = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOSpeedMeasureUnitKey] integerValue];
    self.selectedHeightMeasureUnit  = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOHeightMeasureUnitKey] integerValue];
    
    self.forecasts                      = [NSMutableDictionary dictionary];
    self.sectionsFromLocationsInArray   = [NSMutableDictionary dictionary];
    self.title = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.region.englishName : self.region.name;
    self.rightBarButtonItem.tintColor   = [UIColor colorWithRed:0 green:0.69 blue:1 alpha:1];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = self.title;
        self.navigationItem.titleView = [[UIView alloc] init];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }

    [self.commentButton setTitle:LocalizedString(@"local-forecast-comment") forState:UIControlStateNormal];
    
    if (self.region.isPerformingFetch) {
        [self presentLoadingView];
    }
    else {
        [self dismissLoadingView];
    }
    
    [self setupRegion];
    
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-sections-first") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-sections-second") forSegmentAtIndex:1];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-sections-third") forSegmentAtIndex:2];
    
    [self.segmentedControl addTarget:self action:@selector(didSwitchLocalForecastView) forControlEvents:UIControlEventValueChanged];
    
    [self updateViewData];
    
    [MIOAnalyticsManager trackScreen:@"Local forecast comments" screenClass:[self.classForCoder description]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
}

- (void)languageChanged:(NSNotification *)notification {
    [self setupLocalizedStrings];
    [self.tableView reloadData];
}

- (void) setupLocalizedStrings {
     self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-sections-first") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-sections-second") forSegmentAtIndex:1];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-sections-third") forSegmentAtIndex:2];
    self.title = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.region.englishName : self.region.name;
    [self setupRegion];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localForecastDataArrived:) name:LocalForecastDataArrived object:nil];
}

- (void)setupRegion {
    self.regionTitle.text      = LocalizedString(@"local-forecast-region-oceanographic-characteristics");
    self.regionWindTitle.text               = LocalizedString(@"local-forecast-region-wind");
    self.regionSwellTitle.text              = LocalizedString(@"local-forecast-region-swell");
    self.regionTemperatureTitle.text        = LocalizedString(@"local-forecast-region-temperature");
    self.regionSalinityTitle.text           = LocalizedString(@"local-forecast-region-salinity");
    self.regionWind.text        = self.region.wind;
    self.regionSwell.text       = self.region.swell;
    self.regionTemperature.text = self.region.temperature;
    self.regionSalinity.text    = self.region.saltiness;
    switch (self.region.identifier.integerValue) {
        case 10:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_norte_pacifico_norte"]];
            break;
        case 11:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_centro_pacifico_norte"]];
            break;
        case 12:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_sur_pacifico_norte"]];
            break;
        case 13:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_puntarenas"]];
            break;
        case 14:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_pacifico_central"]];
            break;
        case 15:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_pacifico_sur"]];
            break;
        case 16:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_caribe"]];
            break;
        case 9:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_isla_coco"]];
            break;
        default:
            [self.regionMap setImage:[UIImage imageNamed:@"mapa_escondido_pacifico_central"]];
            break;
    }
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = self.title;
        self.navigationItem.titleView = [[UIView alloc] init];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }
    if( self.segmentedControl.selectedSegmentIndex == LocalForecastSectionRegion ){
        self.tableView.hidden               = YES;
        self.regionDisplay.hidden           = NO;
        self.rightBarButtonItem.enabled     = NO;
        self.rightBarButtonItem.tintColor   = [UIColor colorWithRed:0 green:0.69 blue:1 alpha:1];
    } else {
        self.tableView.hidden               = NO;
        self.regionDisplay.hidden           = YES;
        self.rightBarButtonItem.enabled     = YES;
        self.rightBarButtonItem.tintColor   = [UIColor colorWithRed:0 green:0.69 blue:1 alpha:1];
        [self.tableView reloadData];
    }
}

- (void)didSwitchLocalForecastView {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case LocalForecastSectionComments:
            self.tableView.hidden               = NO;
            self.regionDisplay.hidden           = YES;
            self.rightBarButtonItem.enabled     = YES;
            [self.tableView reloadData];
            
            [MIOAnalyticsManager trackScreen:@"Local forecast comments" screenClass:[self.classForCoder description]];
            
            break;
            
        case LocalForecastSectionForecast:
            self.tableView.hidden               = NO;
            self.regionDisplay.hidden           = YES;
            self.rightBarButtonItem.enabled     = YES;
            [self.tableView reloadData];
            
            [MIOAnalyticsManager trackScreen:@"Local forecast data table" screenClass:[self.classForCoder description]];
            
            break;
            
        case LocalForecastSectionRegion:
            self.tableView.hidden               = YES;
            self.regionDisplay.hidden           = NO;
            self.rightBarButtonItem.enabled     = NO;
            self.rightBarButtonItem.tintColor   = [UIColor colorWithRed:0 green:0.69 blue:1 alpha:1];
            break;
            
        default:
            break;
    }
}

- (void)localForecastDataArrived:(NSNotification *)notification {
    NSNumber *localForecast = [notification.userInfo objectForKey:@"localForecast"];
    
    if ([localForecast integerValue] == [self.region.identifier integerValue]) {
        [self dismissLoadingView];
        
        [self updateViewData];
        [self setupRegion];
    }
}

- (void)updateViewData {
    [self reloadDatasourceData];
    
    self.forecasts      = [NSMutableDictionary dictionary];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"YYYY/MM/dd";
    formatter.locale = [NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];
    for (LocalForecast *forecast in self.localForecasts) {
        NSString *dateKey = [formatter stringFromDate:forecast.date];
        NSString *dataForDay = [self.forecasts objectForKey:dateKey];
        [self.forecasts setObject:@([dataForDay integerValue] + 1) forKey:dateKey];
    }

    NSArray *dates = [[self.forecasts allKeys] mutableCopy];
    dates = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    for (int i = 0; i < dates.count; i++) {
        NSDate *forecastDate = [formatter dateFromString: dates[i]];
        NSDate *today = [NSDate date];

        if (today.day == forecastDate.day && today.month  == forecastDate.month && today.year == forecastDate.year) {
            self.todaySection = i;
        }
    }

    [self.refreshControl endRefreshing];
    [self.tableView reloadData];

    if (self.localForecasts.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.todaySection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.forecasts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *currentSectionString  = [NSString stringWithFormat:@"%@", @(section)];
    NSString *nextSectionString     = [NSString stringWithFormat:@"%@", @(section + 1)];
    
    NSArray *dates  = [[self.forecasts allKeys] mutableCopy];
    dates           = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *date  = dates[section];
    
    if (section == 0) {
        [self.sectionsFromLocationsInArray setObject:@(section) forKey:currentSectionString];
        [self.sectionsFromLocationsInArray setObject:@(section + [[self.forecasts objectForKey:date] integerValue]) forKey:nextSectionString];
    }
    else {
        [self.sectionsFromLocationsInArray setObject:@([[self.sectionsFromLocationsInArray objectForKey:currentSectionString] integerValue] + [[self.forecasts objectForKey:date] integerValue]) forKey:nextSectionString];
    }
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case LocalForecastSectionComments:
            return 1;
            break;
            
        case LocalForecastSectionForecast:
            return 1;
            break;
            
        case LocalForecastSectionRegion: {
            return [[self.forecasts objectForKey:date] integerValue];
            break;
        }
            
        default:
            break;
    }
    
    return 0;
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
    
    MIOLocalForecastHeaderView *header = [self.tableView dequeueReusableCellWithIdentifier:@"forecastHeader"];
    formatter.dateFormat = self.selectedLanguage == MIOSettingsLanguageEnglish ? @"EEEE, MMMM d" : @"EEEE d, MMMM";
    [header.label setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate: forecastDate]]];
    
    NSDate *today = [NSDate date];
    
    if (today.day == forecastDate.day && today.month  == forecastDate.month && today.year == forecastDate.year) {
        header.backgroundColor  = [UIColor blackColor];
    }
    else {
        header.backgroundColor  = [UIColor colorWithRed:130.0f/255.0f green:130.0f/255.0f blue:130.0f/255.0f alpha:1.0f];
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case LocalForecastSectionComments:
            return 360.0f;
            break;
            
        case LocalForecastSectionForecast:
            return 360.0f;
            break;
            
        case LocalForecastSectionRegion:
            return 60.0f;
            break;
            
        default:
            break;
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionString  = [NSString stringWithFormat:@"%@", @(indexPath.section)];
    
    // Obtener datos necesarios para el pronóstico de la mañana y de la tarde
    
    NSArray *dates  = [[self.forecasts allKeys] mutableCopy];
    dates           = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *date  = dates[indexPath.section]; //Obtener la fecha que corresponde a la sección
    
//    return [[self.forecasts objectForKey:fecha] integerValue];
    
    NSInteger start = [[self.sectionsFromLocationsInArray objectForKey:sectionString] integerValue];
    NSInteger end   = start + [[self.forecasts objectForKey:date] integerValue];
    
    NSMutableArray *forecasts = [NSMutableArray arrayWithArray:@[]];
    
    for (int i = start; i < end; i++) {
        [forecasts addObject:self.localForecasts[i]];
    }
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case LocalForecastSectionComments: {
            LocalForecastCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalForecastComment" forIndexPath:indexPath];
            
            [cell.morningCommentsSlider reset];
            [cell.afternoonCommentsSlider reset];
            
            cell.morningDisclaimer.text     = LocalizedString(@"local-forecast-morning");
            cell.afternoonDisclaimer.text   = LocalizedString(@"local-forecast-afternoon");
            
            __block LocalForecast *morningForecast;
            __block LocalForecast *afternoonForecast;
            
            if (forecasts.count == 4) {
                morningForecast     = forecasts[1];
                afternoonForecast   = forecasts[2];
            }
            else if (forecasts.count == 3) {
                morningForecast      = forecasts[0];
                afternoonForecast    = forecasts[1];
            }
            else {
                morningForecast      = nil;
                afternoonForecast    = forecasts[0];
            }
            
            // Realizar cálculos para determinar la cantidad de tarjetas que se
            // necesitarán tanto para los comentarios de la mañana como los de la tarde.
            
            LocalForecastSwellAndWind morningSwellAndWind           = [morningForecast swellAndWind];
            LocalForecastSwellAndWind afternoonSwellAndWind         = [afternoonForecast swellAndWind];
            
            LocalForecastBathingAndPorts morningBathingAndPorts     = [morningForecast bathingAndPortsForRegion:self.region.name];
            LocalForecastBathingAndPorts afternoonBathingAndPorts   = [afternoonForecast bathingAndPortsForRegion:self.region.name];
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            CommentCard *morningSwellAndWindCard    = [[CommentCard alloc] initWithFrame:[cell.morningCommentsSlider cardFrame]];
            CommentCard *morningBathingCard         = [[CommentCard alloc] initWithFrame:[cell.morningCommentsSlider cardFrame]];
//            CommentCard *morningPortsCard           = [[CommentCard alloc] initWithFrame:[cell.morningCommentsSlider cardFrame]];

            switch (morningSwellAndWind) {
                case LocalForecastSwellAndWindRed1:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-red"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-red-1");
                    break;
                    
                case LocalForecastSwellAndWindRed2:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-red"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-red-2");
                    break;
                    
                case LocalForecastSwellAndWindYellow1:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-yellow"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-yellow-1");
                    break;
                    
                case LocalForecastSwellAndWindYellow2:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-yellow"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-yellow-2");
                    break;
                    
                case LocalForecastSwellAndWindGreen1:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-green"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-green-1");
                    break;
                    
                case LocalForecastSwellAndWindGreen2:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-green"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-green-2");
                    break;
                    
                case LocalForecastSwellAndWindLightBlue1:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-light-blue"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-light-blue-1");
                    break;
                    
                case LocalForecastSwellAndWindLightBlue2:
                    morningSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-light-blue"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-light-blue-2");
                    break;
                    
                default:
                    break;
            }
            
            switch (morningBathingAndPorts) {
                case LocalForecastBathingAndPortsCaribbeanRed1:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-red"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-red-1");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-red"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level2");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-red"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-red-1");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanRed2:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-red"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-red-2");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-red"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-red-2");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-red"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level1");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanYellow:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-yellow"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-yellow");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-yellow"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-yellow");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-yellow"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level3");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanGreen:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-green"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-green");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-green"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-green");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-green"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level4");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanLightBlue:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-light-blue"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-light-blue");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-light-blue"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-light-blue");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-light-blue"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level5");
                    break;
                    
                case LocalForecastBathingAndPortsPacificRed:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-red"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-red");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-red"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-red");
                    break;
                    
                case LocalForecastBathingAndPortsPacificYellow:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-yellow"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-yellow");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-yellow"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-yellow");
                    break;
                case LocalForecastBathingAndPortsPacificYellow1:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-yellow"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-yellow1");
                    //                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-yellow"];
                    //                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-yellow");
                    break;
                case LocalForecastBathingAndPortsPacificGreen:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-green"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-green");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-green"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-green");
                    break;
                    
                case LocalForecastBathingAndPortsPacificLightBlue1:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-light-blue"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-light-blue-1");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-light-blue"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-light-blue-1");
                    break;
                    
                case LocalForecastBathingAndPortsPacificLightBlue2:
                    morningBathingCard.image.image  = [UIImage imageNamed:@"swimmer-light-blue"];
                    morningBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-light-blue-2");
//                    morningPortsCard.image.image    = [UIImage imageNamed:@"port-light-blue"];
//                    morningPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-light-blue-2");
                    break;
                    
                default:
                    break;
            }
            
            CommentCard *afternoonSwellAndWindCard    = [[CommentCard alloc] initWithFrame:[cell.afternoonCommentsSlider cardFrame]];
            CommentCard *afternoonBathingCard         = [[CommentCard alloc] initWithFrame:[cell.afternoonCommentsSlider cardFrame]];
            CommentCard *afternoonPortsCard           = [[CommentCard alloc] initWithFrame:[cell.afternoonCommentsSlider cardFrame]];
            
            switch (afternoonSwellAndWind) {
                case LocalForecastSwellAndWindRed1:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-red"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-red-1");
                    break;
                    
                case LocalForecastSwellAndWindRed2:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-red"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-red-2");
                    break;
                    
                case LocalForecastSwellAndWindYellow1:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-yellow"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-yellow-1");
                    break;
                    
                case LocalForecastSwellAndWindYellow2:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-yellow"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-yellow-2");
                    break;
                    
                case LocalForecastSwellAndWindGreen1:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-green"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-green-1");
                    break;
                    
                case LocalForecastSwellAndWindGreen2:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-green"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-green-2");
                    break;
                    
                case LocalForecastSwellAndWindLightBlue1:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-light-blue"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-light-blue-1");
                    break;
                    
                case LocalForecastSwellAndWindLightBlue2:
                    afternoonSwellAndWindCard.image.image    = [UIImage imageNamed:@"sailing-light-blue"];
                    afternoonSwellAndWindCard.text.text      = LocalizedString(@"local-forecast-swell-and-wind-light-blue-2");
                    break;
                    
                default:
                    break;
            }
            
            switch (afternoonBathingAndPorts) {
                case LocalForecastBathingAndPortsCaribbeanRed1:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-red"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-red-1");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-red"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-red-1");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-red"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level2");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanRed2:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-red"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-red-2");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-red"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-red-2");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-red"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level1");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanYellow:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-yellow"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-yellow");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-yellow"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-yellow");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-yellow"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level3");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanGreen:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-green"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-green");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-green"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-green");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-green"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level4");
                    break;
                    
                case LocalForecastBathingAndPortsCaribbeanLightBlue:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-light-blue"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-caribbean-light-blue");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-light-blue"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-caribbean-light-blue");
                    morningSwellAndWindCard.image.image = [UIImage imageNamed:@"sailing-light-blue"];
                    morningSwellAndWindCard.text.text      = LocalizedString(@"card1_caribbean_level5");
                    break;
                    
                case LocalForecastBathingAndPortsPacificRed:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-red"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-red");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-red"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-red");
                    break;
                    
                case LocalForecastBathingAndPortsPacificYellow:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-yellow"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-yellow");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-yellow"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-yellow");
                    break;

                case LocalForecastBathingAndPortsPacificYellow1:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-yellow"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-yellow1");
                    break;
                case LocalForecastBathingAndPortsPacificGreen:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-green"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-green");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-green"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-green");
                    break;
                    
                case LocalForecastBathingAndPortsPacificLightBlue1:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-light-blue"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-light-blue-1");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-light-blue"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-light-blue-1");
                    break;
                    
                case LocalForecastBathingAndPortsPacificLightBlue2:
                    afternoonBathingCard.image.image  = [UIImage imageNamed:@"swimmer-light-blue"];
                    afternoonBathingCard.text.text    = LocalizedString(@"local-forecast-bathing-pacific-light-blue-2");
                    afternoonPortsCard.image.image    = [UIImage imageNamed:@"port-light-blue"];
                    afternoonPortsCard.text.text      = LocalizedString(@"local-forecast-port-pacific-light-blue-2");
                    break;
                    
                default:
                    break;
            }
            
            [cell.morningCommentsSlider setupWithNumberOfPages:morningSwellAndWind == LocalForecastSwellAndWindNone ? morningBathingAndPorts == LocalForecastBathingAndPortsNone ? 0 : 1 : 2];//change last number to 3 if want to include ports
            [cell.afternoonCommentsSlider setupWithNumberOfPages:afternoonSwellAndWind == LocalForecastSwellAndWindNone ? afternoonBathingAndPorts == LocalForecastBathingAndPortsNone ? 0 : 1 : 2];//change last number to 3 if want to include ports
            
            if (morningSwellAndWind != LocalForecastSwellAndWindNone) {
                if (morningBathingAndPorts != LocalForecastBathingAndPortsNone) {
                    [cell.morningCommentsSlider addPage:morningBathingCard];
                    [cell.morningCommentsSlider addPage:morningSwellAndWindCard];
//                    [cell.morningCommentsSlider addPage:morningPortsCard];
                }
                else {
                    [cell.morningCommentsSlider addPage:morningSwellAndWindCard];
                }
            }
            else {
                if (morningBathingAndPorts != LocalForecastBathingAndPortsNone) {
                    [cell.morningCommentsSlider addPage:morningBathingCard];
//                    [cell.morningCommentsSlider addPage:morningPortsCard];
                }
            }
            
            if (afternoonSwellAndWind != LocalForecastSwellAndWindNone) {
                if (afternoonBathingAndPorts != LocalForecastBathingAndPortsNone) {
                    [cell.afternoonCommentsSlider addPage:afternoonBathingCard];
                    [cell.afternoonCommentsSlider addPage:afternoonSwellAndWindCard];
//                    [cell.afternoonCommentsSlider addPage:afternoonPortsCard];
                }
                else {
                    [cell.afternoonCommentsSlider addPage:afternoonSwellAndWindCard];
                }
            }
            else {
                if (afternoonBathingAndPorts != LocalForecastBathingAndPortsNone) {
                    [cell.afternoonCommentsSlider addPage:afternoonBathingCard];
//                    [cell.afternoonCommentsSlider addPage:afternoonPortsCard];
                }
            }
            
            [cell.morningCommentsSlider goToPage:morningForecast.currentlyDisplayedPage];
            [cell.afternoonCommentsSlider goToPage:afternoonForecast.currentlyDisplayedPage];
            
            cell.morningCommentsSlider.didMoveToPage = ^(NSInteger page) {
                morningForecast.currentlyDisplayedPage  = page;
            };
            
            cell.afternoonCommentsSlider.didMoveToPage = ^(NSInteger page) {
                afternoonForecast.currentlyDisplayedPage    = page;
            };
            
            return cell;
            
            break;
        }
            
            
        case LocalForecastSectionForecast: {
            LocalForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocalForecast" forIndexPath:indexPath];
            
            LocalForecast *firstForecast;
            LocalForecast *secondForecast;
            LocalForecast *thirdForecast;
            LocalForecast *fourthForecast;
            
            if (forecasts.count == 4) {
                firstForecast    = forecasts[0];
                secondForecast   = forecasts[1];
                thirdForecast    = forecasts[2];
                fourthForecast   = forecasts[3];
            }
            else if (forecasts.count == 3) {
                secondForecast   = forecasts[0];
                thirdForecast    = forecasts[1];
                fourthForecast   = forecasts[2];
            }
            else if (forecasts.count == 2) {
                thirdForecast   = forecasts[0];
                fourthForecast  = forecasts[1];
            }
            else if (forecasts.count == 1) {
                fourthForecast  = forecasts[0];
            }
            
            [cell.firstForecast.hour setText:[firstForecast.date formattedDateWithFormat:@"HH" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]]];
            
            [cell.firstForecast.waveIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWaveWithHeight:firstForecast.waveHeight]]];
            cell.firstForecast.waveDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([firstForecast.waveDirection floatValue]));
            [cell.firstForecast.waveSignificative setText:[NSString stringWithFormat:@"%.01f", (firstForecast.waveHeight.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.firstForecast.waveMax setText:[NSString stringWithFormat:@"%.01f", (firstForecast.waveHeightMax.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.firstForecast.wavePeriod setText:[NSString stringWithFormat:@"%i", (int)roundf(firstForecast.wavePeriod.floatValue)]];
            [cell.firstForecast.windIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWindWithSpeed:firstForecast.windSpeed]]];
            cell.firstForecast.windDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([firstForecast.windDirection floatValue]));
            [cell.firstForecast.windSpeed setText:[NSString stringWithFormat:@"%.01f", (firstForecast.windSpeed.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            [cell.firstForecast.windBurst setText:[NSString stringWithFormat:@"%.01f", (firstForecast.windBurst.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            cell.firstForecast.waveDirectionText.text   = [firstForecast waveDirectionText];
            cell.firstForecast.windDirectionText.text   = [firstForecast windDirectionText];
            
            [cell.secondForecast.hour setText:[secondForecast.date formattedDateWithFormat:@"HH" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]]];
            
            [cell.secondForecast.waveIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWaveWithHeight:secondForecast.waveHeight]]];
            cell.secondForecast.waveDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([secondForecast.waveDirection floatValue]));
            [cell.secondForecast.waveSignificative setText:[NSString stringWithFormat:@"%.01f", (secondForecast.waveHeight.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.secondForecast.waveMax setText:[NSString stringWithFormat:@"%.01f", (secondForecast.waveHeightMax.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.secondForecast.wavePeriod setText:[NSString stringWithFormat:@"%i", (int)roundf(secondForecast.wavePeriod.floatValue)]];
            [cell.secondForecast.windIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWindWithSpeed:secondForecast.windSpeed]]];
            cell.secondForecast.windDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([secondForecast.windDirection floatValue]));
            [cell.secondForecast.windSpeed setText:[NSString stringWithFormat:@"%.01f", (secondForecast.windSpeed.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            [cell.secondForecast.windBurst setText:[NSString stringWithFormat:@"%.01f", (secondForecast.windBurst.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            cell.secondForecast.waveDirectionText.text   = [secondForecast waveDirectionText];
            cell.secondForecast.windDirectionText.text   = [secondForecast windDirectionText];
            
            [cell.thirdForecast.hour setText:[thirdForecast.date formattedDateWithFormat:@"HH" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]]];
            
            [cell.thirdForecast.waveIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWaveWithHeight:thirdForecast.waveHeight]]];
            cell.thirdForecast.waveDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([thirdForecast.waveDirection floatValue]));
            [cell.thirdForecast.waveSignificative setText:[NSString stringWithFormat:@"%.01f", (thirdForecast.waveHeight.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.thirdForecast.waveMax setText:[NSString stringWithFormat:@"%.01f", (thirdForecast.waveHeightMax.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.thirdForecast.wavePeriod setText:[NSString stringWithFormat:@"%i", (int)roundf(thirdForecast.wavePeriod.floatValue)]];
            [cell.thirdForecast.windIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWindWithSpeed:thirdForecast.windSpeed]]];
            cell.thirdForecast.windDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([thirdForecast.windDirection floatValue]));
            [cell.thirdForecast.windSpeed setText:[NSString stringWithFormat:@"%.01f", (thirdForecast.windSpeed.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            [cell.thirdForecast.windBurst setText:[NSString stringWithFormat:@"%.01f", (thirdForecast.windBurst.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            cell.thirdForecast.waveDirectionText.text   = [thirdForecast waveDirectionText];
            cell.thirdForecast.windDirectionText.text   = [thirdForecast windDirectionText];
            
            [cell.fourthForecast.hour setText:[fourthForecast.date formattedDateWithFormat:@"HH" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]]];
            
            [cell.fourthForecast.waveIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWaveWithHeight:fourthForecast.waveHeight]]];
            cell.fourthForecast.waveDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([fourthForecast.waveDirection floatValue]));
            [cell.fourthForecast.waveSignificative setText:[NSString stringWithFormat:@"%.01f", (fourthForecast.waveHeight.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.fourthForecast.waveMax setText:[NSString stringWithFormat:@"%.01f", (fourthForecast.waveHeightMax.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.fourthForecast.wavePeriod setText:[NSString stringWithFormat:@"%i", (int)roundf(fourthForecast.wavePeriod.floatValue)]];
            [cell.fourthForecast.windIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWindWithSpeed:fourthForecast.windSpeed]]];
            cell.fourthForecast.windDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([fourthForecast.windDirection floatValue]));
            [cell.fourthForecast.windSpeed setText:[NSString stringWithFormat:@"%.01f", (fourthForecast.windSpeed.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            [cell.fourthForecast.windBurst setText:[NSString stringWithFormat:@"%.01f", (fourthForecast.windBurst.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            cell.fourthForecast.waveDirectionText.text   = [fourthForecast waveDirectionText];
            cell.fourthForecast.windDirectionText.text   = [fourthForecast windDirectionText];
            
            return cell;
            
            break;
        }
            
        case LocalForecastSectionRegion: {
            MIOLocalForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forecastCell" forIndexPath:indexPath];
            
            //Obtener llaves del diccionario y ordenarlas
            NSArray *dates = [[self.forecasts allKeys] mutableCopy];
            dates = [dates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            //Contar la cantidad de pronósticos hasta la sección actual
            int rowCount = 0;
            for (int i = 0; i < indexPath.section; ++i) {
                rowCount += [[self.forecasts objectForKey:dates[i]] integerValue];
            }
            
            LocalForecast *forecast = [self.localForecasts objectAtIndex:(rowCount + indexPath.row)];
            
            [cell.hour setText:[forecast.date formattedDateWithFormat:@"HH" locale:[NSLocale localeWithLocaleIdentifier:@"en-US"]]];
            
            [cell.waveIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWaveWithHeight:forecast.waveHeight]]];
            cell.waveDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([forecast.waveDirection floatValue]));
            [cell.waveSignificative setText:[NSString stringWithFormat:@"%.01f", (forecast.waveHeight.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.waveMax setText:[NSString stringWithFormat:@"%.01f", (forecast.waveHeightMax.floatValue * (self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier))]];
            [cell.wavePeriod setText:[NSString stringWithFormat:@"%.01f", forecast.wavePeriod.floatValue]];
            [cell.windIcon setImage:[UIImage imageNamed:[MIOLocalForecastUtils imageNameForWindWithSpeed:forecast.windSpeed]]];
            cell.windDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS([forecast.windDirection floatValue]));
            [cell.windSpeed setText:[NSString stringWithFormat:@"%.01f", (forecast.windSpeed.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            [cell.windBurst setText:[NSString stringWithFormat:@"%.01f", (forecast.windBurst.floatValue * (self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier))]];
            
            return cell;
            
            break;
        }
            
        default:
            return nil;
            break;
    }
    
}

#pragma mark - DataSource

-(void)reloadDatasourceData {
    LocalForecast *lastForecast = [[[LocalForecast allObjects] sortedResultsUsingKeyPath:@"date" ascending:NO] firstObject];

    NSDate *lastDate;

    if (lastForecast) {
        lastDate    = [NSDate dateWithYear:lastForecast.date.year month:lastForecast.date.month day:lastForecast.date.day - 1 hour:59 minute:59 second:59];
    }
    else {
        lastDate = [[NSDate date] dateByAddingWeeks:1];

        lastDate    = [NSDate dateWithYear:lastDate.year month:lastDate.month day:lastDate.day hour:59 minute:59 second:59];
    }

    NSDate *startDate   = [lastDate dateBySubtractingWeeks:1];
    startDate           = [NSDate dateWithYear:startDate.year month:startDate.month day:startDate.day hour:0 minute:0 second:0];

    NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"localForecast == %@ AND date <= %@ AND date >= %@", self.region.identifier, lastDate, startDate];

    self.localForecasts = [[LocalForecast objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"date" ascending:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LocalForecastComment"]) {
        
        ((MIOLocalForecastCommentViewController *)segue.destinationViewController).commentContent   = self.region.comment;
        ((MIOLocalForecastCommentViewController *)segue.destinationViewController).forecastRegion   = self.region;
        
        NSDate *startingDate    = ((LocalForecast *)self.localForecasts[0]).date;
        NSDate *endDate         = ((LocalForecast *)[self.localForecasts lastObject]).date;
        
        ((MIOLocalForecastCommentViewController *)segue.destinationViewController).validThruStart   = startingDate;
        ((MIOLocalForecastCommentViewController *)segue.destinationViewController).validThruEnd     = endDate;
    }
}

- (IBAction)displayHelp:(UIBarButtonItem *)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case LocalForecastSectionComments:
            [self performSegueWithIdentifier:CommentsHelpSegueIdentifier sender:self];
            break;
            
        case LocalForecastSectionForecast:
            [self performSegueWithIdentifier:ForecastsHelpSegueIdentifier sender:self];
            break;
            
        case LocalForecastSectionRegion:
            break;
            
        default:
            break;
    }
}

- (void)presentLoadingView {
    [self.commentButton setTitle:@"" forState:UIControlStateNormal];
    self.commentButton.userInteractionEnabled   = NO;
    self.activityIndicator.hidden   = NO;
    [self.activityIndicator startAnimating];
}

- (void)dismissLoadingView {
    self.activityIndicator.hidden   = YES;
    self.commentButton.userInteractionEnabled   = YES;
    [self.activityIndicator stopAnimating];
    [self.commentButton setTitle:LocalizedString(@"local-forecast-comment") forState:UIControlStateNormal];
}

-(void) refreshData {
    [self.refreshControl beginRefreshing];
    [self updateViewData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
