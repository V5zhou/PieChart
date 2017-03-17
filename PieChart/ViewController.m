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

@property (nonatomic, strong) PieChartView *pieView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor brownColor];
    label.text = @"人物印象分";
    label.numberOfLines = 0;
    [label sizeToFit];
    label.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.view.frame)/6 + 40);
    [self.view addSubview:label];
    
    //
    self.pieView = [PieChartView createWithFrame:CGRectMake(0, 0, 300, 300)];
    _pieView.center = self.view.center;
    [self.view addSubview:_pieView];
    [self reloadNewData];
}

- (void)reloadNewData {
    NSArray *descriptions = @[@"身高", @"体重", @"三围", @"发型", @"收入", @"衣着", @"性格", @"学历", @"存款"];

    NSMutableArray *descriptionArray = [NSMutableArray array];
    NSMutableArray *fullArray = [NSMutableArray array];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSInteger i = 0; i < (arc4random()%descriptions.count + 3); i++) {
        [descriptionArray addObject:descriptions[i]];
        [fullArray addObject:@(100)];       //全都100为满分
        [dataArray addObject:@(arc4random()%100 + 1)];
    }
    _pieView.descriptions = descriptionArray;
    _pieView.fullProgressArray = fullArray;
    _pieView.progressArray = dataArray;
    _pieView.minites = [NSString stringWithFormat:@"%u", arc4random()%60 + 1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self reloadNewData];
}

@end
