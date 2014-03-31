//
// Created by Marcelo Schroeder on 1/08/13.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


@implementation UITableViewCell (IACategory)

#pragma mark - Public

- (void)m_prepareForReuse {
    [[self m_appearanceTheme] m_setAppearanceOnPrepareForReuseForCell:self];
}

@end