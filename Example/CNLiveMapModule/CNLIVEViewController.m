//
//  CNLIVEViewController.m
//  CNLiveSendPositonModule
//
//  Created by 郭瑞朋 on 11/19/2019.
//  Copyright (c) 2019 郭瑞朋. All rights reserved.
//

#import "CNLIVEViewController.h"
#import "CNLiveServices.h"
#import "CNLiveMapViewController.h"
#import <MapKit/MapKit.h>
@interface CNLIVEViewController ()<CNLiveMapPositionDelegate>
@property (nonatomic, assign)CLLocationCoordinate2D templocation;
@property (nonatomic, copy) NSString *tempImg;
@property (nonatomic, strong) NSArray *tempArr;
@end

@implementation CNLIVEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.backgroundColor = [UIColor redColor];
    btn1.frame = CGRectMake(100, 100+200, 100, 100);
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(btnAction1) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction{
    id<CNLiveSendPositionProtocol> service = [[BeeHive shareInstance] createService:@protocol(CNLiveSendPositionProtocol)];
    [service pushToMapViewController:self];
}

- (void)btnAction1{
    id<CNLiveSendPositionProtocol> service = [[BeeHive shareInstance] createService:@protocol(CNLiveSendPositionProtocol)];
    [service pushToMapDetailViewController:self location:self.templocation image:self.tempImg addressName:self.tempArr];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendCurrentLocation:(CLLocationCoordinate2D)location image:(nonnull NSString *)img addressName:(nonnull NSArray *)arr {
    NSLog(@"");
    self.templocation = location;
    self.tempImg = img;
    self.tempArr = arr;
    
}

-(void)forwardingLocation:(CLLocationCoordinate2D)location image:(NSString *)img addressName:(NSArray *)arr{
    NSLog(@"");
}

@end
