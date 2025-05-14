//
//  TouristInfoViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "TouristInfoViewController.h"
#import "TouristInfoDetailViewController.h"
#import "TouristInfoHeader.h"
#import "TouristInfoFooter.h"
#import "MFInformation.h"
#import "MFLink.h"
#import "MFImage.h"
#import "ForecastHeader.h"
@import Firebase;

@interface TouristInfoViewController () < InfoHeaderSelectionDelegate>

@property (nonatomic) TouristInfoHeader *header;
@property (nonatomic) TouristInfoFooter *footer;
@property (nonatomic, readwrite) FIRFirestore *db;
@property (strong, nonatomic) NSArray<MFLink *> *links;
@property (strong, nonatomic) MFInformation *selectedInfo;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation TouristInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.db = [FIRFirestore firestore];
    [self configureUI];
    self.links = [[NSArray alloc] init];
    [self loadData];
}

-(void) configureUI {

    self.title = [LocalizedString(@"tourist-info") capitalizedString];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.activityIndicator];
    [[self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor] setActive:YES];
    [[self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor] setActive:YES];
    [self.tableView layoutIfNeeded];
    self.header = [[TouristInfoHeader alloc] init];
    self.footer = [[TouristInfoFooter alloc] init];
    self.header.delegate = self;
}

- (void) loadData {
    [self showProgress];
    [self readInformation:NO];
}

- (void) readInformation: (BOOL) isRefreshing {
    [[self.db collectionWithPath:@"MFInformation"] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        NSMutableArray<MFInformation *> *array = [[NSMutableArray alloc] init];
        if (error == nil) {
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                if(document != nil && document.exists){
                    MFInformation *information = [[MFInformation alloc] initWith:document];
                    if(information && information.isActive == [NSNumber numberWithBool:YES]) {
                        [array addObject:information];
                    }
                }
            }
            [[self.db collectionWithPath:@"MFImage"] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
                if (error == nil) {
                    for(MFInformation *information in array) {
                        NSMutableArray<MFImage *> *imagesForInformation = [[NSMutableArray alloc] init];
                            for(FIRDocumentSnapshot *docImg in snapshot.documents) {
                                if([information.image containsString:docImg.documentID]) {
                                    MFImage *img = [[MFImage alloc] initWith:docImg];
                                    [imagesForInformation addObject:img];
                                }
                            }
                        information.mfImage = [imagesForInformation firstObject];
                    }
                    [self addHeader:array :isRefreshing];
                    [self readLinks];
                }
            }];
        }
    }];
}

- (void) readLinks {
    [[self.db collectionWithPath:@"MFLink"] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error == nil) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for(FIRDocumentSnapshot *link in snapshot.documents) {
                if(link.exists) {
                    MFLink *mfLink = [[MFLink alloc] initWith:link];
                    if(link) {
                        [array addObject:mfLink];
                    }
                    NSSortDescriptor *sortDescriptor;
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order"
                                                                 ascending:YES];
                    self.links = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self hideProgress];
                    });
                }
            }
        }
    }];
}

-(void) addHeader:(NSArray<MFInformation *>*)information : (BOOL) isRefreshing {
    if(isRefreshing){
        [self.header populateWith:information];
    } else {
        self.header.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.tableHeaderView = self.header;
        [[self.header.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor] setActive:YES];
        [[self.header.widthAnchor constraintEqualToAnchor:self.tableView.widthAnchor] setActive:YES];
        [self.header populateWith:information];
        [self.header setNeedsLayout];
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.links.count == 0) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.links.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];
    MFLink *link  = self.links[indexPath.row];
    cell.textLabel.text                         = link.title;
    cell.textLabel.font                         = [UIFont fontWithName:@"SFUIText-Regular" size:17.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:0.01 green:0.52 blue:0.26 alpha:1];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ForecastHeader *header = [[ForecastHeader alloc] init];
    header.title.text = LocalizedString(@"tourist-info-links");
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 225;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MFLink *link = self.links[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *finalUrlString = link.url;
    if (![link.url containsString:@"http://"] && ![link.url containsString:@"https://"]) {
        finalUrlString = [NSString stringWithFormat:@"http://%@", link.url];
    }
    NSURL *url = [NSURL URLWithString:finalUrlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:LocalizedString(@"unable-to-open-link") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void) showProgress {
    [self.activityIndicator startAnimating];
}

-(void) hideProgress {
    [self.activityIndicator stopAnimating];
}

- (void)itemSelected:(MFInformation *)information {
    self.selectedInfo = information;
    [self performSegueWithIdentifier:@"TouristInfoDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TouristInfoDetail"]) {
        TouristInfoDetailViewController *detail = segue.destinationViewController;
        if(detail) {
            detail.information = self.selectedInfo;
        }
    }
}

-(void) refreshData {
    [self readInformation:YES];
}
@end
