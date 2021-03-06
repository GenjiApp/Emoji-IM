//
//  EIMCandidatesController.m
//  Emoji IM
//
//  Created by Genji on 2015/05/21.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "EIMCandidatesController.h"
#import "EIMAppDelegate.h"
#import "EIMPreferencesKeys.h"
#import "EIMResourceFileNames.h"


static NSString * const kCategoryPeopleKey = @"People";
static NSString * const kCategoryNatureKey = @"Nature";
static NSString * const kCategoryFoodAndDrinkKey = @"Food & Drink";
static NSString * const kCategoryCelebrationKey = @"Celebration";
static NSString * const kCategoryActivityKey = @"Activity";
static NSString * const kCategoryTravelAndPlacesKey = @"Travel & Places";
static NSString * const kCategoryObjectsAndSymbolsKey = @"Objects & Symbols";
static NSString * const kCategoryPictographsKey = @"Pictographs";
static NSString * const kCategoryTechnicalSymbolsKey = @"Technical Symbols";
static NSString * const kCategoryBulletsAndStarsKey = @"Bullets & Stars";
static NSString * const kCategoryPunctuationKey = @"Punctuation";
static NSString * const kCategoryMathSymbolsKey = @"Math Symbols";

static const NSUInteger kNumberOfShowingCandidates = 5;


static EIMCandidatesController *candidatesController;


@interface EIMCandidatesController ()

@property (nonatomic, readonly) EIMAppDelegate *appDelegate;
@property (nonatomic, strong) EIMCandidatesPanelController *panelController;
@property (nonatomic, strong) NSDictionary *emojiDictionary;

@end

@implementation EIMCandidatesController

+ (void)setupWithServer:(IMKServer *)server
{
  candidatesController = [[EIMCandidatesController alloc] init];

  NSBundle *mainBundle = [server bundle];
  NSStoryboard *storyboard = [NSStoryboard storyboardWithName:EIMCandidatesPanelStoryboardFileName bundle:mainBundle];
  candidatesController.panelController = [storyboard instantiateInitialController];
  NSURL *emojiDictionaryURL = [mainBundle URLForResource:EIMEmojiDictionaryFileName withExtension:@"plist"];
  NSDictionary *emojiDictionary = [NSDictionary dictionaryWithContentsOfURL:emojiDictionaryURL];
  candidatesController.emojiDictionary = emojiDictionary;
}

+ (void)showCandidatesPanelForClient:(id <IMKTextInput>)inputClient
{
  EIMCandidatesPanelController *panelController = candidatesController.panelController;
  EIMCandidatesViewController *viewController = panelController.candidatesViewController;

  NSRect lineHeightRectangle;
  NSDictionary *attributes = [inputClient attributesForCharacterIndex:0 lineHeightRectangle:&lineHeightRectangle];
  BOOL isTextOrientationHorizontally = YES;
  NSNumber *textOrientation = attributes[IMKTextOrientationName];
  if(textOrientation) {
    isTextOrientationHorizontally = [textOrientation boolValue];
  }

  NSRect frame = panelController.window.frame;
  CGFloat rowHeight = viewController.tableView.rowHeight;
  CGFloat footerViewHeight = viewController.footerViewSize.height;
  NSArray *candidates = viewController.candidates;
  if(candidates.count > kNumberOfShowingCandidates) {
    frame.size.height = rowHeight * (kNumberOfShowingCandidates + 0.5) + footerViewHeight;
  }
  else {
    frame.size.height = rowHeight * candidates.count + footerViewHeight;
  }

  if(isTextOrientationHorizontally) {
    frame.origin.x = lineHeightRectangle.origin.x - 5.0;
    frame.origin.y = lineHeightRectangle.origin.y - frame.size.height - 5.0;
    if(NSMaxX(frame) > [NSScreen mainScreen].frame.size.width) {
      frame.origin.x = [NSScreen mainScreen].frame.size.width - frame.size.width - 5.0;
    }
    if(frame.origin.x < 0) {
      frame.origin.x = 5.0;
    }
    if(frame.origin.y < 0) {
      frame.origin.y = NSMaxY(lineHeightRectangle) + 5.0;
    }
    if(frame.origin.y < 0) {
      frame.origin.y = 5.0;
    }
  }
  else {
    frame.origin.x = lineHeightRectangle.origin.x - frame.size.width - 5.0;
    frame.origin.y = lineHeightRectangle.origin.y - frame.size.height;
    if(NSMaxX(frame) > [NSScreen mainScreen].frame.size.width) {
      frame.origin.x = [NSScreen mainScreen].frame.size.width - frame.size.width - 5.0;
    }
    if(frame.origin.x < 0) {
      frame.origin.x = lineHeightRectangle.origin.x + lineHeightRectangle.size.width + 5.0;
    }
    if(frame.origin.x < 0) {
      frame.origin.x = 5.0;
    }
    if(frame.origin.y < 0) {
      frame.origin.y = 5.0;
    }
  }

  [panelController.window setFrame:frame display:YES];
  frame.origin = NSZeroPoint;
  [viewController.view setFrame:frame];

  panelController.window.level = [inputClient windowLevel] + 1;
  [panelController.window orderFrontRegardless];
}

+ (void)updateCandidatesWithString:(NSString *)string forClient:(id<IMKTextInput>)inputClient fromInputController:(id<EIMCandidatesViewDelegate>)inputController
{
  EIMCandidatesPanelController *panelController = candidatesController.panelController;
  EIMCandidatesViewController *viewController = panelController.candidatesViewController;
  viewController.delegate = inputController;

  if(string.length < 2) {
    [panelController close];
    return;
  }

  NSMutableArray *currentKeywords = [NSMutableArray array];
  NSArray *keywords = [string componentsSeparatedByString:@" "];
  NSMutableString *formatString = [NSMutableString string];
  for(NSString *keyword in keywords) {
    if(!keyword.length) {
      continue;
    }

    if(formatString.length) {
      [formatString appendString:@" AND "];
    }

    [currentKeywords addObject:keyword];
    [formatString appendFormat:@"%@ CONTAINS[c] '%@'", EIMDictionaryNameKey, keyword];
  }

  viewController.currentKeywords = currentKeywords;
  if(!formatString.length) {
    [panelController close];
    return;
  }

  NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];

  NSMutableArray *emojis = [NSMutableArray array];
  [emojis addObjectsFromArray:candidatesController.appDelegate.favorites];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryPeopleKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryNatureKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryFoodAndDrinkKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryCelebrationKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryActivityKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryTravelAndPlacesKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryObjectsAndSymbolsKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryPictographsKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryTechnicalSymbolsKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryBulletsAndStarsKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryPunctuationKey]];
  [emojis addObjectsFromArray:candidatesController.emojiDictionary[kCategoryMathSymbolsKey]];
  viewController.candidates = [emojis filteredArrayUsingPredicate:predicate];

  NSUInteger numberOfCandidates = viewController.candidates.count;
  if(numberOfCandidates) {
    [self showCandidatesPanelForClient:inputClient];
    viewController.numberOfCandidatesLabel.stringValue = [NSString stringWithFormat:NSLocalizedString(@"%lu candidate%@", nil), numberOfCandidates, (numberOfCandidates != 1) ? @"s" : @""];
  }
  else {
    [panelController close];
  }

  [viewController.tableView reloadData];
  [viewController.tableView scrollRowToVisible:0];
}

+ (void)closeCandidatesPanel
{
  [candidatesController.panelController close];
  [candidatesController.panelController.candidatesViewController.tableView deselectAll:nil];
}

+ (void)selectCandidateAtIndex:(NSUInteger)index
{
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
  [candidatesController.panelController.candidatesViewController.tableView selectRowIndexes:indexes byExtendingSelection:NO];
}

+ (void)selectPreviousCandidate
{
  EIMCandidatesViewController *viewController = candidatesController.panelController.candidatesViewController;
  NSInteger selectionRow = viewController.tableView.selectedRow;
  if(selectionRow == -1 || selectionRow == 0) {
    selectionRow = viewController.tableView.numberOfRows - 1;
  }
  else {
    selectionRow--;
  }

  [self selectCandidateAtIndex:selectionRow];
}

+ (void)selectNextCandidate
{
  EIMCandidatesViewController *viewController = candidatesController.panelController.candidatesViewController;
  NSInteger selectionRow = viewController.tableView.selectedRow;
  if(selectionRow == -1 || selectionRow == viewController.tableView.numberOfRows - 1) {
    selectionRow = 0;
  }
  else {
    selectionRow++;
  }

  [self selectCandidateAtIndex:selectionRow];
}

+ (BOOL)isPanelVisible
{
  return candidatesController.panelController.candidatesViewController.viewVisible;
}


#pragma mark -
#pragma mark Accessor Method
- (EIMAppDelegate *)appDelegate
{
  return [NSApp delegate];
}

@end
