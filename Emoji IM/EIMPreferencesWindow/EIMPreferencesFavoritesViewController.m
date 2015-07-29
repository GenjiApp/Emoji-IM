//
//  EIMPreferencesFavoritesViewController.m
//  Emoji IM
//
//  Created by Genji on 2015/05/10.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMPreferencesFavoritesViewController.h"
#import "EIMAppDelegate.h"
#import "EIMPreferencesFavoriteEditorViewController.h"
#import "EIMPreferencesKeys.h"

static NSString * const kReplaceColumnIdentifier = @"Replace Column";
static NSString * const kWithColumnIdentifier = @"With Column";

static NSString * const kFavoriteEditorViewControllerStoryboardIdentifier = @"Favorite Editor View Controller";
static NSString * const kShowFavoriteEditorAddModeSegueIdentifier = @"Show Favorite Editor Add Mode";
static NSString * const kShowFavoriteEditorEditModeSegueIdentifier = @"Show Favorite Editor Edit Mode";

@interface EIMPreferencesFavoritesViewController () <NSTableViewDataSource, NSTableViewDelegate, EIMPreferencesFavoriteEditorViewDelegate>

@property (nonatomic, readonly) EIMAppDelegate *appDelegate;

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, weak) IBOutlet NSButton *editButton;
@property (nonatomic) NSInteger editingRow;

- (IBAction)removeFavorite:(id)sender;
- (IBAction)editFavoriteInline:(id)sender;
- (IBAction)editFavoriteInSheet:(id)sender;

@end

@implementation EIMPreferencesFavoritesViewController

#pragma mark -
#pragma mark Accessor Method
- (EIMAppDelegate *)appDelegate
{
  return [NSApp delegate];
}

#pragma mark -
#pragma mark Action Methods
- (IBAction)removeFavorite:(id)sender
{
  NSInteger clickedRow = self.tableView.clickedRow;
  NSIndexSet *selectedRowIndexes = self.tableView.selectedRowIndexes;
  if(clickedRow == -1 && !selectedRowIndexes.count) {
    return;
  }

  NSIndexSet *removingIndexes = nil;
  if(clickedRow == -1 || [selectedRowIndexes containsIndex:clickedRow]) {
    removingIndexes = selectedRowIndexes;
  }
  else if(clickedRow != -1 && ![selectedRowIndexes containsIndex:clickedRow]) {
    removingIndexes = [NSIndexSet indexSetWithIndex:clickedRow];
  }

  [self.appDelegate removeFavoritesAtIndexes:removingIndexes];

  [self.tableView reloadData];
  self.removeButton.enabled = NO;
  self.editButton.enabled = NO;
}

- (IBAction)editFavoriteInline:(id)sender
{
  NSTextField *textField = (NSTextField *)sender;
  NSInteger row = [self.tableView rowForView:textField];
  NSInteger columnIndex = [self.tableView columnForView:textField];
  if(row == -1 || columnIndex == -1) {
    return;
  }

  NSString *stringValue = textField.stringValue;
  if(stringValue.length) {
    NSMutableDictionary *favoriteDictionary = [self.appDelegate.favorites[row] mutableCopy];
    NSTableColumn *tableColumn = self.tableView.tableColumns[columnIndex];
    if([tableColumn.identifier isEqualToString:kReplaceColumnIdentifier]) {
      favoriteDictionary[EIMDictionaryNameKey] = stringValue;
    }
    else if([tableColumn.identifier isEqualToString:kWithColumnIdentifier]) {
      favoriteDictionary[EIMDictionaryEmojiKey] = stringValue;
    }

    [self.appDelegate replaceFavoriteAtIndex:row withFavorite:favoriteDictionary];
  }

  [self.tableView reloadData];
}

- (IBAction)editFavoriteInSheet:(id)sender
{
  NSInteger clickedRow = self.tableView.clickedRow;
  if(clickedRow == -1) {
    return;
  }

  self.editingRow = clickedRow;
  EIMPreferencesFavoriteEditorViewController *viewController = [self.storyboard instantiateControllerWithIdentifier:kFavoriteEditorViewControllerStoryboardIdentifier];
  viewController.delegate = self;
  viewController.editorMode = EIMFavoriteEditorModeEdit;
  viewController.editingFavoriteDictionary = self.appDelegate.favorites[clickedRow];
  [self presentViewControllerAsSheet:viewController];
}


#pragma mark -
#pragma mark NSTableViewDataSource Method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.appDelegate.favorites.count;
}


#pragma mark -
#pragma mark NSTableViewDelegate Methods
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSDictionary *favoriteDictionary = self.appDelegate.favorites[row];
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  if([tableColumn.identifier isEqualToString:kReplaceColumnIdentifier]) {
    NSString *name = favoriteDictionary[EIMDictionaryNameKey];
    if(!name) {
      name = @"";
    }
    cellView.textField.stringValue = name;
  }
  else if([tableColumn.identifier isEqualToString:kWithColumnIdentifier]) {
    NSString *emoji = favoriteDictionary[EIMDictionaryEmojiKey];
    if(!emoji) {
      emoji = @"";
    }
    cellView.textField.stringValue = emoji;
  }
  return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSTableView *tableView = notification.object;
  self.removeButton.enabled = (tableView.selectedRow != -1);
  NSIndexSet *rowIndexes = tableView.selectedRowIndexes;
  self.editButton.enabled = (rowIndexes.count == 1);
}


#pragma mark -
#pragma mark EIMPreferencesFavoriteEditorViewDelegate
- (void)favoriteEditorView:(EIMPreferencesFavoriteEditorViewController *)viewController didEndEdit:(NSDictionary *)favoriteDictionary
{
  NSIndexSet *indexSet = nil;
  if(viewController.editorMode == EIMFavoriteEditorModeAdd) {
    [self.appDelegate addFavorite:favoriteDictionary];
    indexSet = [NSIndexSet indexSetWithIndex:self.appDelegate.favorites.count - 1];
  }
  else if(viewController.editorMode == EIMFavoriteEditorModeEdit) {
    [self.appDelegate replaceFavoriteAtIndex:self.editingRow withFavorite:favoriteDictionary];
    indexSet = [NSIndexSet indexSetWithIndex:self.editingRow];
  }

  [self.tableView reloadData];
  [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];

  self.editingRow = -1;
}


#pragma mark -
#pragma mark NSSeguePerforming Method
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
  if([segue.identifier isEqualToString:kShowFavoriteEditorAddModeSegueIdentifier]) {
    EIMPreferencesFavoriteEditorViewController *viewController = segue.destinationController;
    viewController.delegate = self;
    viewController.editorMode = EIMFavoriteEditorModeAdd;
    viewController.editingFavoriteDictionary = nil;
  }
  else if([segue.identifier isEqualToString:kShowFavoriteEditorEditModeSegueIdentifier]) {
    self.editingRow = self.tableView.selectedRow;
    EIMPreferencesFavoriteEditorViewController *viewController = segue.destinationController;
    viewController.delegate = self;
    viewController.editorMode = EIMFavoriteEditorModeEdit;
    viewController.editingFavoriteDictionary = self.appDelegate.favorites[self.editingRow];
  }
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
  SEL action = menuItem.action;
  if(action == @selector(editFavoriteInSheet:) ||
     action == @selector(removeFavorite:)) {
    return (self.tableView.clickedRow != -1);
  }
  return YES;
}

@end
