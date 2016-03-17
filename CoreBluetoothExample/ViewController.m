//
//  ViewController.m
//  CoreBluetoothExample
//
//  Created by Wang on 16/3/16.
//  Copyright © 2016年 WangJace. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_peripheralArr;
}
/**
 *  系统蓝牙设备管理对象，可以把他理解为主设备，通过他可以去扫描和链接外设
 */
@property (nonatomic,strong) CBCentralManager *manager;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (copy, nonatomic) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    _dataSource = [[NSMutableArray alloc] init];
    _peripheralArr = [[NSMutableArray alloc] init];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"CBCentralManagerStateUnknown");
        }
            break;
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"CBCentralManagerStateUnauthorized");
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");
        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");
            [central scanForPeripheralsWithServices:nil options:nil];
        }
            break;
        case CBCentralManagerStateResetting:
        {
            NSLog(@"CBCentralManagerStateResetting");
        }
            break;
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"CBCentralManagerStateUnsupported");
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![_dataSource containsObject:peripheral.name] && peripheral.name != nil) {
        [_dataSource addObject:peripheral.name];
        [_peripheralArr addObject:peripheral];
        [_myTableView reloadData];
    }
    /*
    if ([peripheral.name hasPrefix:@""]) {
        //连接设备
        [central connectPeripheral:peripheral options:nil];
    }
     */
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self showAlertWithString:[NSString stringWithFormat:@"连接%@成功",peripheral.name]];
    peripheral.delegate = self;
    //扫描外设Services
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showAlertWithString:[NSString stringWithFormat:@"%@断开连接",peripheral.name]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self showAlertWithString:[NSString stringWithFormat:@"连接%@失败",peripheral.name]];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"扫描到外设服务%@",peripheral.services);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [peripheral discoverCharacteristics:nil forService:service];
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //连接设备
    [_manager connectPeripheral:_peripheralArr[indexPath.row] options:nil];
}


- (void)showAlertWithString:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    [self.navigationController presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
