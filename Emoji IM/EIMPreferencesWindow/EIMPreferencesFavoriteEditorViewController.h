//
//  EIMPreferencesFavoriteEditorViewController.h
//  Emoji IM
//
//  Created by Genji on 2015/05/11.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, EIMFavoriteEditorMode) {
  EIMFavoriteEditorModeAdd = 0,
  EIMFavoriteEditorModeEdit,
};

@protocol EIMPreferencesFavoriteEditorViewDelegate;

@interface EIMPreferencesFavoriteEditorViewController : NSViewController

@property (nonatomic, weak) id <EIMPreferencesFavoriteEditorViewDelegate> delegate;
@property (nonatomic) EIMFavoriteEditorMode editorMode;
@property (nonatomic, strong) NSDictionary *editingFavoriteDictionary;

@end


@protocol EIMPreferencesFavoriteEditorViewDelegate <NSObject>

- (void)favoriteEditorView:(EIMPreferencesFavoriteEditorViewController *)viewController didEndEdit:(NSDictionary *)favoriteDictionary;

@end