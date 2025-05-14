//
//  MIOWarningsViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/14/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOWarningsViewController.h"
#import "MIOWarningViewController.h"
#import "MainTabBarViewController.h"
#import "IntroViewController.h"
#import "Warning.h"
#import "MIOWarningTableViewCell.h"
#import "MIOAPI.h"
#import <DateTools/DateTools.h>
#import <Realm/Realm.h>

static NSString *const kTutorialCompletedKey = @"TutorialCompleted";

@interface MIOWarningsViewController () <NSFetchedResultsControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) NSMutableArray *introPages;
@property (strong, nonatomic) NSArray *introDescriptionStrings;
@property (strong, nonatomic) NSArray *introTitleStrings;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) APIClient *apiClient;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loadingViewMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnstntLoadingViewHeight;
@property (weak, nonatomic) IBOutlet UIView *segmentedViewContainer;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIPageViewController *pageController;
@property RLMResults<Warning *> *warnings;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) CGPoint lastOffset;
@end

@implementation MIOWarningsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    self.tableView.tableFooterView = [UIView new];
    self.lastOffset = self.tableView.contentOffset;
    self.apiClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIURL]];
    [self reloadDatasourceDataForWarningsLevel:100];
    [self.tableView reloadData];
    [self loadData:NO];
    
    [self.segmentedControl addTarget:self action:@selector(didSwitchNotificationsView) forControlEvents:UIControlEventValueChanged];
    
    self.selectedLanguage            = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    
    [self.segmentedControl setTitle:LocalizedString(@"warnings-first-segment") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"warnings-second-segment") forSegmentAtIndex:1];
    [self.segmentedControl setTitle:LocalizedString(@"warnings-third-segment") forSegmentAtIndex:2];
    NSString *viewControllerTitle = LocalizedString(@"warnings-list-title");
    self.navigationItem.title = viewControllerTitle;
    self.title = viewControllerTitle;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [MIOAnalyticsManager trackScreen:@"Notification list" screenClass:[self.classForCoder description]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageChanged:)
                                                 name:kMIOLanguageModifiedKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomeActive:)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:nil];
}

-(void) applicationDidBecomeActive:(NSNotification *)notification {
    [self checkForNotificationArrived];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.lastOffset = self.tableView.contentOffset;
    [self.refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    [self.segmentedViewContainer setNeedsLayout];
    [self.segmentedViewContainer layoutIfNeeded];
    [self.tableView setContentOffset:self.lastOffset animated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkForNotificationArrived];
}

- (void) setupTitles {
    NSString *viewControllerTitle = LocalizedString(@"warnings-list-title");
    self.title = viewControllerTitle;
    [self.segmentedControl setTitle:LocalizedString(@"warnings-first-segment") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"warnings-second-segment") forSegmentAtIndex:1];
    [self.segmentedControl setTitle:LocalizedString(@"warnings-third-segment") forSegmentAtIndex:2];
}

- (void)languageChanged:(NSNotification *)notification {
    [self setupTitles];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStylePlain target:nil action:nil];
    self.selectedLanguage  = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.tableView reloadData];
}

- (void) checkForNotificationArrived {
    NSNumber *notification = ((MainTabBarViewController *)self.navigationController.tabBarController).notificationToPresent;
    if([notification intValue] != 0) {
        ((MainTabBarViewController *)self.navigationController.tabBarController).notificationToPresent = 0;
        [self presentNotificationDetailWithIdentifier:notification];
    }
}

- (void) loadData:(BOOL) isRefreshing {

    NSDate *warningsRetrievalTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:WarningsDataRetrievalTimestampKey];

    if (!warningsRetrievalTimestamp || [[NSDate date] minutesFrom:warningsRetrievalTimestamp] >= 5 || isRefreshing == YES) {

        if(isRefreshing == NO) {
            [self presentLoadingView];
        }

        [Warning apiClient:self.apiClient warningsWithCallback:^(APIResponse * _Nonnull response) {
            if (response.success) {
                [self dismissLoadingView];
                [Warning saveWarningsDictionaryRepresentationToStorage:response.mappedResponse];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:WarningsDataRetrievalTimestampKey];

                switch (self.segmentedControl.selectedSegmentIndex) {
                    case 0:
                        [self reloadDatasourceDataForWarningsLevel:100];
                        break;
                    case 1:
                        [self reloadDatasourceDataForWarningsLevel:1];
                        break;
                    case 2:
                        [self reloadDatasourceDataForWarningsLevel:0];
                        break;
                    default:
                        break;
                }
                [self.tableView reloadData];
            }
            else if (response.statusCode == APIResponseStatusCodeNotConnectedToInternet) {
                [self presentInformationMessage:LocalizedString(@"no-internet-connectivity-message")];
            }
            else {
                [self dismissLoadingView];
            }
            [self.refreshControl endRefreshing];
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didSwitchNotificationsView {
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self reloadDatasourceDataForWarningsLevel:100];
            [self.tableView reloadData];
            if(_refreshControl.isRefreshing) {
                [self.refreshControl beginRefreshing];
            }
            break;
        case 1:
            [self reloadDatasourceDataForWarningsLevel:1];
            [self.tableView reloadData];
            if(_refreshControl.isRefreshing) {
                [self.refreshControl beginRefreshing];
            }
            break;
        case 2:
            [self reloadDatasourceDataForWarningsLevel:0];
            [self.tableView reloadData];
            if(_refreshControl.isRefreshing) {
                [self.refreshControl beginRefreshing];
            }
            break;
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.warnings.count >= 10 ? 10 : self.warnings.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"WarningDetail" sender:self.warnings[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell   = [UITableViewCell new];
    
    cell                    = [self.tableView dequeueReusableCellWithIdentifier:@"WarningCell"];
    
    Warning *warning        = self.warnings[indexPath.row];
    
    MIOWarningTableViewCell *warningCell    = (MIOWarningTableViewCell *)cell;
    
    warningCell.warningTitleLabel.text      = warning.title;
    warningCell.warningDetailLabel.text     = warning.subtitle;
    
    NSString *imageName                     = [warning.level integerValue] == 0 ? @"advertencia-verde" : [warning.level integerValue] == 1 ? @"advertencia-amarilla" : @"advertencia-roja";
    
    warningCell.warningImage.image          = [UIImage imageNamed:imageName];
    warningCell.warningDateLabel.text       = [warning.date formattedDateWithFormat:self.selectedLanguage == MIOSettingsLanguageEnglish ?  @"MMMM d, yyyy | h a" : @"d MMMM, yyyy | h a" timeZone:[NSTimeZone localTimeZone] locale:[NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ?  @"en_US" : @"es_ES"]];
    
    
    return cell;
}

#pragma mark - DataSource

-(void)reloadDatasourceDataForWarningsLevel:(NSInteger)level
{
    if (level == 0) {
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"level == %@", @(level)];

        self.warnings = [[Warning objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"date" ascending:NO];
    }
    else if (level == 1) {
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"level >= %@", @(level)];
        self.warnings = [[Warning objectsWithPredicate:predicate] sortedResultsUsingKeyPath:@"date" ascending:NO];
    }
    else {
        self.warnings = [[Warning allObjects] sortedResultsUsingKeyPath:@"date" ascending:NO];
    }
    self.warnings = self.warnings;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WarningDetail"]) {
        ((MIOWarningViewController *)segue.destinationViewController).warning = sender;
    }
}

- (void)presentNotificationDetailWithIdentifier:(NSNumber *)identifier {
    if ([self.navigationController.topViewController isKindOfClass:[MIOWarningViewController class]]){
        MIOWarningViewController *warningsViewController = (MIOWarningViewController *) self.navigationController.topViewController;
        if(warningsViewController.warning.identifier.integerValue == identifier.integerValue) {
            return;
        }
    }
    Warning *warningToPresent = [Warning objectForPrimaryKey:identifier];
    if (warningToPresent) {
        [self performSegueWithIdentifier:@"WarningDetail" sender:warningToPresent];
    } else {
        [self presentLoadingView];
        [Warning apiClient:self.apiClient warningsWithCallback:^(APIResponse * _Nonnull response) {
            if (response.success) {
                [self dismissLoadingView];
                [Warning saveWarningsDictionaryRepresentationToStorage:response.mappedResponse];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:WarningsDataRetrievalTimestampKey];

                switch (self.segmentedControl.selectedSegmentIndex) {
                    case 0:
                        [self reloadDatasourceDataForWarningsLevel:100];
                        break;
                    case 1:
                        [self reloadDatasourceDataForWarningsLevel:1];
                        break;
                    case 2:
                        [self reloadDatasourceDataForWarningsLevel:0];
                        break;
                    default:
                        break;
                }
                [self.tableView reloadData];
                Warning *warningToPresent   = [Warning objectForPrimaryKey:identifier];
                if(warningToPresent) {
                    [self performSegueWithIdentifier:@"WarningDetail" sender:warningToPresent];
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

- (void)presentLoadingView {
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    self.activityIndicator.hidden   = NO;
    [self.activityIndicator startAnimating];
    self.isRefreshing = YES;
}

- (void)dismissLoadingView {
    [self.refreshControl endRefreshing];
    self.loadingView.hidden = YES;
    self.cnstntLoadingViewHeight.constant   = 0;
    [self.activityIndicator stopAnimating];
    self.isRefreshing = NO;
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
    [self loadData:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
