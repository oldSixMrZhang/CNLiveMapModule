//
//  CNLiveMapDetailViewController.h
//  AFNetworking
//
//  Created by open on 2019/11/26.
//

#import "CNCommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNLiveMapDetailViewController : CNCommonViewController
@property (nonatomic, weak) id<CNLiveMapPositionDelegate> delegate;

//@property (nonatomic, strong) IMAMsg *msg;//需要转发的消息
//@property (nonatomic, strong) IMAConversation *conversation;
//locationCoordinate是发送出去的地点的经纬度坐标
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, copy) NSString    *img;
//此array是发送出去的地点名称（0）和地点地址（1）
@property (nonatomic, strong) NSArray   *locationInfo;
@end

NS_ASSUME_NONNULL_END
