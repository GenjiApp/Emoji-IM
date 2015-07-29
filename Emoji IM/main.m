//
//  main.m
//  Emoji IM
//
//  Created by Genji on 2015/01/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "EIMCandidatesController.h"
#import "EIMResourceFileNames.h"

static NSString * const kInputMethodConnectionNameKey = @"InputMethodConnectionName";
static NSString * const kMainNibFileKey = @"NSMainNibFile";

IMKServer *server;

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDictionary = [mainBundle infoDictionary];
    NSString *connectionName = infoDictionary[kInputMethodConnectionNameKey];
    NSString *bundleIdentifier = [mainBundle bundleIdentifier];

    server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:bundleIdentifier];

    // NSApp はこの時点で nil なので、[NSApplication sharedApplication] を使う。
    NSApplication *application = [NSApplication sharedApplication];
    NSArray *topLevelObjects;

    // MainMenu.xib を手動読み込み。
    // 通常のアプリケーションでは NSApplicationMain() 関数で読み込まれるが、
    // インプットメソッドの場合はこのタイミングで手動読み込みする。
    NSString *mainNibName = infoDictionary[kMainNibFileKey];
    if([mainBundle loadNibNamed:mainNibName owner:application topLevelObjects:&topLevelObjects]) {
      [EIMCandidatesController setupWithServer:server];
      [application run];
    }
    else {
      NSLog(@"failed to load main nib.");
    }
  }

  return 0;
}
