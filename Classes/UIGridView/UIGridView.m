//
//  UIGridViewView.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "UIGridViewCell.h"
#import "UIGridViewRow.h"

@implementation UIGridView


@synthesize uiGridViewDelegate;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder
{
	
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}


- (void) setUp
{
	self.delegate = self;
	self.dataSource = self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	self.delegate = nil;
	self.dataSource = nil;
	self.uiGridViewDelegate = nil;
    [super dealloc];
}

- (UIGridViewCell *) dequeueReusableCell
{
	UIGridViewCell* temp = tempCell;
	tempCell = nil;
	return temp;
}


// UITableViewController specifics
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int residue =  ([uiGridViewDelegate numberOfCellsOfGridView:self] % [uiGridViewDelegate numberOfColumnsOfGridView:self]);
	
	if (residue > 0) residue = 1;
	
	return ([uiGridViewDelegate numberOfCellsOfGridView:self] / [uiGridViewDelegate numberOfColumnsOfGridView:self]) + residue;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [uiGridViewDelegate gridView:self heightForRowAt:indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UIGridViewRow";
	
    UIGridViewRow *row = (UIGridViewRow *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil) {
        row = [[[UIGridViewRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	int numCols = [uiGridViewDelegate numberOfColumnsOfGridView:self];
	int count = [uiGridViewDelegate numberOfCellsOfGridView:self];
	
	CGFloat x = 0.0;
	CGFloat height = [uiGridViewDelegate gridView:self heightForRowAt:indexPath.row];
	
	for (int i=0;i<numCols;i++) {
		
		if ((i + indexPath.row * numCols) >= count) {
			
			if ([row.contentView.subviews count] > i) {
				((UIGridViewCell *)[row.contentView.subviews objectAtIndex:i]).hidden = YES;
			}
			
			continue;
		}
		
		if ([row.contentView.subviews count] > i) {
			tempCell = [row.contentView.subviews objectAtIndex:i];
		} else {
			tempCell = nil;
		}
		
		UIGridViewCell *cell = [uiGridViewDelegate gridView:self 
												cellForRowAt:indexPath.row 
												 AndColumnAt:i];
		
		if (cell.superview != row.contentView) {
			[cell removeFromSuperview];
			[row.contentView addSubview:cell];
			
			// Add gesture recoginzers:
			// 1. Single tap
			UITapGestureRecognizer *tapGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPressed:)] autorelease];
			[cell addGestureRecognizer:tapGR];
			
			// 2. Long press
			UILongPressGestureRecognizer *longPressGR = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressed:)] autorelease];
			[cell addGestureRecognizer:longPressGR];
			
			// 3. Double tap
			// It is disable due to delays
			/*
			UITapGestureRecognizer *doubleTapGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDoublePressed:)] autorelease];
			doubleTapGR.numberOfTapsRequired = 2;
			[cell addGestureRecognizer:doubleTapGR];
			[tapGR requireGestureRecognizerToFail:doubleTapGR];
			 */
		}
		
		cell.hidden = NO;
		cell.rowIndex = indexPath.row;
		cell.colIndex = i;
		
		CGFloat thisWidth = [uiGridViewDelegate gridView:self widthForColumnAt:i];
		cell.frame = CGRectMake(x, 0, thisWidth, height);
		x += thisWidth;
	}
	
	row.frame = CGRectMake(row.frame.origin.x,
							row.frame.origin.y,
							x,
							height);
	
    return row;
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction) cellPressed:(id) sender
{
	UIGestureRecognizer *recoginizer = (UIGestureRecognizer *)sender;
	UIGridViewCell *cell = (UIGridViewCell *)recoginizer.view;

	[uiGridViewDelegate gridView:self didSelectRowAt:cell.rowIndex AndColumnAt:cell.colIndex];
}


////////////////////////////////////////////////////////////////////////////////


-(IBAction)cellLongPressed:(id)sender
{
	UIGestureRecognizer *recoginizer = (UIGestureRecognizer *)sender;
	UIGridViewCell *cell = (UIGridViewCell *)recoginizer.view;
	
	// Invoke the delegate only at the beginning of recognizing.
	// If not do so, the delegate is invoked twice: at the beggining and at the end
	if (recoginizer.state == UIGestureRecognizerStateBegan)
		[uiGridViewDelegate gridView:self didLongPressRowAt:cell.rowIndex AndColumnAt:cell.colIndex];
}



////////////////////////////////////////////////////////////////////////////////


-(IBAction)cellDoublePressed:(id)sender
{
	UIGestureRecognizer *recoginizer = (UIGestureRecognizer *)sender;
	UIGridViewCell *cell = (UIGridViewCell *)recoginizer.view;
	
	[uiGridViewDelegate gridView:self didDoublePressRowAt:cell.rowIndex AndColumnAt:cell.colIndex];
}



////////////////////////////////////////////////////////////////////////////////

@end
