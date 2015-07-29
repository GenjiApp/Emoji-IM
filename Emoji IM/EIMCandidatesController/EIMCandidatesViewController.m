//
//  EIMCandidatesViewController.m
//  Emoji IM
//
//  Created by Genji on 2015/04/26.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMAppDelegate.h"
#import "EIMCandidatesViewController.h"
#import "EIMCandidatesPanelController.h"
#import "EIMCandidateTableRowView.h"
#import "EIMCandidateCellView.h"
#import "EIMPreferencesKeys.h"


static NSString * const kCandidateCellViewIdentifier = @"Candidate Cell";
static const NSUInteger kMaxCharacterLengthOfLargeFontSize = 50;


@interface EIMCandidatesViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, readonly) EIMAppDelegate *appDelegate;
@property (nonatomic, readwrite, getter=isViewVisible) BOOL viewVisible;
@property (nonatomic, weak) IBOutlet NSView *footerView;

@end


@implementation EIMCandidatesViewController

- (void)dealloc
{
  self.delegate = nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.wantsLayer = YES;
  self.view.layer.borderWidth = 1.0;
  self.view.layer.borderColor = [NSColor grayColor].CGColor;
  self.view.layer.cornerRadius = 8.0;
  self.view.layer.masksToBounds = YES;

  self.footerView.wantsLayer = YES;
  self.footerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
  CALayer *layer = [CALayer layer];
  NSSize size = self.footerView.frame.size;
  layer.frame = CGRectMake(0, size.height - 1.0, size.width, 1.0);
  layer.backgroundColor = [NSColor lightGrayColor].CGColor;
  [self.footerView.layer addSublayer:layer];

  self.tableView.target = self;
  self.tableView.doubleAction = @selector(candidateSelected:);
}

- (void)viewDidAppear
{
  self.viewVisible = YES;
}

- (void)viewDidDisappear
{
  self.viewVisible = NO;
  [self.tableView deselectAll:nil];
}


#pragma mark -
#pragma mark Private Method
- (NSString *)emojiWithDictionary:(NSDictionary *)dictionary
{
  NSArray *variants = dictionary[EIMDictionaryVariantsKey];
  if(variants.count) {
    NSInteger skinTone = self.appDelegate.skinTone;
    if(skinTone != -1) {
      return variants[skinTone];
    }
  }

  return dictionary[EIMDictionaryEmojiKey];
}


#pragma mark -
#pragma mark Action Method
- (IBAction)candidateSelected:(id)sender
{
  if([self.delegate respondsToSelector:@selector(candidateSelected:)]) {
    NSDictionary *dict = self.candidates[self.tableView.clickedRow];
    [self.delegate candidatesViewSelected:[self emojiWithDictionary:dict]];
  }
}


#pragma mark -
#pragma mark Accessor Method
- (EIMAppDelegate *)appDelegate
{
  return [NSApp delegate];
}

- (NSSize)footerViewSize
{
  return self.footerView.frame.size;
}


#pragma mark -
#pragma mark NSTableViewDataSource Method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.candidates.count;
}


#pragma mark -
#pragma mark NSTableViewDelegate Method
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  EIMCandidateCellView *cellView = [tableView makeViewWithIdentifier:kCandidateCellViewIdentifier owner:self];
  NSDictionary *dict = self.candidates[row];
  cellView.emojiLabel.stringValue = [self emojiWithDictionary:dict];

  NSString *name = dict[EIMDictionaryNameKey];
  NSMutableArray *ranges = [NSMutableArray array];
  for(NSString *keyword in self.currentKeywords) {
    NSRange range = [name rangeOfString:keyword options:NSCaseInsensitiveSearch];
    if(range.location != NSNotFound) {
      [ranges addObject:[NSValue valueWithRange:range]];
    }
  }
  NSColor *backgroundColor = [NSColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.3];
  NSDictionary *attributes = @{NSBackgroundColorAttributeName: backgroundColor};
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:dict[EIMDictionaryNameKey]];
  for(NSValue *rangeObject in ranges) {
    [attrString setAttributes:attributes range:rangeObject.rangeValue];
  }

  if(attrString.length > kMaxCharacterLengthOfLargeFontSize) {
    NSFont *font = [NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]];
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrString.length)];
  }

  cellView.titleLabel.attributedStringValue = attrString;

  return cellView;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
  EIMCandidateTableRowView *rowView = [[EIMCandidateTableRowView alloc] init];
  return rowView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSTableView *tableView = notification.object;
  NSInteger selectedRow = tableView.selectedRow;
  if(selectedRow != -1) {
    [tableView scrollRowToVisible:selectedRow];
    NSDictionary *dict = self.candidates[selectedRow];
    if([self.delegate respondsToSelector:@selector(candidatesViewSelectionChanged:)]) {
      [self.delegate candidatesViewSelectionChanged:[self emojiWithDictionary:dict]];
    }
  }
}

@end
