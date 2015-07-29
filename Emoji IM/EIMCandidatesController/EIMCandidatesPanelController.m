//
//  EIMCandidatesPanelController.m
//  Emoji IM
//
//  Created by Genji on 2015/04/27.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <InputMethodKit/InputMethodKit.h>
#import "EIMCandidatesPanelController.h"
#import "EIMCandidatesViewController.h"


@interface EIMCandidatesPanelController () <NSWindowDelegate>

@end


@implementation EIMCandidatesPanelController

- (void)windowDidLoad
{
  self.window.opaque = NO;
  self.window.backgroundColor = [NSColor clearColor];
}

#pragma mark -
#pragma mark Accessor Methods
- (EIMCandidatesViewController *)candidatesViewController
{
  return (EIMCandidatesViewController *)self.contentViewController;
}


#pragma mark -
#pragma mark NSWindowDelegate Method
- (void)windowDidResize:(NSNotification *)notification
{
  // [NSWindow invalidateShadow] を遅延実行して影の再計算をしないと、ウィンドウのドロップシャドウが乱れる。
  [self.window performSelector:@selector(invalidateShadow) withObject:nil afterDelay:0.0];
}

@end
