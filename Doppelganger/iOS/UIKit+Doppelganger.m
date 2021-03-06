//
//  UIKit+Doppelganger.m
//  Pods
//
//  Created by Sash Zats on 1/13/15.
//
//

#import "UIKit+Doppelganger.h"

#import "WMLArrayDiff.h"


static NSString *const WMLArrayDiffSourceIndexPathKey = @"WMLArrayDiffSourceIndexPathKey";
static NSString *const WMLArrayDiffDestinationIndexPathKey = @"WMLArrayDiffDestinationIndexPathKey";


@implementation UICollectionView (Doppelganger)

- (void)wml_applyBatchChangesForRows:(NSArray *)changes inSection:(NSUInteger)section completion:(void (^)(BOOL))completion {
    NSMutableArray *insertion = [NSMutableArray array];
    NSMutableArray *deletion = [NSMutableArray array];
    NSMutableArray *moving = [NSMutableArray array];
    
    for (WMLArrayDiff *diff in changes) {
        switch (diff.type) {
            case WMLArrayDiffTypeDelete:
                [deletion addObject:[NSIndexPath indexPathForItem:diff.previousIndex inSection:section]];
                break;
            
            case WMLArrayDiffTypeInsert:
                [insertion addObject:[NSIndexPath indexPathForItem:diff.currentIndex inSection:section]];
                break;

            case WMLArrayDiffTypeMove:
                [moving addObject:diff];
                break;
        }
    }
    
    [self performBatchUpdates:^{
        [self insertItemsAtIndexPaths:insertion];
        [self deleteItemsAtIndexPaths:deletion];
        for (WMLArrayDiff *diff in moving) {
            [self moveItemAtIndexPath:[NSIndexPath indexPathForItem:diff.previousIndex inSection:section]
                          toIndexPath:[NSIndexPath indexPathForItem:diff.currentIndex inSection:section]];
        }
    } completion:completion];
}

- (void)wml_applyBatchChangesForSections:(NSArray *)changes completion:(void (^)(BOOL))completion {
  NSMutableIndexSet *insertion = [NSMutableIndexSet indexSet];
  NSMutableIndexSet *deletion = [NSMutableIndexSet indexSet];
  NSMutableArray *moving = [NSMutableArray array];
  
  for (WMLArrayDiff *diff in changes) {
    switch (diff.type) {
      case WMLArrayDiffTypeDelete:
        [deletion addIndex:diff.previousIndex];
        break;
        
      case WMLArrayDiffTypeInsert:
        [insertion addIndex:diff.currentIndex];
        break;
        
      case WMLArrayDiffTypeMove:
        [moving addObject:diff];
        break;
    }
  }
  
  [self performBatchUpdates:^{
    [self insertSections:insertion];
    [self deleteSections:deletion];
    for (WMLArrayDiff *diff in moving) {
      [self moveSection:diff.previousIndex toSection:diff.currentIndex];
    }
  } completion:completion];
}

@end

@implementation UITableView (Doppelganger)

- (void)wml_applyBatchChangesForRows:(NSArray *)changes inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *insertion = [NSMutableArray array];
    NSMutableArray *deletion = [NSMutableArray array];
    NSMutableArray *moving = [NSMutableArray array];
    
    for (WMLArrayDiff *diff in changes) {
        switch (diff.type) {
            case WMLArrayDiffTypeDelete:
                [deletion addObject:[NSIndexPath indexPathForItem:diff.previousIndex inSection:section]];
                break;
                
            case WMLArrayDiffTypeInsert:
                [insertion addObject:[NSIndexPath indexPathForItem:diff.currentIndex inSection:section]];
                break;
                
            case WMLArrayDiffTypeMove:
                [moving addObject:diff];
                break;
        }
    }
    
    [self beginUpdates];
    [self deleteRowsAtIndexPaths:deletion withRowAnimation:animation];
    [self insertRowsAtIndexPaths:insertion withRowAnimation:animation];
    for (WMLArrayDiff *diff in moving) {
        [self moveRowAtIndexPath:[NSIndexPath indexPathForItem:diff.previousIndex inSection:section]
                     toIndexPath:[NSIndexPath indexPathForItem:diff.currentIndex inSection:section]];
    }
    [self endUpdates];
}

- (void)wml_applyBatchChangesForSections:(NSArray *)changes withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableIndexSet *insertion = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deletion = [NSMutableIndexSet indexSet];
    NSMutableArray *moving = [NSMutableArray array];
    
    for (WMLArrayDiff *diff in changes) {
        switch (diff.type) {
            case WMLArrayDiffTypeDelete:
                [deletion addIndex:diff.previousIndex];
                break;
                
            case WMLArrayDiffTypeInsert:
                [insertion addIndex:diff.currentIndex];
                break;
                
            case WMLArrayDiffTypeMove:
                [moving addObject:diff];
                break;
        }
    }
    
    [self beginUpdates];
    [self deleteSections:deletion withRowAnimation:animation];
    [self insertSections:insertion withRowAnimation:animation];
    for (WMLArrayDiff *diff in moving) {
        [self moveSection:diff.previousIndex toSection:diff.currentIndex];
    }
    [self endUpdates];
}

@end
