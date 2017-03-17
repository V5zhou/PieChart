//
//  ViewController.m
//  PieChart
//
//  Created by zmz on 17/3/17.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "ViewController.h"
#import "PieChartView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    PieChartView *view = [PieChartView createWithFrame:CGRectMake(0, 0, 300, 300)];
    view.center = self.view.center;
    view.descriptions = @[@"身高", @"体重", @"三围", @"发型", @"收入", @"衣着", @"性格", @"学历", @"存款"];
    NSMutableArray *fullArray = [NSMutableArray array];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSInteger i = 0; i < view.descriptions.count; i++) {
        [fullArray addObject:@(100)];       //全都100为满分
        [dataArray addObject:@(arc4random()%100 + 1)];
    }
    view.fullProgressArray = fullArray;
    view.progressArray = dataArray;
    view.minites = @"38";
    [self.view addSubview:view];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor brownColor];
    label.text = @"我觉得\n描述改成：价格、年龄、姿色、姿势啥啥啥的更棒\n中间改为坚持分钟数\n\n同志们，有没有同感？";
    label.numberOfLines = 0;
    [label sizeToFit];
    label.center = CGPointMake(self.view.center.x, CGRectGetMaxY(view.frame) + 40);
    [self.view addSubview:label];
}

@end
