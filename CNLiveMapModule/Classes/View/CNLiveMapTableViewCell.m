//
//  CNLiveMapTableViewCell.m
//  AFNetworking
//
//  Created by open on 2019/11/22.
//

#import "CNLiveMapTableViewCell.h"

@interface CNLiveMapTableViewCell()
@property (nonatomic, strong) UIView *lineView;

@end
@implementation CNLiveMapTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initLayout];
    }
    return self;
}

- (void)initLayout{
    [self addSubview:self.name];
    [self addSubview:self.address];
    [self addSubview:self.choseIMG];
    [self addSubview:self.lineView];
}

- (void)setFirstCell:(NSIndexPath *)path{
    if (path.row == 0) {
        self.address.hidden = YES;
        [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self.choseIMG.mas_left).offset(-5);
            make.centerY.equalTo(self);
        }];
        self.choseIMG.hidden = NO;
    }else{
        self.address.hidden = NO;
        [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self.choseIMG.mas_left).offset(-5);
            make.top.equalTo(self).offset(10);
        }];
        [self.address mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self.choseIMG.mas_left).offset(-5);
            make.bottom.equalTo(self).offset(-10);
        }];
        self.choseIMG.hidden = YES;
    }
    [self.choseIMG mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(20);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left).offset(15);
        make.height.equalTo(@(1));
    }];
}
- (void)setSearchCell{
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(10);
    }];
    [self.address mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(self).offset(-10);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left).offset(15);
        make.height.equalTo(@(1));
    }];
}
-(UILabel *)name{
    if (_name == nil) {
        _name = [[UILabel alloc] init];
        _name.font = UIFontCNMake(17);
        _name.textColor = [UIColor blackColor];
    }
    return _name;
}

-(UILabel *)address{
    if (_address == nil) {
        _address = [[UILabel alloc] init];
        _address.font = UIFontCNMake(14);
        _address.textColor = [UIColor colorWithRed:101/255.0 green:101/255.0 blue:101/255.0 alpha:1.0];
    }
    return _address;
}
-(UIImageView *)choseIMG{
    if (_choseIMG == nil) {
        _choseIMG = [[UIImageView alloc] init];
        UIImage *image = [self getImageName:@"map_module_where_chose" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        _choseIMG.image = image;
        _choseIMG.hidden = YES;
    }
    return _choseIMG;
}
-(UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = KGrayLineColor;
    }
    return _lineView;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark -- bundle图片
/**
 *  创建图片
 *
 *  @param imageName 图片名字
 *  @param bundleName 图片所在的bundle名字
 *  @param targetClass 类和bundle的同级目录
 *  @return 返回UIImage
 */
- (UIImage *)getImageName:(NSString *)imageName bundleName:(NSString *)bundleName targetClass:(Class)targetClass{
    NSBundle *bundle = [NSBundle bundleForClass:targetClass];
    NSURL *url = [bundle URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *targetBundle = [NSBundle bundleWithURL:url];
    UIImage *image = [UIImage imageNamed:imageName inBundle:targetBundle compatibleWithTraitCollection:nil];
    return image?image:[UIImage imageNamed:imageName inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}
@end
