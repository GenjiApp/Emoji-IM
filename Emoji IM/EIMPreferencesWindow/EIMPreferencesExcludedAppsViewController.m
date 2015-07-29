//
//  EIMPreferencesExcludedAppsViewController.m
//  Emoji IM
//
//  Created by Genji on 2015/05/04.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMPreferencesExcludedAppsViewController.h"
#import "EIMAppDelegate.h"
#import "EIMPreferencesKeys.h"

static NSString * const kApplicationNameColumnIdentifier = @"Application Name Column";
static NSString * const kApplicationNameCellViewIdentifier = @"Application Name Cell View";
static NSString * const kBundleIdentifierColumnIdentifier = @"Bundle Identifier Column";
static NSString * const kBundleIdentifierCellViewIdentifier = @"Bundle Identifier Cell View";

@interface EIMPreferencesExcludedAppsViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;

- (IBAction)addExcludedApp:(id)sender;
- (IBAction)removeExcludedApps:(id)sender;

@end

@implementation EIMPreferencesExcludedAppsViewController

#pragma mark -
#pragma mark Action Methods
- (IBAction)addExcludedApp:(id)sender
{
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.directoryURL = [NSURL fileURLWithPath:@"/Applications"];
  openPanel.allowedFileTypes = @[@"app"];
  openPanel.allowsOtherFileTypes = NO;
  openPanel.canChooseFiles = YES;
  openPanel.canChooseDirectories = NO;
  openPanel.allowsMultipleSelection = YES;
  [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result != NSFileHandlingPanelOKButton) {
      return;
    }
    EIMAppDelegate *appDelegate = [NSApp delegate];
    [appDelegate addExcludedApps:openPanel.URLs];
    [self.tableView reloadData];
  }];
}

- (IBAction)removeExcludedApps:(id)sender
{
  EIMAppDelegate *appDelegate = [NSApp delegate];
  [appDelegate removeExcludedAppsAtIndexes:self.tableView.selectedRowIndexes];
  self.removeButton.enabled = NO;
  [self.tableView reloadData];
}


#pragma mark -
#pragma mark NSTableViewDataSource Method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  EIMAppDelegate *appDelegate = [NSApp delegate];
  return appDelegate.excludedApps.count;
}


#pragma mark -
#pragma mark NSTableViewDelegate Method
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  EIMAppDelegate *appDelegate = [NSApp delegate];
  NSString *bundleIdentifier = appDelegate.excludedApps[row];
  if(!bundleIdentifier) {
    bundleIdentifier = @"";
  }
  NSTableCellView *cellView = nil;
  if([tableColumn.identifier isEqualToString:kApplicationNameColumnIdentifier]) {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSImage *icon = nil;
    NSString *appName = nil;
    NSURL *fileURL = [workspace URLForApplicationWithBundleIdentifier:bundleIdentifier];
    if(fileURL) {
      icon = [workspace iconForFile:fileURL.path];
      appName = [[NSFileManager defaultManager] displayNameAtPath:fileURL.path];
    }

    cellView = [tableView makeViewWithIdentifier:kApplicationNameCellViewIdentifier owner:self];
    if(!appName.length) {
      appName = NSLocalizedString(@"Not found", nil);
      cellView.textField.textColor = [NSColor redColor];
    }
    else {
      cellView.textField.textColor = [NSColor textColor];
    }

    if(!icon) {
      icon = [NSImage imageNamed:NSImageNameCaution];
    }

    cellView.textField.stringValue = appName;
    cellView.imageView.image = icon;
  }
  else if([tableColumn.identifier isEqualToString:kBundleIdentifierColumnIdentifier]) {
    cellView = [tableView makeViewWithIdentifier:kBundleIdentifierCellViewIdentifier owner:self];
    cellView.textField.stringValue = bundleIdentifier;
  }

  return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSTableView *tableView = notification.object;
  self.removeButton.enabled = (tableView.selectedRow != -1);
}

@end
