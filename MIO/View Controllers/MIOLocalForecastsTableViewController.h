//
//  LocalForecastsTableViewController.h
//  MIO
//
//  Created by Alonso Vega on 6/16/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocalForecastRegion.h"

@interface MIOLocalForecastsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *regionDisplay;
@property (nonatomic, strong) LocalForecastRegion *region;

@end
