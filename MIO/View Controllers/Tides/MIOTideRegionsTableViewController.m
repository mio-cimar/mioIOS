//
//  TideRegionsTableViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOTideRegionsTableViewController.h"
#import "MIOTideForecastViewController.h"

#import "TideRegion.h"

#import "MIOLocalForecastRegionTableViewCell.h"
#import "MIOLocalForecastHeaderView.h"

#import "MIOAPI.h"
#import <DateTools/DateTools.h>
#import <Haneke/Haneke.h>

@interface MIOTideRegionsTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) MIOSettingsLanguages selectedLanguage;
//@property (strong, nonatomic)   NSFetchedResultsController *dataController;
@property (strong, nonatomic)   APIClient *apiClient;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic)     IBOutlet UITableView *tableView;
@property (nonatomic)       NSInteger numberOfTideForecastsToFetch;
@property (nonatomic)       NSInteger numberOfTideForecastsFetched;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstntLoadingViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *loadingViewMessage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property RLMResults<TideRegion *> *tideRegions;

@end

@implementation MIOTideRegionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tideRegions = [[TideRegion allObjects] sortedResultsUsingKeyPath:@"order" ascending:YES];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    self.tableView.tableFooterView = [UIView new];
    [self dismissLoadingView];
    
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    
    [self reloadTableData];
    self.apiClient                  = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    [self loadData:NO];
    
    self.title  = LocalizedString(@"tide-regions-title");
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = self.title;
        self.navigationItem.titleView = [[UIView alloc] init];
    }
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
    [MIOAnalyticsManager trackScreen:@"Tide region list" screenClass:[self.classForCoder description]];
}

- (void)languageChanged:(NSNotification *)notification {
    self.title  = LocalizedString(@"tide-regions-title");
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.tableView reloadData];
}

- (void) loadData:(BOOL) isRefreshing {
    NSDate *dataRetrievalTimeStamp  = [[NSUserDefaults standardUserDefaults] objectForKey:TideRegionsDataRetrievalTimestampKey];
    NSDate *today                   = [NSDate date];

    if (today.day != dataRetrievalTimeStamp.day || isRefreshing == YES) {
        if(isRefreshing == NO) {
            [self presentLoadingView];
        }

        [TideRegion apiClient:self.apiClient tideRegionsWithCallback:^(APIResponse * _Nonnull response) {
            [self.refreshControl endRefreshing];
            if (response.success) {
                NSDate *reference   = [NSDate dateWithYear:today.year month:today.month day:today.day hour:today.hour minute:today.minute second:today.second];

                NSDate *start   = [reference dateBySubtractingWeeks:1];
                NSDate *end     = [reference dateByAddingMonths:2];
                [TideRegion saveTideRegionsDictionaryRepresentationToStorage:response.mappedResponse];
                [self reloadTableData];

                self.numberOfTideForecastsToFetch   = self.tideRegions.count;
                self.numberOfTideForecastsFetched   = 0;
                [self.refreshControl endRefreshing];
                for (TideRegion *region in self.tideRegions) {
                    region.isPerformingFetch    = YES;

                    [region apiClient:self.apiClient tideEntriesFromDate:start toDate:end withCallback:^(APIResponse *_Nonnull response) {

                        region.isPerformingFetch = NO;

                        self.numberOfTideForecastsFetched++;

                        if (self.numberOfTideForecastsFetched == self.numberOfTideForecastsToFetch) {
                            [self dismissLoadingView];
                        }
                        region.isPerformingFetch = NO;
                        if (response.success) {
                            [TideRegion saveTideEntriesDictionaryRepresentationToStorage:response.mappedResponse];
                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:TideRegionsDataRetrievalTimestampKey];
                        }
                        else if (response.statusCode == APIResponseStatusCodeNotConnectedToInternet) {
                            [self presentInformationMessage:LocalizedString(@"no-internet-connectivity-message")];
                        }
                    }];
                }
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


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MIOLocalForecastRegionTableViewCell *cell                       = [tableView dequeueReusableCellWithIdentifier:@"TideRegionCell"];
    
    TideRegion *tideRegion  = self.tideRegions[indexPath.row];
    
    cell.label.text         = self.selectedLanguage == MIOSettingsLanguageEnglish ? tideRegion.englishName : tideRegion.name;
    cell.accessoryType      = UITableViewCellAccessoryDisclosureIndicator;
    switch (tideRegion.identifier.integerValue) {
        case 38:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_golfo_elena.pdf"]];
            break;
        case 35:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_bahia_culebra.pdf"]];
            break;
        case 42:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_puntarenas.pdf"]];
            break;
        case 40:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_puerto_herradura.pdf"]];
            break;
        case 41:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_quepos.pdf"]];
            break;
        case 36:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_bahia_uvita.pdf"]];
            break;
        case 37:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_golfito.pdf"]];
            break;
        case 39:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_ilsa_del_coco.pdf"]];
            break;
        case 43:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_limon.pdf"]];
            break;
        default:
            [cell.icon setImage:[UIImage imageNamed:@"mapa_mini_pacifico_central.pdf"]];
            break;
    }


    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tideRegions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TideRegion *region  = self.tideRegions[indexPath.row];
    
    [self performSegueWithIdentifier:@"TideDetail" sender:region];
}

-(void)reloadTableData
{
    self.tideRegions = [[TideRegion allObjects] sortedResultsUsingKeyPath:@"order" ascending:YES];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TideDetail"]) {
        
        ((MIOTideForecastViewController *)segue.destinationViewController).tideRegion = sender;
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
    [self.loadingViewMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loadingViewMessage.backgroundColor     = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.cnstntLoadingViewHeight.constant   = 49.0f;
    
    [self.loadingViewMessage setTitle:message forState:UIControlStateNormal];
    self.loadingView.tintColor  = [UIColor whiteColor];
    
    self.activityIndicator.hidden   = YES;
    [self.activityIndicator stopAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(dismissLoadingView) userInfo:nil repeats:NO];
}

-(void) refreshData {
    [self loadData:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
