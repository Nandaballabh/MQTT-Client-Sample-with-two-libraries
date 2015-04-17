//
//  MQTT2ViewController.m
//  MQTTDemo
//
//  Created by Nanda Ballabh on 4/17/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import "MQTT2ViewController.h"
#import "MQTTClientManager.h"

@interface MQTT2ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MQTT2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"MQTT-2message"];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectPressed:(id)sender {
    [sender setEnabled:NO];
    // sender will always be self.testButton
    NSLog(@"%s:%d - %@", __func__, __LINE__, sender);
    // Only generate a new unique clientID if this client doesn't already have one.
    NSString *clientID = [[MQTTClientManager mqttManager] clientID];
    if (clientID == NULL) {
        clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [[MQTTClientManager mqttManager] setClientID:clientID];
    }
    [[MQTTClientManager mqttManager]connectWithHost:kMQTTServerHost port:kMQTTServerPort clientId:clientID];

}

- (IBAction)showLogPressed:(id)sender {
    NSString * allMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"MQTT-2message"];
    self.textView.text = allMessage;

}

@end
