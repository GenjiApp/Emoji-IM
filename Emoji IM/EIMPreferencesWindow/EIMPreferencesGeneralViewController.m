//
//  EIMPreferencesGeneralViewController.m
//  Emoji IM
//
//  Created by Genji on 2015/05/10.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMPreferencesGeneralViewController.h"
#import "EIMAppDelegate.h"

@interface EIMPreferencesGeneralViewController ()

@property (weak) IBOutlet NSButton *ignoreEisuKeyCheckBox;

- (IBAction)ignoresEisuKeyChanged:(id)sender;

@end


@implementation EIMPreferencesGeneralViewController

- (void)viewWillAppear
{
  [super viewWillAppear];

  EIMAppDelegate *appDelegate = [NSApp delegate];
  self.ignoreEisuKeyCheckBox.state = appDelegate.ignoresEisuKey ? NSOnState : NSOffState;
}

#pragma mark -
#pragma mark Action Method
- (IBAction)ignoresEisuKeyChanged:(id)sender
{
  EIMAppDelegate *appDelegate = [NSApp delegate];
  NSButton *checkBox = (NSButton *)sender;
  BOOL enabled = (checkBox.state == NSOnState);
  NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @(YES)};
  if(enabled && AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
    appDelegate.ignoresEisuKey = YES;
  }
  else {
    appDelegate.ignoresEisuKey = NO;
    checkBox.state = NSOffState;
  }
}

@end
