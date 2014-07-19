//
//  DFUBootViewController.m
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/15/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import "DFUBootViewController.h"
#import "DFUUploadViewController.h"
#import "AppDelegate.h"

@implementation DFUBootViewController

@synthesize dfuController = _dfuController;
@synthesize metawearAPI, scanActivityIndicator, targetTableView, scanButton, cm, appNameLabel, appSizeLabel, discoveredTargets, discoveredTargetsRSSI, isScanning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"DFU";
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.dfuController = [[DFUController alloc] init];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"DFU";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanButtonPressed)];
        self.navigationItem.rightBarButtonItem = anotherButton;
        
        self.scanActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.scanActivityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [self.view addSubview:self.scanActivityIndicator];
        
        self.targetTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 140, self.view.frame.size.width-40, self.view.frame.size.height-100) style:UITableViewStyleGrouped];
        self.targetTableView.layer.borderColor = [UIColor clearColor].CGColor;
        self.targetTableView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.targetTableView.layer.borderWidth = 2.0;
        [self.targetTableView.layer setCornerRadius:10.0];
        self.targetTableView.dataSource = self;
        self.targetTableView.delegate = self;
        [self.view addSubview:self.targetTableView];
        
        self.appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 70, 170, 21)];
        [self.view addSubview:self.appNameLabel];
        
        self.appSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 100, 151, 21)];
        [self.view addSubview:self.appSizeLabel];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.discoveredTargets = [@[] mutableCopy];
    self.discoveredTargetsRSSI = [@{} mutableCopy];
    
    self.targetTableView.delegate = self;
    self.targetTableView.dataSource = self;
    
    self.cm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.metawearAPI = [[MetaWearAPI alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.metawearAPI = appDelegate.metawearAPI;
    self.metawearAPI.delegate = self;
    
    [self.metawearAPI jumpToBootloader];
    
    NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:@"metawear" withExtension:@"bin"];
    [self.dfuController setFirmwareURL:firmwareURL];
    
    [self.discoveredTargets removeAllObjects];
    [self.targetTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    self.appNameLabel.text = self.dfuController.appName;
    self.appSizeLabel.text = [NSString stringWithFormat:@"%d bytes", self.dfuController.appSize];
    
    if (self.cm.state == CBCentralManagerStatePoweredOn && !self.isScanning) {
        [self startScan];
    }
}

- (void) stopScan
{
    [self.discoveredTargets removeAllObjects];
    [self.targetTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [self.cm stopScan];
    self.isScanning = NO;
    [self.scanActivityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem.title = @"Scan";
    NSLog(@"Stopped scan.");
}

- (void) startScan
{
    [self.cm scanForPeripheralsWithServices:@[[DFUController serviceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    self.isScanning = YES;
    [self.scanActivityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem.title = @"Stop scan";
    NSLog(@"Started scan.");
}

- (void)scanButtonPressed
{
    if (self.isScanning) {
        [self stopScan];
    } else {
        [self startScan];
    }
}

- (UIImage *) imageForSignalStrength:(NSNumber *) RSSI
{
    NSString *imageName;
    if (RSSI.floatValue > -40.0)
        imageName = @"3-BARS.png";
    else if (RSSI.floatValue > -60.0)
        imageName = @"2-BARS.png";
    else if (RSSI.floatValue > -100.0)
        imageName = @"1-BAR.png";
    else
        imageName = @"0-BARS.png";
    
    return [UIImage imageNamed:imageName];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *p = [self.discoveredTargets objectAtIndex:tableView.indexPathForSelectedRow.row];
    
    self.dfuController.peripheral = p;
    [self.cm connectPeripheral:p options:nil];
    
    [self stopScan];
    
    DFUUploadViewController *vc = [[DFUUploadViewController alloc] initWithNibName:nil bundle:nil];
    [vc setDfuController:self.dfuController];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.discoveredTargets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DeviceInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInformationCell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CBPeripheral *p = [self.discoveredTargets objectAtIndex:indexPath.row];
    cell.textLabel.text = p.name;
    NSNumber *rssi = [self.discoveredTargetsRSSI objectForKey:[NSString stringWithFormat:@"%@", p.identifier]];
    cell.imageView.image = [self imageForSignalStrength:rssi];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self scanButtonPressed];
    }
    NSLog(@"Central manager did update state: %d", (int) central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Avoid bogus value sometimes given by iOS.
    if (RSSI.intValue != 127) {
        NSString *key = [NSString stringWithFormat:@"%@", peripheral.identifier];
        NSNumber *oldRSSI = [self.discoveredTargetsRSSI objectForKey:key];
        NSNumber *newRSSI = [NSNumber numberWithFloat:(RSSI.floatValue*0.3 + oldRSSI.floatValue*0.7)];
        [self.discoveredTargetsRSSI setValue:newRSSI forKey:key];
    }
    
    if (![self.discoveredTargets containsObject:peripheral]) {
        [self.discoveredTargets addObject:peripheral];
    }
    
    NSLog(@"didDiscoverPeripheral %@, %f", peripheral.name, RSSI.floatValue);
    [self.targetTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral %@", peripheral.name);
    
    [self.dfuController didConnect];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"didDisconnectPeripheral %@: %@", peripheral.name, error);
    }
    
    [self.dfuController didDisconnect:error];
}

@end
