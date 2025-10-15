//
//  CNLiveSendPositonService.m
//  AFNetworking
//
//  Created by open on 2019/11/22.
//

#import "CNLiveSendPositonService.h"
#import "CNLiveServices.h"
#import "CNLiveMapViewController.h"
#import "CNLiveMapDetailViewController.h"
#import <CNLiveManager/CNLiveManager.h>

@BeeHiveService(CNLiveSendPositionProtocol,CNLiveSendPositonService)
@interface CNLiveSendPositonService ()<CNLiveSendPositionProtocol>

@end
@implementation CNLiveSendPositonService

- (void)pushToMapDetailViewController {
    
}

- (void)pushToMapViewController:(id)delegate {
    CNLiveMapViewController *vc = [CNLiveMapViewController new];
    vc.delegate = delegate;
    [CNLivePageJumpManager pushViewController:vc];
}

-(void)pushToMapDetailViewController:(id)delegate location:(CLLocationCoordinate2D)location image:(NSString *)img addressName:(NSArray *)arr{
    CNLiveMapDetailViewController *vc = [CNLiveMapDetailViewController new];
    vc.delegate = delegate;
    vc.locationCoordinate = location;
    vc.img = img;
    vc.locationInfo = arr;
    [CNLivePageJumpManager pushViewController:vc];
}
@end
