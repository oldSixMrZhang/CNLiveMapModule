//
//  CNLiveMapViewController.m
//  CNLiveSendPositonModule
//
//  Created by open on 2019/11/22.
//

#import "CNLiveMapViewController.h"
#import "CNLiveMapTableViewCell.h"

@interface CNLiveMapViewController()
<
BMKMapViewDelegate,
BMKLocationManagerDelegate,
UITableViewDelegate,
UITableViewDataSource,
BMKPoiSearchDelegate,
BMKGeoCodeSearchDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate
>
@property (nonatomic, strong) UIButton              *sendBarItem;
@property (nonatomic, strong) BMKMapView            *mapView;//地图
@property (nonatomic, strong) BMKUserLocation       *userLocation; //当前位置对象
@property (nonatomic, strong) UIButton              *repositionBtn;//重新定位按钮
@property (nonatomic, strong) BMKLocationManager    *locationManager;//定位管理
///tableview
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) NSArray               *dataArray;
@property (nonatomic, strong) NSIndexPath           *selectedIndexPath;//选择的cell

//逆地理获取POI
@property (nonatomic, strong) BMKGeoCodeSearch      *geoCodeSearch;
///poi搜索
@property (nonatomic, strong) BMKPoiSearch          *poiSearch;
@property (nonatomic, copy)   NSString              *tempCity;
///关键字搜索
@property (nonatomic, strong) UISearchController    *searchController;
@property (nonatomic, assign) CGFloat               keyBoardTempHeight;

@property (nonatomic, strong) UITableView           *searchTableView;
@property (nonatomic, strong) NSArray               *searchDataArray;

@end
@implementation CNLiveMapViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置";
    self.selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    //发送按钮
    self.sendBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBarItem.frame = CGRectMake(0, 0, 60, 30);
    [self.sendBarItem setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBarItem addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBarItem setTitleColor:RGBOF(0x9C9C9C) forState:UIControlStateNormal];
    self.sendBarItem.userInteractionEnabled = NO;
    UIBarButtonItem *rightCunstomButtonView = [[UIBarButtonItem alloc] initWithCustomView:self.sendBarItem];
    
    self.navigationItem.rightBarButtonItem = rightCunstomButtonView;
    //添加地图view
    [self.view addSubview:self.mapView];
    //在地图上添加重新定位按钮
    [self.mapView addSubview:self.repositionBtn];
    [self.repositionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mapView.mas_right).offset(-10);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self repositionAction];
    //添加searchView
    [self addSearchController];
    //添加tableview
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.equalTo(self.mapView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kVerticalBottomSafeHeight);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [CNLiveMapViewController networkStatusWithBlock:^(CNLiveNetworkStatusType status) {
        if (status == CNLiveNetworkStatusUnknown || status == CNLiveNetworkStatusNotReachable) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshBDVC"];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshBDVC"];
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                [self.tableView.mj_header beginRefreshing];
            }
        }
    }];
}

#pragma mark -- private
- (void)becomeActive{
    if ([CNLiveNetworking isNetworking]) {
        BOOL b = [[NSUserDefaults standardUserDefaults]boolForKey:@"refreshBDVC"];
        if (b) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshBDVC"];
            [self.tableView.mj_header beginRefreshing];
        }
    }
}
- (void)reloadMapTableView{
    if (![CNLiveNetworking isNetworking]) {
        [QMUITips showLoadingInView:self.tableView];
        self.dataArray = @[];
        [self.tableView reloadData];
        return;
    }
    [QMUITips hideAllTips];
    self.selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView.mj_header beginRefreshing];
}

- (void)addSearchController{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
//    self.searchController.obscuresBackgroundDuringPresentation = YES;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    UISearchBar *bar = self.searchController.searchBar;
    bar.frame = CGRectMake(0, self.mapView.frame.origin.y, SCREEN_WIDTH, 44);
    bar.barStyle = UIBarStyleDefault;
    bar.delegate = self;
    bar.translucent = NO;
    bar.barTintColor = [UIColor groupTableViewBackgroundColor];
    bar.tintColor = [UIColor colorWithRed:0 green:(190 / 255.0) blue:(12 / 255.0) alpha:1];
    UIImageView *view = [[[bar.subviews objectAtIndex:0] subviews] firstObject];
    view.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
    view.layer.borderWidth = 0.7;
    bar.showsBookmarkButton = NO;
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor redColor], NSFontAttributeName: [UIFont systemFontOfSize:16]} forState:UIControlStateNormal];
    
    // 修改标题文字
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"取消"];
    UITextField *searchField = [bar valueForKey:@"searchField"];
    searchField.placeholder = @"搜索地点";
    searchField.returnKeyType = UIReturnKeyDone;
    
    // 获取清除按钮
    UIButton * clearBtn = [searchField valueForKey:@"_clearButton"];
    // 重新绑定触发方法
    [clearBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 3.0f;
        searchField.layer.borderColor = [UIColor colorWithRed:((0xdddddd >> 16) & 0x000000FF)/255.0f green:((0xdddddd >> 8) & 0x000000FF)/255.0f blue:((0xdddddd) & 0x000000FF)/255.0 alpha:1].CGColor;
        searchField.layer.borderWidth = 0.7;
    }
    [self.view addSubview:bar];
}

- (void)repositionAction{
    [self.sendBarItem setTitleColor:KGray102Color forState:UIControlStateNormal];
    self.sendBarItem.userInteractionEnabled = NO;
    @try {
        [self.locationManager stopUpdatingLocation];
    } @catch (NSException *exception) {
        NSLog(@"CNBDMapViewController.m 崩溃了");
    }
    MJWeakSelf
    [self.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
        [QMUITips hideAllTips];
        BOOL isError = false;
        if (error)
        {
            isError = YES;
        }
        if (location && !isError) {//得到定位信息，添加annotation
            
            if (location.location) {
                NSLog(@"LOC = %@",location.location);
                //把地图放到位置中心点
                [weakSelf.mapView setCenterCoordinate:location.location.coordinate animated:YES];
                //实现该方法，否则定位图标不出现
                weakSelf.userLocation.location = location.location;
                [weakSelf.mapView updateLocationData:weakSelf.userLocation];
                //获取POI
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf reloadMapTableView];
            }
            if (location.rgcData) {
                weakSelf.tempCity = location.rgcData.city;
            }
        }else{
            isError = YES;
        }
        if ([error.localizedDescription containsString:@"网络"] && [error.localizedDescription containsString:@"失败"]) {
            UIAlertController *con = [UIAlertController alertControllerWithTitle:@"" message:@"网络错误，请检查您的网络。" preferredStyle:1];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [con addAction:action1];
            [weakSelf presentViewController:con animated:YES completion:nil];
        }else{
            if (isError) {
                UIAlertController *con = [UIAlertController alertControllerWithTitle:@"" message:@"无法获取您的位置信息。" preferredStyle:1];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [con addAction:action1];
                [weakSelf presentViewController:con animated:YES completion:nil];
            }
        }
    }];
}
- (void)sendLocation{
    MJWeakSelf
    //30秒没反应弹窗提醒错误，拦截回退不截图
    BMKPoiInfo *info = self.dataArray[self.selectedIndexPath.row];
    if (!info) {
        [QMUITips hideAllTips];
        return;
    }
    [QMUITips showLoadingInView:[UIApplication sharedApplication].delegate.window];
    NSArray *sendARR = @[info.name,info.address.length>0?info.address:@"未知地点"];
    float level = self.mapView.zoomLevel;
    level<3?level=3:level;
    level>18?level=18:level;
    NSString *centerPointStr = [NSString stringWithFormat:@"%f,%f",info.pt.longitude,info.pt.latitude];
    NSString *imagUrl = [NSString stringWithFormat:@"http://api.map.baidu.com/staticimage/v2?ak=%@&mcode=%@&center=%@&width=560&height=280&coordtype=gcj02ll&dpiType=ph&zoom=%f",BDMapAK,BDMapMCODE,centerPointStr,level];
    [QMUITips hideAllTipsInView:[UIApplication sharedApplication].delegate.window];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendCurrentLocation:image:addressName:)]) {
        CLLocationCoordinate2D location = self.mapView.centerCoordinate;
        [self.delegate sendCurrentLocation:location image:imagUrl addressName:sendARR];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }else{
        [QMUITips showError:@"发送失败" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1.5];
    }
}

//逆地理位置返回poi（跟Android一致）
- (void)getPOIInfo:(CLLocationCoordinate2D)coordinate{
    if (![CNLiveNetworking isNetworking]) {
        [self.tableView.mj_header endRefreshing];
        self.dataArray = @[];
        [self.tableView reloadData];
        return;
    }
    BMKReverseGeoCodeSearchOption *reverseGeoCodeOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeoCodeOption.location = coordinate;//CLLocationCoordinate2DMake(39.915, 116.404);
    // 是否访问最新版行政区划数据（仅对中国数据生效）
    reverseGeoCodeOption.isLatestAdmin = YES;
    BOOL flag = [self.geoCodeSearch reverseGeoCode: reverseGeoCodeOption];
    if (flag) {
        NSLog(@"逆geo检索发送成功");
    }  else  {
        NSLog(@"逆geo检索发送失败");
    }
}

//输入内容检索
- (void)clearBtnClick{
    self.searchDataArray = @[];
    [self.searchTableView reloadData];
}

//添加屏幕中心点标注
- (void)addCenterAnnotation{
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.isLockedToScreen = YES;
    CGPoint p = CGPointZero;
    p.x = SCREEN_WIDTH/2;
    p.y = self.mapView.frame.size.height/2-14;
    annotation.screenPointToLock = p;
    [_mapView addAnnotation:annotation];
}
#pragma mark -- textfieldDelegate
// 点击键盘Return键取消第一响应者
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return  YES;
}

#pragma mark -- scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.searchTableView) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}
#pragma mark -- SearchControllerDelegate
-(void)didPresentSearchController:(UISearchController *)searchController{
    UIView *_statusView = [[UIView alloc] initWithFrame:CGRectMake(0, -50, SCREEN_WIDTH, 150)];
    _statusView.backgroundColor = self.searchController.view.backgroundColor;// [UIColor groupTableViewBackgroundColor];
    [self.searchController.view addSubview:_statusView];
    self.searchController.searchBar.frame = CGRectMake(0, kNavigationBarHeight + kVerticalStatusHeight, self.searchController.searchBar.frame.size.width, 44);
    UISearchBar *bar = self.searchController.searchBar;
    [self.searchController.view addSubview:bar];
    [self.searchController.view addSubview:self.searchTableView];
    [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.searchController.view);
        make.bottom.equalTo(self.searchController.view).offset(-kVerticalBottomSafeHeight);
        make.top.equalTo(self.searchController.searchBar.mas_bottom);
    }];
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (CNLiveStringTrimedIsEmpty(searchController.searchBar.text)) {
        self.searchDataArray = @[];
        [self.searchTableView reloadData];
        return;
    }
    //初始化请求参数类BMKCitySearchOption的实例
    BMKPOICitySearchOption *cityOption = [[BMKPOICitySearchOption alloc] init];
    //检索关键字，必选。举例：小吃
    cityOption.keyword = searchController.searchBar.text;
    //区域名称(市或区的名字，如北京市，海淀区)，最长不超过25个字符，必选
    cityOption.city = self.tempCity;
    //检索分类，可选，与keyword字段组合进行检索，多个分类以","分隔。举例：美食,烧烤,酒店
//    cityOption.tags = @[@"美食",@"烧烤"];
    //区域数据返回限制，可选，为YES时，仅返回city对应区域内数据
//    cityOption.isCityLimit = YES;
    //POI检索结果详细程度
    //cityOption.scope = BMK_POI_SCOPE_BASIC_INFORMATION;
    //检索过滤条件，scope字段为BMK_POI_SCOPE_DETAIL_INFORMATION时，filter字段才有效
    //cityOption.filter = filter;
    //分页页码，默认为0，0代表第一页，1代表第二页，以此类推
    cityOption.pageIndex = 0;
    //单次召回POI数量，默认为10条记录，最大返回20条
    cityOption.pageSize = 10;
    BOOL flag = [self.poiSearch poiSearchInCity:cityOption];
    if(flag) {
        NSLog(@"POI城市内检索成功");
    } else {
        NSLog(@"POI城市内检索失败");
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{                     // return NO to not become first responder
    if (self.tempCity.length > 0) {
        return YES;
    }else{
        [QMUITips showWithText:@"获取定位信息失败，请重试。" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1.5];
        return NO;
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.searchDataArray = @[];
    [self.searchTableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    self.searchController.searchBar.frame = CGRectMake(0,kNavigationBarHeight, self.searchController.searchBar.frame.size.width, 44.0);
}

#pragma mark -- tableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentify = @"CNMapTableViewCell";
    CNLiveMapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (!cell) {
        cell = [[CNLiveMapTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    }
    if (tableView == self.tableView) {
        BMKPoiInfo *info = self.dataArray[indexPath.row];
        cell.name.text = info.name;
        cell.address.text = info.address;
        [cell setFirstCell:indexPath];
        if (indexPath.row == self.selectedIndexPath.row) {
            cell.choseIMG.hidden = NO;
        }else{
            cell.choseIMG.hidden = YES;
        }
    }else{
        BMKPoiInfo *info = self.searchDataArray[indexPath.row];
        cell.name.text = info.name;
        cell.address.text = info.address;
        [cell setSearchCell];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        CNLiveMapTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.choseIMG.hidden = YES;
        self.selectedIndexPath=indexPath;
        CNLiveMapTableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell1.choseIMG.hidden = NO;
        BMKPoiInfo *info = self.dataArray[indexPath.row];
        [self.mapView setCenterCoordinate:info.pt animated:YES];
    }else{
        BMKPoiInfo *info = self.searchDataArray[indexPath.row];
        self.searchController.active = NO;
        [self.mapView setCenterCoordinate:info.pt animated:YES];
        [self reloadMapTableView];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kDefaultCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.dataArray.count;
    }else{
        return self.searchDataArray.count;
    }
    return 0;
}
#pragma mark -- 地图delegate
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager doRequestAlwaysAuthorization:(CLLocationManager * _Nonnull)locationManager{
    [locationManager requestAlwaysAuthorization];
}
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

/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 *@param reason 地区区域改变的原因
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated reason:(BMKRegionChangeReason)reason{
    [QMUITips hideAllTips];
    if (reason == BMKRegionChangeReasonGesture) {//手势触发导致地图区域变化，如双击、拖拽、滑动地图
        [self.sendBarItem setTitleColor:KGray102Color forState:UIControlStateNormal];
        self.sendBarItem.userInteractionEnabled = NO;
        [self reloadMapTableView];
    }else if(reason == BMKRegionChangeReasonEvent){//地图上控件事件，如点击指南针返回2D地图。
        NSLog(@"");
    }else if(reason == BMKRegionChangeReasonAPIs){//开发者调用接口、设置地图参数等导致地图区域变化
        NSLog(@"");
    }
}
/**
 *地图初始化完毕时会调用此接口
 *@param mapView 地图View
 */
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    [self addCenterAnnotation];
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:reuseIndetifier];
        }
        UIImage *image = [self getImageName:@"map_module_where_point_b" bundleName:@"CNLiveMapModule" targetClass:[self class]];

        annotationView.image = image;
        return annotationView;
    }
    return nil;
}

#pragma mark - 逆地理获取POI
/**
 反向地理编码检索结果回调
 
 @param searcher 检索对象
 @param result 反向地理编码检索结果
 @param error 错误码，@see BMKCloudErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    [self.tableView.mj_header endRefreshing];
    [QMUITips hideAllTips];
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"检索结果返回成功：%@",result.poiList);
        if (result.poiList.count > 0) {
            self.dataArray = result.poiList;
        }else{
            BMKPoiInfo *info = [[BMKPoiInfo alloc]init];
            info.name = @"[位置]";
            info.address = @"未知地点";
            self.dataArray = @[info];
        }
        self.selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadData];
        [self.sendBarItem setTitleColor:UIColorMake(26, 173, 25) forState:UIControlStateNormal];
        self.sendBarItem.userInteractionEnabled = YES;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UITableViewScrollPositionNone) animated:NO];

    }else {//错误的结果，提示
        if (error == BMK_SEARCH_NETWOKR_ERROR) {
            [QMUITips showInfo:@"网络错误，请检查网络。" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1.5];
        }else{
            [QMUITips showInfo:@"未知错误,请重试" inView:[UIApplication sharedApplication].delegate.window hideAfterDelay:1.5];
        }
    }
}
#pragma mark - poi搜索Delegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误码，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    //BMKSearchErrorCode错误码，BMK_SEARCH_NO_ERROR：检索结果正常返回
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"检索结果返回成功：%@",poiResult.poiInfoList);
        BMKPoiInfo *info = poiResult.poiInfoList[0];
        if (info.UID.length == 0) {
            self.searchDataArray = @[];
            [self.searchTableView reloadData];
            [QMUITips showInfo:@"无结果" inView:self.searchController.view hideAfterDelay:1.5];
            return;
        }
        self.searchDataArray = poiResult.poiInfoList;
        [self.searchTableView reloadData];
    }
     else {//错误的结果，提示
         NSLog(@"其他检索结果错误码");
         self.searchDataArray = @[];
         [self.searchTableView reloadData];
         [QMUITips showInfo:@"无结果" inView:self.searchController.view hideAfterDelay:1.5];
    }
}

#pragma mark -- lazy
- (BMKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, (self.view.height-44-20)/2)];
        _mapView.delegate = self;
        _mapView.zoomLevel = 17;//缩放等级4-21
        _mapView.showMapScaleBar = YES;//显示比例尺
        //打开实时路况图层
        //        [_mapView setTrafficEnabled:YES];
        _mapView.showsUserLocation = YES;//显示定位图层
        //显示我的位置，我的位置图标和地图都不会旋转
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        //更换我的位置图标
        // self.mapView是BMKMapView对象
        BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
        //定位图标名称，需要将该图片放到 mapapi.bundle/images 目录下
        //        param.locationViewImgName = @"icon_nav_bus";
        //用户自定义定位图标，V4.2.1以后支持
        UIImage *image = [self getImageName:@"map_module_where_position" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        param.locationViewImage = image;
        //根据配置参数更新定位图层样式
        //设置显示精度圈，默认YES
        param.isAccuracyCircleShow = YES;
        //精度圈 边框颜色
        param.accuracyCircleStrokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0];
        //精度圈 填充颜色
        param.accuracyCircleFillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0];
        [_mapView updateLocationViewWithParam:param];
        
    }
    return _mapView;
}
-(BMKUserLocation *)userLocation{
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}
-(UIButton *)repositionBtn{
    if (!_repositionBtn) {
        _repositionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image1 = [self getImageName:@"map_module_where_select" bundleName:@"CNLiveMapModule" targetClass:[self class]];
        UIImage *image2 = [self getImageName:@"map_module_where_no_select" bundleName:@"CNLiveMapModule" targetClass:[self class]];

        [_repositionBtn setImage:image1 forState:UIControlStateNormal];
        [_repositionBtn setImage:image2 forState:UIControlStateSelected];
        [_repositionBtn addTarget:self action:@selector(repositionAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _repositionBtn;
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
//        _locationManager.locationTimeout = 3;
        //设置获取地址信息超时时间
//        _locationManager.reGeocodeTimeout = 3;
    }
    return _locationManager;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = RGB(242, 242, 242);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [UIColor clearColor];
        MJWeakSelf
        _tableView.mj_header = [CNLiveRefreshHeader headerWithRefreshingBlock:^{
            [weakSelf getPOIInfo:weakSelf.mapView.centerCoordinate];
        }];
    }
    return _tableView;
}
-(BMKPoiSearch *)poiSearch{
    if (!_poiSearch) {
        _poiSearch = [[BMKPoiSearch alloc] init];
        _poiSearch.delegate = self;
    }
    return _poiSearch;
}

-(BMKGeoCodeSearch *)geoCodeSearch{
    if (!_geoCodeSearch) {
        _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
        _geoCodeSearch.delegate = self;
    }
    return _geoCodeSearch;
}

-(UITableView *)searchTableView{
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] init];
        _searchTableView.backgroundColor = KGrayBgColor;
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.separatorColor = [UIColor clearColor];
    }
    return _searchTableView;
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
