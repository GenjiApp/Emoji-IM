//
//  EIMPreferencesTabViewController.m
//  Emoji IM
//
//  Created by Genji on 2015/05/06.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMPreferencesTabViewController.h"

@interface EIMPreferencesTabViewController () <NSTabViewDelegate>

@end

@implementation EIMPreferencesTabViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)awakeFromNib
{
  NSTabViewItem *selectedTabViewItem = self.tabViewItems[self.selectedTabViewItemIndex];
  self.tabView.window.title = selectedTabViewItem.viewController.title;
}


#pragma mark -
#pragma mark NSTabViewDelegate Method
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  [super tabView:tabView willSelectTabViewItem:tabViewItem];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
  [super tabView:tabView didSelectTabViewItem:tabViewItem];

  self.tabView.window.title = tabViewItem.viewController.title;

  NSRect viewFrame = tabViewItem.viewController.view.frame;
  viewFrame.size = tabViewItem.viewController.view.fittingSize;
  NSRect windowFrame = self.view.window.frame;
  NSRect newWindowFrame = [self.view.window frameRectForContentRect:viewFrame];
  newWindowFrame.origin.x = windowFrame.origin.x;
  newWindowFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - newWindowFrame.size.height;
  [self.view.window setFrame:newWindowFrame display:YES animate:NO];
}

@end
