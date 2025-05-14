//
//  LocalForecatsListTableViewController.m
//  MIO
//
//  Created by Alonso Vega on 6/24/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOLocalForecastsRegionTableViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MIORegionalForecastViewController.h"
#import "MIOLocalForecastsTableViewController.h"
#import "MIOLocalForecastRegionTableViewCell.h"
#import "LocalForecastRegion.h"
#import "RegionalForecastType.h"
#import "RegionalForecastTypeSlide.h"
#import "MIOAPI.h"
#import "MIOLocalForecastHeaderView.h"
#import "ForecastHeader.h"
#import <Haneke/Haneke.h>
#import <DateTools/DateTools.h>
#import <Realm/Realm.h>
#import "RegionalForecastTableViewCell.h"

@interface MIOLocalForecastsRegionTableViewController () <NSFetchedResultsControllerDelegate, MIORegionalForecastViewControllerDelegate, UITableViewDelegate>

@property (nonatomic, strong) LocalForecastRegion *selectedRegion;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) APIClient *apiClient;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loadingViewMessage;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstntLoadingViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic)       NSInteger numberOfLocalForecastsToFetch;
@property (nonatomic)       NSInteger numberOfLocalForecastsFetched;
@property (strong, nonatomic) NSArray *outdatedRegionalForecastTypeSlides;
@property (nonatomic) __block BOOL newSlidesDataArrived;
@property (strong, nonatomic) NSMutableDictionary *regionalForecastTypeSlidesByRegionBeforeUpdate;
@property (weak, nonatomic) RegionalForecastType *currentlyDisplayedRegionalForecastType;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property RLMResults<LocalForecastRegion *> *localForecastRegions;
@property RLMResults<RegionalForecastType *> *regionalForecasts;
@property (strong, nonatomic) UIColor *defaultSeparatorColor;

@end

@implementation MIOLocalForecastsRegionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocalizedStrings];
    self.localForecastRegions = [[LocalForecastRegion allObjects] sortedResultsUsingKeyPath:@"order" ascending:YES];
    self.regionalForecasts =  [[RegionalForecastType allObjects] sortedResultsUsingKeyPath:@"identifier" ascending:NO];
    [self dismissLoadingView];
    self.apiClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    [self.segmentedControl addTarget:self action:@selector(didSwitchSegmentedControl) forControlEvents:UIControlEventValueChanged];
    [self configureUI];
    self.outdatedRegionalForecastTypeSlides             = @[];
    self.regionalForecastTypeSlidesByRegionBeforeUpdate = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [self.tableView reloadData];
    [self fetchLocalForecasts:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
}

- (void) configureUI {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    self.defaultSeparatorColor = [[[UITableView alloc] init] separatorColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.tableView.separatorColor = UIColor.clearColor;
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    }
}

- (void)languageChanged:(NSNotification *)notification {
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.apiClient.requestSerializer setValue:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en" : @"es" forHTTPHeaderField:@"Accept-Language"];
    [self setupLocalizedStrings];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.tableView reloadData];
    [self fetchLocalForecasts:YES];
}

- (void) setupLocalizedStrings {
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-title") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"regional-forecast-regions-title") forSegmentAtIndex:1];
    NSString *viewControllerTitle = LocalizedString(@"forecasts-title");
    self.title = viewControllerTitle;
}

- (void) fetchLocalForecasts:(BOOL) isRefreshing {
    NSDate *localForecastTimestamp  = [[NSUserDefaults standardUserDefaults] objectForKey:LocalForecastDataRetrievalTimestampKey];
    BOOL languageModified           = [[NSUserDefaults standardUserDefaults] boolForKey:kMIOLanguageModifiedKey];

    if (!localForecastTimestamp || [[NSDate date] minutesFrom:localForecastTimestamp] >= 5 || languageModified || isRefreshing == YES) {

        [self presentLoadingView];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kMIOLanguageModifiedKey];

        [LocalForecastRegion apiClient:self.apiClient localForecastRegionsWithCallback:^(APIResponse * _Nonnull response) {
            if (response.success) {
                [LocalForecastRegion saveLocalForecastRegionsDictionaryRepresentationToStorage:response.mappedResponse];

                self.numberOfLocalForecastsToFetch  = self.localForecastRegions.count;
                self.numberOfLocalForecastsFetched  = 0;

                for (LocalForecastRegion *region in self.localForecastRegions) {
                    region.isPerformingFetch = YES;

                    [region apiClient:self.apiClient localForecastWithCallback:^(APIResponse * _Nonnull response) {
                        region.isPerformingFetch    = NO;

                        self.numberOfLocalForecastsFetched++;

                        if (self.numberOfLocalForecastsFetched == self.numberOfLocalForecastsToFetch) {
                        [self dismissLoadingView];
                        }

                        if (response.success) {
                            [LocalForecastRegion saveLocalForecastsDictionaryRepresentationToStorage:response.mappedResponse];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LocalForecastDataRetrievalTimestampKey];
                        }
                    }];
                }
                [self reloadDataSource];
                [self.tableView reloadData];
                [self fetchRegionalForecasts];
            }
            else if (response.statusCode == APIResponseStatusCodeNotConnectedToInternet) {
                [self presentInformationMessage:LocalizedString(@"no-internet-connectivity-message")];
            }
            else {
                [self dismissLoadingView];
            }
        }];
    }
}

- (void) fetchRegionalForecasts {
    [self presentLoadingView];

    [RegionalForecastType apiClient:self.apiClient regionalForecastTypesWithCallback:^(APIResponse * _Nonnull response) {
        if (response.success) {
            [self dismissLoadingView];

            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:RegionalForecastsDataRetrievalTimestampKey];

            for (RegionalForecastType *regionalForecastType in self.regionalForecasts) {
                NSMutableArray *regionalForecastTypeSlidesForRegionBeforeUpdate = [NSMutableArray arrayWithArray:@[]];

                for (RegionalForecastTypeSlide *slide in regionalForecastType.slides) {
                    [regionalForecastTypeSlidesForRegionBeforeUpdate addObject:slide.identifier];
                }

                self.regionalForecastTypeSlidesByRegionBeforeUpdate[[NSString stringWithFormat:@"%@", regionalForecastType.identifier]] = regionalForecastTypeSlidesForRegionBeforeUpdate;
            }
            [RegionalForecastType saveRegionalForecastTypesDictionaryRepresentationToStorage:response.mappedResponse];
            [self reloadDataSource];

            RegionalForecastType *updatedCurrentlyDisplayedRegionalForecastType;

            for (RegionalForecastType *regionalForecastType in self.regionalForecasts) {
                if ([regionalForecastType.identifier integerValue] == [self.currentlyDisplayedRegionalForecastType.identifier integerValue]) {
                    updatedCurrentlyDisplayedRegionalForecastType = regionalForecastType;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissLoadingView];
                [self.tableView reloadData];
            });
        }
        else if (response.statusCode == APIResponseStatusCodeNotConnectedToInternet) {
            [self dismissLoadingView];
            [self presentInformationMessage:LocalizedString(@"no-internet-connectivity-message")];
        }
        else {
            [self dismissLoadingView];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        return self.localForecastRegions.count;
    } else {
        return self.regionalForecasts.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_segmentedControl.selectedSegmentIndex == 0) {
        return 78.0f;
    }else {
        return 45.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_segmentedControl.selectedSegmentIndex == 0) {
        MIOLocalForecastRegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionCell" forIndexPath:indexPath];
        cell.divider.backgroundColor = self.defaultSeparatorColor;
        LocalForecastRegion *region = self.localForecastRegions[indexPath.row];
        [cell.label setText:self.selectedLanguage == MIOSettingsLanguageEnglish ? region.englishName : region.name];
        switch (region.identifier.integerValue) {
            case 10:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_pacifico_norte_norte.pdf"]];
                break;
            case 11:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_pacifico_norte_centro.pdf"]];
                break;
            case 12:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_pacifico_norte_sur.pdf"]];
                break;
            case 13:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_puntarenas.pdf"]];
                break;
            case 14:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_pacifico_central.pdf"]];
                break;
            case 15:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_golfito.pdf"]];
                break;
            case 16:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_limon.pdf"]];
                break;
            case 9:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_ilsa_del_coco.pdf"]];
                break;
            default:
                [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_pacifico_central.pdf"]];
                break;
        }
        return cell;
    } else {
        RegionalForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionalForecastTypeCell"];
        RegionalForecastType *regionalForecastType  = self.regionalForecasts[indexPath.row];
        cell.textLabel.text                         = self.selectedLanguage == MIOSettingsLanguageEnglish ? regionalForecastType.englishName : regionalForecastType.name;
        cell.textLabel.font                         = [UIFont fontWithName:@"SFUIText-Regular" size:17.0f];
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.69 blue:1 alpha:1];
        cell.accessoryType                          = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle                         = UITableViewCellSelectionStyleNone;
        cell.divider.backgroundColor = self.defaultSeparatorColor;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.segmentedControl.selectedSegmentIndex == 0){
        self.selectedRegion = self.localForecastRegions[indexPath.row];
        [self performSegueWithIdentifier:@"showForecast" sender:self];
    } else {
        RegionalForecastType *regionalForecastType              = self.regionalForecasts[indexPath.row];
        [self performSegueWithIdentifier:@"RegionalForecast" sender:regionalForecastType];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RegionalForecast"]) {

        ((MIORegionalForecastViewController *)segue.destinationViewController).forecast = sender;
        ((MIORegionalForecastViewController *)segue.destinationViewController).delegate = self;
        self.currentlyDisplayedRegionalForecastType = sender;
    } else {
        MIOLocalForecastsTableViewController *destination = segue.destinationViewController;
        destination.region = self.selectedRegion;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

-(void)reloadDataSource
{
    if (_segmentedControl.selectedSegmentIndex == 0) {
        self.localForecastRegions = [[LocalForecastRegion allObjects] sortedResultsUsingKeyPath:@"order" ascending: YES];
    } else {
        self.regionalForecasts = [[RegionalForecastType allObjects] sortedResultsUsingKeyPath:@"identifier" ascending:NO];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ForecastHeader *header = [[ForecastHeader alloc] init];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        header.title.text = LocalizedString(@"local-forecast-regions-first-section-title");
        header.divider.backgroundColor = nil;
    } else {
        header.title.text = LocalizedString(@"regional-forecast-regions-header");
        header.divider.backgroundColor = self.defaultSeparatorColor;
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 41;
    } else {
        return 0;
    }

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)didSwitchSegmentedControl {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self reloadDataSource];
            self.tableView.separatorInset = UIEdgeInsetsMake(0, 94, 0, 0);
            [self.tableView reloadData];
            [MIOAnalyticsManager trackScreen:@"Local forecast list" screenClass:[self.classForCoder description]];
            break;
        case 1:
            [self reloadDataSource];
            self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

- (void)presentLoadingView {
    [self.refreshControl beginRefreshing];
    self.activityIndicator.hidden   = NO;
    [self.activityIndicator startAnimating];
}

- (void)dismissLoadingView {
    [self.refreshControl endRefreshing];
    self.loadingView.hidden = YES;
    self.cnstntLoadingViewHeight.constant   = 0;
    [self.activityIndicator stopAnimating];
}

- (void)presentInformationMessage:(NSString *)message {
    self.loadingView.hidden = NO;
    self.cnstntLoadingViewHeight.constant   = 49.0f;
    [self.loadingViewMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loadingViewMessage.backgroundColor     = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    [self.loadingViewMessage setTitle:message forState:UIControlStateNormal];
    
    self.activityIndicator.hidden   = YES;
    [self.activityIndicator stopAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(dismissLoadingView) userInfo:nil repeats:NO];
}

-(void) refreshData {
    [self fetchLocalForecasts:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
