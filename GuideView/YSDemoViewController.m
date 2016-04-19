//
//  YSDemoViewController.m
//  GuideViewDemo
//
//  Created by Joseph Gao on 16/4/1.
//  Copyright © 2016年 Joseph. All rights reserved.
//

#import "YSDemoViewController.h"
#import "YSFirstLaunchGuideView.h"
#import <Accelerate/Accelerate.h>
#import <float.h>

@interface YSDemoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (nonatomic, assign) NSInteger keyIndex;

@end

@implementation YSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [YSFirstLaunchGuideView configFirstLaunchWithImgNames:@[@"1", @"2"]
                                                   key:@"DemoVC"
                                               blurRadius:0
                                    saturationDeltaFactor:0
                                                   inView:self.view];
}

- (IBAction)screenShot:(id)sender {
    self.keyIndex++;
    _bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg%zd", self.keyIndex%3]];
}

- (IBAction)showGuideView:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"firstLaunchInfoDic"];
    
    [YSFirstLaunchGuideView configFirstLaunchWithImgNames:@[@"1", @"2"]
                                                   key:[NSString stringWithFormat:@"key-%zd", self.keyIndex]
                                               blurRadius:0
                                    saturationDeltaFactor:0
                                                   inView:self.view];
}



@end
