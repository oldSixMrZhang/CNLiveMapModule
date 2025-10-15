//
//  CNLiveMapTableViewCell.h
//  AFNetworking
//
//  Created by open on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNLiveMapTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *address;
@property (nonatomic, strong) UIImageView *choseIMG;
- (void)setFirstCell:(NSIndexPath *)path;
- (void)setSearchCell;
@end

NS_ASSUME_NONNULL_END
