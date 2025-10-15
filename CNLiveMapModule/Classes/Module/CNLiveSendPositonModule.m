//
//  CNLiveSendPositonModule.m
//  AFNetworking
//
//  Created by open on 2019/11/22.
//

#import "CNLiveSendPositonModule.h"
#import "CNLiveServices.h"

@BeeHiveMod(CNLiveSendPositonModule)
@interface CNLiveSendPositonModule()<BHModuleProtocol>

@end
@implementation CNLiveSendPositonModule
- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSUInteger)moduleLevel {
    return 0;
}

- (void)modSetUp:(BHContext *)context {
    switch (context.env) {
        case BHEnvironmentDev:
            //....初始化开发环境
            break;
        case BHEnvironmentProd:
            //....初始化生产环境
        default:
            break;
    }
    
}

- (void)modInit:(BHContext *)context {
    
}

@end
