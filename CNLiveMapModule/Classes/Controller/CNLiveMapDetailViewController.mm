//
//  CNLiveMapDetailViewController.m
//  AFNetworking
//
//  Created by open on 2019/11/26.
//

#import "CNLiveMapDetailViewController.h"

@interface CNLiveMapDetailViewController ()
<
BMKMapViewDelegate,
BMKLocationManagerDelegate,
BMKRouteSearchDelegate
>
@property (nonatomic, strong) UIView                *bottomView;
@property (nonatomic, strong) UILabel               *nameLab;
@property (nonatomic, strong) UILabel               *addressLab;
@property (nonatomic, strong) UIButton              *showListBtn;
@property (nonatomic, strong) BMKMapView            *mapView;//地图
@property (nonatomic, strong) UIButton              *resetBtn;
@property (nonatomic, assign) CLLocationCoordinate2D mineLocationCoordinate;

@property (nonatomic, strong) BMKLocationManager    *locationManager;//定位管理
@property (nonatomic, strong) BMKUserLocation       *userLocation; //当前位置对象
@property (nonatomic, strong) BMKPointAnnotation    *annotation;//标注
@property (nonatomic, assign) BOOL                  isLocation;//定位是否成功
@property (nonatomic, strong) NSMutableArray        *listSelectArray;
/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D        startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D        destinationCoordinate;
@property (nonatomic, strong) NSMutableArray        *maps;
@end

@implementation CNLiveMapDetailViewController{
    BOOL _isShowRoute;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [_mapView viewWillAppear];
    _locationManager.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_mapView viewWillDisappear];
    _locationManager.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-kVerticalBottomSafeHeight);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(84);
    }];
    [self.bottomView addSubview:self.showListBtn];
    [self.showListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomView);
        make.right.equalTo(self.bottomView.mas_right).offset(-15);
        make.size.mas_equalTo(CGSizeMake(54, 54));
    }];
    [self.bottomView addSubview:self.nameLab];
    self.nameLab.text = self.locationInfo[0];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(15);
        make.right.equalTo(self.showListBtn.mas_left).offset(-15);
        make.top.equalTo(self.showListBtn.mas_top).offset(5);
    }];
    [self.bottomView addSubview:self.addressLab];
    self.addressLab.text = self.locationInfo[1];
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(15);
        make.right.equalTo(self.showListBtn.mas_left).offset(-15);
        make.bottom.equalTo(self.showListBtn.mas_bottom).offset(-5);
    }];
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    CGPoint p = self.mapView.compassPosition;
    p.x += 60;
    self.mapView.compassPosition = p;
    CGPoint p1 = self.mapView.mapScaleBarPosition;
    p1.y = SCREEN_WIDTH - 84 - kVerticalBottomSafeHeight - 30;
    self.mapView.mapScaleBarPosition = p1;
    [self.mapView addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mapView.mas_right).offset(-15);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-24);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self addTopView];
}

#pragma mark -- private
- (void)addTopView{
    //返回按钮
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    UIImage *image = [self getImageName:@"map_module_backWhite" bundleName:@"CNLiveMapModule" targetClass:[self class]];
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backController) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mapView).offset(15);
        make.top.equalTo(self.mapView).offset(30+kVerticalTopHeight);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    backBtn.layer.cornerRadius = 8;
    backBtn.layer.masksToBounds = YES;
    
    UIButton *sendBtn = [[UIButton alloc] init];
    sendBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    [sendBtn addTarget:self action:@selector(selectToOperation) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image1 = [self getImageName:@"map_module_pyq_fengxiang" bundleName:@"CNLiveMapModule" targetClass:[self class]];
    [sendBtn setImage:image1 forState:UIControlStateNormal];
    [self.mapView addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mapView.mas_right).offset(-15);
        make.top.equalTo(self.mapView).offset(30+kVerticalTopHeight);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    sendBtn.layer.cornerRadius = 8;
    sendBtn.layer.masksToBounds = YES;
}

- (void)backController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectToOperation{
    MJWeakSelf
    [self.view createAlertViewTitleArray:@[@"发送给朋友"] subTitleArr:@[@""] textColor:UIColorMake(11, 190, 6) subTitleColor:UIColorMake(152, 152, 152) firstFont:UIFontMake(18) font:UIFontMake(18) subFont:UIFontMake(18) cancelTitle:@"取消" cancelFont:UIFontMake(18) cancelTitleColor:UIColorMake(102, 102, 102) actionBlock:^(UIButton *button, NSInteger didRow) {
        switch (didRow) {
            case 0:
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(forwardingLocation:image:addressName:)]) {
                    [self.delegate forwardingLocation:self.locationCoordinate image:self.img addressName:self.locationInfo];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else{
                    [QMUITips showError:@"发送失败" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1.5];
                }
//                CNMessageForwardingController *vc= [[CNMessageForwardingController alloc] init];
//                vc.msgsArray = @[weakSelf.msg];
//                vc.conversation = weakSelf.conversation;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)resetPosition{
    if (self.isLocation) {
        [self.mapView setCenterCoordinate:self.userLocation.location.coordinate animated:YES];
    }else{//没自动定位到位置，需要手动定位
        @try {
            [self.locationManager stopUpdatingLocation];
        } @catch (NSException *exception) {
            NSLog(@"CNBDMapDetailViewController.mm 崩溃了");
        }
        [QMUITips showLoadingInView:self.view];
        MJWeakSelf
        [self.locationManager requestLocationWithReGeocode:NO withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
            [QMUITips hideAllTips];
            BOOL isError = false;
            if (error)
            {
                isError = YES;
//                NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            }
            if (location) {//得到定位信息，添加annotation
                if (location.location) {
                    NSLog(@"LOC = %@",location.location);
                    //把地图放到位置中心点
                    weakSelf.mineLocationCoordinate = location.location.coordinate;
                    [weakSelf.mapView setCenterCoordinate:weakSelf.mineLocationCoordinate animated:YES];
                    //实现该方法，否则定位图标不出现
                    weakSelf.userLocation.location = location.location;
                    [weakSelf.mapView updateLocationData:weakSelf.userLocation];
                    
                }
            }else{
                isError = YES;
            }
            if ([error.localizedDescription containsString:@"网络"] && [error.localizedDescription containsString:@"失败"]) {
                UIAlertController *con = [UIAlertController alertControllerWithTitle:@"" message:@"网络错误，请检查您的网络。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [con addAction:action1];
                [weakSelf presentViewController:con animated:YES completion:nil];
            }else{
                if (isError) {
                    UIAlertController *con = [UIAlertController alertControllerWithTitle:@"" message:@"无法获取您的位置信息。" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [con addAction:action1];
                    [weakSelf presentViewController:con animated:YES completion:nil];
                }
            }
            [self.locationManager startUpdatingLocation];
            [self.locationManager startUpdatingHeading];
        }];

    }
}

- (void)showListSelectBtn{
    [self initListSelectArray];
    MJWeakSelf
    [self.view createAlertViewTitleArray:self.listSelectArray textColor:UIColorMake(40, 40, 40) font:UIFontMake(15) actionBlock:^(UIButton *button, NSInteger didRow) {
        if (didRow == 0) {
            if ([weakSelf.listSelectArray[0] isEqualToString:@"隐藏路线"]) {
                [weakSelf hideWalkLine];
                [weakSelf.listSelectArray replaceObjectAtIndex:0 withObject:@"显示路线"];
                self->_isShowRoute = NO;
                return;
            }else{
                self->_isShowRoute = YES;
                [weakSelf.listSelectArray replaceObjectAtIndex:0 withObject:@"隐藏路线"];
                [self walkLine];
            }
            //显示路线
            if (weakSelf.mineLocationCoordinate.latitude == 0) {
                QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
                    //                [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"" message:@"无法获取你的位置信息。\n 请到手机系统的[隐私]->[定位服务]中打开定位服务，并允许网家家使用定位服务" preferredStyle:QMUIAlertControllerStyleAlert];
                [alertController addAction:action1];
                [alertController showWithAnimated:YES];
                return;
            }
            return;
        }
        CLLocationCoordinate2D startLocation = self.mineLocationCoordinate;
        CLLocationCoordinate2D endLocation = self.locationCoordinate;
        
        if (didRow == self.maps.count) {//苹果地图
            MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:startLocation addressDictionary:nil]];
            currentLocation.name = @"我的位置";
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endLocation addressDictionary:nil]];
            toLocation.name = self.locationInfo[0];
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                           MKLaunchOptionsMapTypeKey:[NSNumber numberWithInteger:MKMapTypeStandard],
                                           MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
            
            return;
        }
        NSString *urlString = self.maps[didRow-1][@"url"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                }];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
        }else{
            [QMUITips showError:@"打开失败" inView:self.view hideAfterDelay:1.5];
        }
        
    }];
}
- (void)initListSelectArray{
    self.listSelectArray = [NSMutableArray arrayWithCapacity:0];
    [self.listSelectArray removeAllObjects];
    [self.listSelectArray addObject:_isShowRoute?@"隐藏路线":@"显示路线"];
    self.maps = [NSMutableArray arrayWithCapacity:0];
    [self.maps removeAllObjects];
    CLLocationCoordinate2D startLocation = self.mineLocationCoordinate;
    CLLocationCoordinate2D endLocation = self.locationCoordinate;
    //高德地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] = @"高德地图";
        [self.listSelectArray addObject:@"高德地图"];
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=我的位置&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&t=0",startLocation.latitude,startLocation.longitude,endLocation.latitude,endLocation.longitude,self.locationInfo[0]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        gaodeMapDic[@"url"] = urlString;
        [self.maps addObject:gaodeMapDic];
    }
    
    
    //百度地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        [self.listSelectArray addObject:@"百度地图"];
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f|name:%@&destination=%f,%f|name:%@&mode=driving",startLocation.latitude,startLocation.longitude,@"我的位置",endLocation.latitude,endLocation.longitude,self.locationInfo[0]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        baiduMapDic[@"url"] = urlString;
        [self.maps addObject:baiduMapDic];
    }
    
    //腾讯地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[@"title"] = @"腾讯地图";
        [self.listSelectArray addObject:@"腾讯地图"];
        NSString *urlStr = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&fromcoord=%f, %f&to=%@&tocoord=%f,%f",startLocation.latitude,startLocation.longitude,self.locationInfo[0],endLocation.latitude,endLocation.longitude];
        qqMapDic[@"url"] = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self.maps addObject:qqMapDic];
    }
    
    //苹果原生地图-苹果原生地图方法和其他不一样,如果没有，提示，确定后去App Store下载
    NSMutableDictionary *iosMapDic = [NSMutableDictionary dictionary];
    iosMapDic[@"title"] = @"苹果地图";
    iosMapDic[@"lat"] = [NSNumber numberWithDouble:endLocation.latitude];
    iosMapDic[@"lng"] = [NSNumber numberWithDouble:endLocation.longitude];
    [self.maps addObject:iosMapDic];
    [self.listSelectArray addObject:@"苹果地图"];
    
}
- (void)walkLine{
    BMKRouteSearch *routeSearch = [[BMKRouteSearch alloc] init];
    routeSearch.delegate = self;
    BMKPlanNode* start = [[BMKPlanNode alloc] init];
    start.pt = self.mineLocationCoordinate;
    //    start.name = @"天安门";
    //    start.cityName = @"北京";
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    end.pt = self.locationCoordinate;
    //    end.name = @"天津站";
    //    end.cityName = @"天津";
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc] init];
    walkingRouteSearchOption.from = start;
    walkingRouteSearchOption.to = end;
    BOOL flag = [routeSearch walkingSearch:walkingRouteSearchOption];
    if (flag) {
        NSLog(@"步行规划检索发送成功");
    } else{
        NSLog(@"步行规划检索发送失败");
    }
}

- (void)hideWalkLine{
    [self.mapView removeOverlays:self.mapView.overlays];
}

#pragma mark -- 路线delegate
/**
 根据overlay生成对应的BMKOverlayView
 
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //初始化一个overlay并返回相应的BMKPolylineView的实例
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        //设置polylineView的填充色
        polylineView.fillColor = [RGBOF(0x5BC4A4) colorWithAlphaComponent:1];
        //设置polylineView的画笔（边框）颜色
        polylineView.strokeColor = [RGBOF(0x5BC4A4) colorWithAlphaComponent:0.7];
        //设置polygonView的线宽度
        polylineView.lineWidth = 2.0;
        return polylineView;
    }
    return nil;
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher result:(BMKWalkingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    [self.mapView removeOverlays:self.mapView.overlays];
    if (error == BMK_SEARCH_NO_ERROR) {
        //+polylineWithPoints: count:坐标点的个数
        __block NSUInteger pointCount = 0;
        //获取所有步行路线中第一条路线
        BMKWalkingRouteLine *routeline = (BMKWalkingRouteLine *)result.routes[0];
        //遍历步行路线中的所有路段
//        BMKWalkingStep *startStep = [[BMKWalkingStep alloc] init];
//        startStep.
        
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取步行路线中的每条路段
            BMKWalkingStep *step = routeline.steps[idx];
//            //初始化标注类BMKPointAnnotation的实例
//            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
//            //设置标注的经纬度坐标为子路段的入口经纬度
//            annotation.coordinate = step.entrace.location;
//            //设置标注的标题为子路段的说明
//            annotation.title = step.entraceInstruction;
//            /**
//
//             当前地图添加标注，需要实现BMKMapViewDelegate的-mapView:viewForAnnotation:方法
//             来生成标注对应的View
//             @param annotation 要添加的标注
//             */
//            [_mapView addAnnotation:annotation];
            //统计路段所经过的地理坐标集合内点的个数
            pointCount += step.pointsCount;
        }];
        //+polylineWithPoints: count:指定的直角坐标点数组
        BMKMapPoint *points = new BMKMapPoint[pointCount];
        __block NSUInteger j = 0;
        //遍历步行路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取步行路线中的每条路段
            BMKWalkingStep *step = routeline.steps[idx];
            //遍历路段所经过的地理坐标集合
            for (NSUInteger i = 0; i < step.pointsCount; i ++) {
                //将每条路段所经过的地理坐标点赋值给points
                points[j].x = step.points[i].x;
                points[j].y = step.points[i].y;
                j ++;
            }
        }];
        
        //根据指定直角坐标点生成一段折线
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:points count:pointCount];
        /**
         向地图View添加Overlay，需要实现BMKMapViewDelegate的-mapView:viewForOverlay:方法
         来生成标注对应的View
         15076875152
         17600128270
         @param overlay 要添加的overlay
         */
        [_mapView addOverlay:polyline];
        //根据polyline设置地图范围
        [self mapViewFitPolyline:polyline withMapView:self.mapView];
    }else{
        _isShowRoute = NO;
        if (error == BMK_SEARCH_NETWOKR_ERROR) {
            [QMUITips showInfo:@"网络错误，请检查网络。" inView:self.view hideAfterDelay:1.5];
        }else{
            [QMUITips showInfo:@"规划路线失败，请重试。" inView:self.view hideAfterDelay:1.5];
        }
    }
}

//根据polyline设置地图范围
- (void)mapViewFitPolyline:(BMKPolyline *)polyline withMapView:(BMKMapView *)mapView {
    double leftTop_x, leftTop_y, rightBottom_x, rightBottom_y;
    if (polyline.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyline.points[0];
    leftTop_x = pt.x;
    leftTop_y = pt.y;
    //左上方的点lefttop坐标（leftTop_x，leftTop_y）
    rightBottom_x = pt.x;
    rightBottom_y = pt.y;
    //右底部的点rightbottom坐标（rightBottom_x，rightBottom_y）
    for (int i = 1; i < polyline.pointCount; i++) {
        BMKMapPoint point = polyline.points[i];
        if (point.x < leftTop_x) {
            leftTop_x = point.x;
        }
        if (point.x > rightBottom_x) {
            rightBottom_x = point.x;
        }
        if (point.y < leftTop_y) {
            leftTop_y = point.y;
        }
        if (point.y > rightBottom_y) {
            rightBottom_y = point.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(leftTop_x , leftTop_y);
    rect.size = BMKMapSizeMake(rightBottom_x - leftTop_x, rightBottom_y - leftTop_y);
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 10, 20, 10);
    [mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
}
#pragma mark -- 地图delegate
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    //添加地图上的标注，并把中心点定位到标注处
    self.annotation.coordinate = self.locationCoordinate;
    [mapView setCenterCoordinate:self.locationCoordinate animated:YES];
    [mapView addAnnotation:self.annotation];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        BMKPinAnnotationView*annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        UIImage *image1 = [self getImageName:@"map_module_where_point_b" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        annotationView.image = image1;
        annotationView.pinColor = BMKPinAnnotationColorRed;
        //        annotationView.canShowCallout= YES;      //设置气泡可以弹出，默认为NO
        //        annotationView.animatesDrop=YES;         //设置标注动画显示，默认为NO
        //        annotationView.draggable = YES;          //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}
#pragma mark -- 定位delegate
//权限改变
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        MJWeakSelf
        QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"" message:@"无法获取你的位置信息。\n 请到手机系统的[隐私]->[定位服务]中打开定位服务，并允许网家家使用定位服务" preferredStyle:QMUIAlertControllerStyleAlert];
        [alertController addAction:action1];
        [alertController showWithAnimated:YES];
    }
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager doRequestAlwaysAuthorization:(CLLocationManager * _Nonnull)locationManager{
    [locationManager requestAlwaysAuthorization];
}
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
    self.isLocation = NO;
}

// 定位SDK中，方向变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading * _Nullable)heading{
    if (!heading) {
        return;
    }
    self.userLocation.heading = heading;
    [self.mapView updateLocationData:self.userLocation];
}


// 定位SDK中，位置变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        self.isLocation = NO;
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
//        [QMUITips showInfo:@"位置更新失败" inView:self.view hideAfterDelay:0.5];
    }else{
        self.mineLocationCoordinate = location.location.coordinate;
        self.isLocation = YES;
    }
    if (!location) {
        return;
    }
//    [QMUITips showInfo:@"位置更新" inView:self.view hideAfterDelay:0.5];
    self.userLocation.location = location.location;
    [self.mapView updateLocationData:self.userLocation];//动态更新我的位置数据
}

#pragma mark -- lazy
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:21];
        _nameLab.textColor = [UIColor blackColor];
    }
    return _nameLab;
}

-(UILabel *)addressLab{
    if (!_addressLab) {
        _addressLab = [[UILabel alloc] init];
        _addressLab.font = [UIFont systemFontOfSize:12];
        _addressLab.textColor = [UIColor blackColor];
    }
    return _addressLab;
}

-(UIButton *)showListBtn{
    if (!_showListBtn) {
        _showListBtn = [[UIButton alloc] init];
        UIImage *image = [self getImageName:@"map_module_where_route" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        [_showListBtn setImage:image forState:UIControlStateNormal];
        [_showListBtn addTarget:self action:@selector(showListSelectBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showListBtn;
}

- (BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (self.view.height-44-20)/2)];
        _mapView.delegate = self;
        _mapView.zoomLevel = 19;//缩放等级4-21
        _mapView.showMapScaleBar = YES;//显示比例尺
//        //打开实时路况图层
//        //        [_mapView setTrafficEnabled:YES];
        _mapView.showsUserLocation = YES;//显示定位图层
//        //显示我的位置，我的位置图标和地图都不会旋转
        _mapView.userTrackingMode = BMKUserTrackingModeHeading;
//        //更换我的位置图标
//        // self.mapView是BMKMapView对象
        BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
//        //定位图标名称，需要将该图片放到 mapapi.bundle/images 目录下
//        //        param.locationViewImgName = @"icon_nav_bus";
//        //用户自定义定位图标，V4.2.1以后支持
        UIImage *image = [self getImageName:@"map_module_userPosition" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        param.locationViewImage = image;
//        //根据配置参数更新定位图层样式
//        //设置显示精度圈，默认YES
//        param.isAccuracyCircleShow = NO;
        [_mapView updateLocationViewWithParam:param];
        
    }
    return _mapView;
}

-(UIButton *)resetBtn{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        UIImage *image = [self getImageName:@"map_module_where_select" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        [_resetBtn setImage:image forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(clickRestBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (void)clickRestBtn{
    [self resetPosition];
}
-(BMKLocationManager *)locationManager{
    if (!_locationManager) {
        //初始化实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置delegate
        _locationManager.delegate = self;
        //设置返回位置的坐标系类型
        _locationManager.coordinateType = BMKLocationCoordinateTypeGCJ02;
        //设置距离过滤参数
        _locationManager.distanceFilter = 1.0f;
        //设置预期精度参数
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        //设置应用位置类型
        _locationManager.activityType = CLActivityTypeFitness;
        //设置是否自动停止位置更新
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        //设置是否允许后台定位
        //_locationManager.allowsBackgroundLocationUpdates = YES;
        //设置位置获取超时时间
//        _locationManager.locationTimeout = 10;
        //设置获取地址信息超时时间
//        _locationManager.reGeocodeTimeout = 3;
    }
    return _locationManager;
}

-(BMKUserLocation *)userLocation{
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

-(BMKPointAnnotation *)annotation{
    if (!_annotation) {
        _annotation = [[BMKPointAnnotation alloc] init];
    }
    return _annotation;
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
