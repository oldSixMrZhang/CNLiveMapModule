//
//  CNLiveMapViewController.h
//  CNLiveSendPositonModule
//
//  Created by open on 2019/11/22.
//

#import <UIKit/UIKit.h>
#import "CNCommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNLiveMapViewController : CNCommonViewController
@property (nonatomic, weak) id<CNLiveMapPositionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
