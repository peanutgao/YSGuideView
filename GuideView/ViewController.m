//
//  ViewController.m
//  GuideViewDemo
//
//  Created by Joseph Gao on 16/4/1.
//  Copyright © 2016年 Joseph. All rights reserved.
//

#import "ViewController.h"
#import "YSDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushToVC:(id)sender {
    YSDemoViewController *vc = [[YSDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clean:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"firstLaunchInfoDic"];
}
@end
