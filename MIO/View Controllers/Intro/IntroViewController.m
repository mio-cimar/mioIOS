//
//  IntroViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/13/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "IntroViewController.h"

#import "IntroPageViewcontroller.h"

NSInteger const kNumberOfPages = 3;

@interface IntroViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *introPages;
@property (strong, nonatomic) NSArray *introDescriptionStrings;
@property (strong, nonatomic) NSArray *introTitleStrings;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property   (nonatomic) NSInteger currentPageIndex;
@property   (nonatomic) NSInteger nextIndex;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.skipButton setTitle:LocalizedString(@"intro-skip-title") forState:UIControlStateNormal];
    
    self.introPages = [NSMutableArray arrayWithArray:@[]];
    
    for (int i = 0; i < kNumberOfPages; i++) {
        IntroPageViewcontroller *pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageViewController"];
        
        [self.introPages addObject:pageViewController];
        
        [self.navigationController addChildViewController:pageViewController];
    }
    
    self.introDescriptionStrings    = [NSArray arrayWithObjects:LocalizedString(@"intro-first-subtitle"), LocalizedString(@"intro-second-subtitle"), LocalizedString(@"intro-third-subtitle"), LocalizedString(@"intro-fourth-subtitle"), LocalizedString(@"intro-fifth-subtitle"), nil];
    
    self.introTitleStrings          = [NSArray arrayWithObjects:LocalizedString(@"intro-first-title"), LocalizedString(@"intro-second-title"), LocalizedString(@"intro-third-title"), LocalizedString(@"intro-fourth-title"), LocalizedString(@"intro-fifth-title"), nil];
    
    self.pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageController"];
    
    self.pageController.dataSource  = self;
    self.pageController.delegate    = self;
    
    IntroPageViewcontroller *page = self.introPages[0];
    
    page.titleContent       = self.introTitleStrings[0];
    page.descriptionContent = self.introDescriptionStrings[0];
    page.imageIdentifier    = [NSString stringWithFormat:@"intro-%d", 1];
    page.index              = 0;
    
    NSArray *viewControllers = [NSArray arrayWithObject:page];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
//    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    [self.view sendSubviewToBack:self.pageController.view];
    
    self.pageControl.numberOfPages  = self.introPages.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(IntroPageViewcontroller *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    IntroPageViewcontroller *page = self.introPages[index];
    
    page.titleContent       = self.introTitleStrings[index];
    page.descriptionContent = self.introDescriptionStrings[index];
    page.imageIdentifier    = [NSString stringWithFormat:@"intro-%u", index+1];
    page.index              = index;
    
    return page;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(IntroPageViewcontroller *)viewController index];
    
    index++;
    
    if (index == kNumberOfPages) {
        return nil;
    }
    
    IntroPageViewcontroller *page = self.introPages[index];
    
    page.titleContent       = self.introTitleStrings[index];
    page.descriptionContent = self.introDescriptionStrings[index];
    page.imageIdentifier    = [NSString stringWithFormat:@"intro-%u", index+1];
    page.index              = index;
    
    return page;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    IntroPageViewcontroller *pageContentView = (IntroPageViewcontroller *)pendingViewControllers[0];
    self.nextIndex = pageContentView.index;
//
//    self.skipButton.hidden          = pageContentView.index != 0;
//    
//    [self.forwardButton removeTarget:nil
//                       action:NULL
//             forControlEvents:UIControlEventAllEvents];
//    
//    if (pageContentView.index != self.introPages.count - 1) {
//        [self.forwardButton setTitle:@">" forState:UIControlStateNormal];
//        [self.forwardButton addTarget:self action:@selector(moveForward:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    else {
//        [self.forwardButton setTitle:LocalizedString(@"intro-forward-title") forState:UIControlStateNormal];
//        [self.forwardButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
//    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        self.currentPageIndex = self.nextIndex;
        
        self.pageControl.currentPage    = self.currentPageIndex;
        
        self.skipButton.hidden          = self.currentPageIndex == self.introPages.count - 1;
        
        [self.forwardButton removeTarget:nil
                                  action:NULL
                        forControlEvents:UIControlEventAllEvents];
        
        if (self.currentPageIndex != self.introPages.count - 1) {
            self.forwardButton.hidden = YES;
            [self.forwardButton setTitle:@"" forState:UIControlStateNormal];
            [self.forwardButton addTarget:self action:@selector(moveForward:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [self.forwardButton setTitle:LocalizedString(@"intro-forward-title") forState:UIControlStateNormal];
            self.forwardButton.hidden = NO;
            [self.forwardButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    self.nextIndex = self.currentPageIndex;
}

- (IBAction)dismiss:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)moveForward:(UIButton *)sender {
    NSInteger index = self.currentPageIndex + 1;
    
    IntroPageViewcontroller *page = self.introPages[index];
    
    page.titleContent       = self.introTitleStrings[index];
    page.descriptionContent = self.introDescriptionStrings[index];
    page.imageIdentifier    = [NSString stringWithFormat:@"intro-%d", index + 1];
    page.index              = index;
    
    NSArray *viewControllers = [NSArray arrayWithObject:page];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.currentPageIndex++;
    self.pageControl.currentPage = self.currentPageIndex;
    
    self.skipButton.hidden       = self.currentPageIndex != 0;
    
    [self.forwardButton removeTarget:nil
                              action:NULL
                    forControlEvents:UIControlEventAllEvents];
    
    if (self.currentPageIndex != self.introPages.count - 1) {
        [self.forwardButton setTitle:@">" forState:UIControlStateNormal];
        [self.forwardButton addTarget:self action:@selector(moveForward:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.forwardButton setTitle:LocalizedString(@"intro-forward-title") forState:UIControlStateNormal];
        [self.forwardButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
