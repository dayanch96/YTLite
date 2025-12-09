#import "Headers/SponsorBlockViewController.h"
#import "Headers/Localization.h"

@implementation SponsorBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    [self setupViews];
}

- (NSArray *)skipSegments {
    // I'm using the playerBar skipSegments instead of the playerViewController ones because of the show in seek bar option
    YTPlayerView *playerView = (YTPlayerView *)self.playerViewController.view;
    YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)playerView.overlayView;
    if ([overlayView isKindOfClass:NSClassFromString(@"YTMainAppVideoPlayerOverlayView")]) {
        id <YTPlayerBarProtocol> object = [overlayView.playerBar respondsToSelector:@selector(modularPlayerBar)] ? overlayView.playerBar.modularPlayerBar : overlayView.playerBar.segmentablePlayerBar;
        if ([object isKindOfClass:NSClassFromString(@"YTSegmentableInlinePlayerBarView")])
            return ((YTSegmentableInlinePlayerBarView *)object).skipSegments;
        if ([object isKindOfClass:NSClassFromString(@"YTModularPlayerBarController")]) {
            YTModularPlayerBarView *view = ((YTModularPlayerBarController *)object).view;
            if ([view isKindOfClass:NSClassFromString(@"YTModularPlayerBarView")])
                return view.skipSegments;
        }
    }
    return nil;
}

- (void)setupViews {
    [self.segmentsInDatabaseLabel removeFromSuperview];
    [self.userSegmentsLabel removeFromSuperview];
    [self.submitSegmentsButton removeFromSuperview];
    [self.whitelistChannelLabel removeFromSuperview];
    
    self.sponsorSegmentViews = [NSMutableArray array];
    self.userSponsorSegmentViews = [NSMutableArray array];
    
    if (!self.startEndSegmentButton) {
        self.startEndSegmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.startEndSegmentButton.backgroundColor = UIColor.systemBlueColor;
        [self.startEndSegmentButton addTarget:self action:@selector(startEndSegmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.playerViewController.userSkipSegments.lastObject.endTime != -1) [self.startEndSegmentButton setTitle:LOC(@"SegmentStartsNow") forState:UIControlStateNormal];
        else [self.startEndSegmentButton setTitle:LOC(@"SegmentEndsNow") forState:UIControlStateNormal];
        self.startEndSegmentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self.playerViewController.view addSubview:self.startEndSegmentButton];
        
        self.startEndSegmentButton.layer.cornerRadius = 12;
        self.startEndSegmentButton.frame = CGRectMake(0,0,512,50);
        self.startEndSegmentButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.startEndSegmentButton.topAnchor constraintEqualToAnchor:self.playerViewController.view.bottomAnchor constant:10].active = YES;
        [self.startEndSegmentButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [self.startEndSegmentButton.widthAnchor constraintEqualToConstant:self.view.frame.size.width/2].active = YES;
        [self.startEndSegmentButton.heightAnchor constraintEqualToConstant:50].active = YES;
        self.startEndSegmentButton.clipsToBounds = YES;
    }
    
    self.whitelistChannelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.whitelistChannelLabel.text = LOC(@"WhitelistChannel");
    [self.playerViewController.view addSubview:self.whitelistChannelLabel];
    self.whitelistChannelLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.whitelistChannelLabel.topAnchor constraintEqualToAnchor:self.startEndSegmentButton.bottomAnchor constant:10].active = YES;
    [self.whitelistChannelLabel.centerXAnchor constraintEqualToAnchor:self.startEndSegmentButton.centerXAnchor].active = YES;
    [self.whitelistChannelLabel.widthAnchor constraintEqualToConstant:185].active = YES;
    [self.whitelistChannelLabel.heightAnchor constraintEqualToConstant:31].active = YES;
    self.whitelistChannelLabel.userInteractionEnabled = YES;
    
    UISwitch *whitelistSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,51,31)];
    [whitelistSwitch addTarget:self action:@selector(whitelistSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.whitelistChannelLabel addSubview:whitelistSwitch];
    whitelistSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [whitelistSwitch.leadingAnchor constraintEqualToAnchor:self.whitelistChannelLabel.trailingAnchor constant:-51].active = YES;
    [whitelistSwitch.centerYAnchor constraintEqualToAnchor:self.whitelistChannelLabel.centerYAnchor].active = YES;
    
    if ([kWhitelistedChannels containsObject:self.playerViewController.channelID]) {
        [whitelistSwitch setOn:YES animated:NO];
    }
    else {
        [whitelistSwitch setOn:NO animated:NO];
    }

    YTPlayerView *playerView = (YTPlayerView *)self.playerViewController.view;
    NSArray *skipSegments = [self skipSegments];
    if (skipSegments.count > 0) {
        self.segmentsInDatabaseLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.segmentsInDatabaseLabel.userInteractionEnabled = YES;
        
        self.segmentsInDatabaseLabel.text = LOC(@"SegmentsInDatabase");
        self.segmentsInDatabaseLabel.numberOfLines = 1;
        self.segmentsInDatabaseLabel.adjustsFontSizeToFitWidth = YES;
        self.segmentsInDatabaseLabel.textAlignment = NSTextAlignmentCenter;
        
        [playerView addSubview:self.segmentsInDatabaseLabel];
        self.segmentsInDatabaseLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.segmentsInDatabaseLabel.topAnchor constraintEqualToAnchor:self.whitelistChannelLabel.bottomAnchor constant:-15].active = YES;
        [self.segmentsInDatabaseLabel.centerXAnchor constraintEqualToAnchor:playerView.centerXAnchor].active = YES;
        [self.segmentsInDatabaseLabel.widthAnchor constraintEqualToAnchor:playerView.widthAnchor].active = YES;
        [self.segmentsInDatabaseLabel.heightAnchor constraintEqualToConstant:75.0f].active = YES;
        
        self.sponsorSegmentViews = [self segmentViewsForSegments:skipSegments editable:NO];
        
        for (int i = 0; i < self.sponsorSegmentViews.count; i++) {
            [self.segmentsInDatabaseLabel addSubview:self.sponsorSegmentViews[i]];
            [self.sponsorSegmentViews[i] addInteraction:[[UIContextMenuInteraction alloc] initWithDelegate:self]];
            
            self.sponsorSegmentViews[i].translatesAutoresizingMaskIntoConstraints = NO;
            [self.sponsorSegmentViews[i].widthAnchor constraintEqualToConstant:playerView.frame.size.width/self.sponsorSegmentViews.count-10].active = YES;
            [self.sponsorSegmentViews[i].heightAnchor constraintEqualToConstant:30].active = YES;
            [self.sponsorSegmentViews[i].topAnchor constraintEqualToAnchor:self.segmentsInDatabaseLabel.bottomAnchor constant:-25].active = YES;
            
            if (self.sponsorSegmentViews.count == 1) {
                [self.sponsorSegmentViews[i].centerXAnchor constraintEqualToAnchor:self.segmentsInDatabaseLabel.centerXAnchor].active = YES;
                break;
            }
            
            if (i > 0) {
                [self.sponsorSegmentViews[i].leftAnchor constraintEqualToAnchor:self.sponsorSegmentViews[i-1].rightAnchor constant:5].active = YES;
            }
            else {
                [self.sponsorSegmentViews[i].leftAnchor constraintEqualToAnchor:self.segmentsInDatabaseLabel.leftAnchor constant:5*(self.sponsorSegmentViews.count / 2)].active = YES;
            }
        }

    }
    
    if (self.playerViewController.userSkipSegments.count > 0) {
        self.userSegmentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userSegmentsLabel.userInteractionEnabled = YES;
        
        self.userSegmentsLabel.text = LOC(@"YourSegments");
        
        self.userSponsorSegmentViews = [self segmentViewsForSegments:self.playerViewController.userSkipSegments editable:YES];
        for (int i = 0; i < self.userSponsorSegmentViews.count; i++) {
            [self.userSegmentsLabel addSubview:self.userSponsorSegmentViews[i]];
            [self.userSponsorSegmentViews[i] addInteraction:[[UIContextMenuInteraction alloc] initWithDelegate:self]];
            
            self.userSponsorSegmentViews[i].translatesAutoresizingMaskIntoConstraints = NO;
            [self.userSponsorSegmentViews[i].widthAnchor constraintEqualToConstant:playerView.frame.size.width/self.userSponsorSegmentViews.count-10].active = YES;
            [self.userSponsorSegmentViews[i].heightAnchor constraintEqualToConstant:30].active = YES;
            [self.userSponsorSegmentViews[i].topAnchor constraintEqualToAnchor:self.userSegmentsLabel.bottomAnchor constant:-25].active = YES;
            
            if (self.userSponsorSegmentViews.count == 1) {
                [self.userSponsorSegmentViews[i].centerXAnchor constraintEqualToAnchor:self.userSegmentsLabel.centerXAnchor].active = YES;
                break;
            }
            
            if (i > 0) {
                [self.userSponsorSegmentViews[i].leftAnchor constraintEqualToAnchor:self.userSponsorSegmentViews[i-1].rightAnchor constant:5].active = YES;
            }
            else {
                [self.userSponsorSegmentViews[i].leftAnchor constraintEqualToAnchor:self.userSegmentsLabel.leftAnchor constant:5*(self.userSponsorSegmentViews.count / 2)].active = YES;
            }
        }
        self.userSegmentsLabel.numberOfLines = 2;
        self.userSegmentsLabel.adjustsFontSizeToFitWidth = YES;
        self.userSegmentsLabel.textAlignment = NSTextAlignmentCenter;
        
        [playerView addSubview:self.userSegmentsLabel];
        self.userSegmentsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (skipSegments.count > 0) [self.userSegmentsLabel.topAnchor constraintEqualToAnchor:self.segmentsInDatabaseLabel.bottomAnchor constant:-10].active = YES;
        else [self.userSegmentsLabel.topAnchor constraintEqualToAnchor:self.whitelistChannelLabel.bottomAnchor constant:-10].active = YES;
        
        [self.userSegmentsLabel.centerXAnchor constraintEqualToAnchor:playerView.centerXAnchor].active = YES;
        [self.userSegmentsLabel.widthAnchor constraintEqualToAnchor:playerView.widthAnchor].active = YES;
        [self.userSegmentsLabel.heightAnchor constraintEqualToConstant:75.0f].active = YES;
        
        self.submitSegmentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.submitSegmentsButton.backgroundColor = UIColor.systemBlueColor;
        
        [self.submitSegmentsButton addTarget:self action:@selector(submitSegmentsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.submitSegmentsButton setTitle:LOC(@"SubmitSegments") forState:UIControlStateNormal];
        
        [playerView addSubview:self.submitSegmentsButton];
        self.submitSegmentsButton.layer.cornerRadius = 12;
        self.submitSegmentsButton.frame = CGRectMake(0,0,512,50);
        
        self.submitSegmentsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.submitSegmentsButton.topAnchor constraintEqualToAnchor:self.userSegmentsLabel.bottomAnchor constant:15].active = YES;
        [self.submitSegmentsButton.centerXAnchor constraintEqualToAnchor:playerView.centerXAnchor].active = YES;
        [self.submitSegmentsButton.widthAnchor constraintEqualToConstant:self.view.frame.size.width/2].active = YES;
        [self.submitSegmentsButton.heightAnchor constraintEqualToConstant:50].active = YES;
        self.submitSegmentsButton.clipsToBounds = YES;
    }
}

- (void)whitelistSwitchToggled:(UISwitch *)sender {
    if (sender.isOn) {
        [kWhitelistedChannels addObject:self.playerViewController.channelID];
    }
    else {
        [kWhitelistedChannels removeObject:self.playerViewController.channelID];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
    
    [settings setValue:kWhitelistedChannels forKey:@"whitelistedChannels"];
    [settings writeToURL:[NSURL fileURLWithPath:settingsPath isDirectory:NO] error:nil];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.galacticdev.isponsorblockprefs.changed"), NULL, NULL, YES);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.startEndSegmentButton removeFromSuperview];
    [self.segmentsInDatabaseLabel removeFromSuperview];
    [self.userSegmentsLabel removeFromSuperview];
    [self.submitSegmentsButton removeFromSuperview];
    [self.whitelistChannelLabel removeFromSuperview];
    
    [self.previousParentViewController addChildViewController:self.playerViewController];
    [self.previousParentViewController.view addSubview:self.playerViewController.view];
    
    self.overlayView.isDisplayingSponsorBlockViewController = NO;
    self.overlayView.sponsorBlockButton.hidden = NO;
    self.overlayView.sponsorStartedEndedButton.hidden = NO;
    [self.overlayView setOverlayVisible:YES];
}

- (void)startEndSegmentButtonPressed:(UIButton *)sender {
    NSString *segmentStartsNowTitle = LOC(@"SegmentStartsNow");
    NSString *segmentEndsNowTitle = LOC(@"SegmentEndsNow");
    NSString *errorTitle = LOC(@"Error");
    NSString *okTitle = LOC(@"OK");
    NSInteger minutes = lroundf(self.playerViewController.userSkipSegments.lastObject.startTime)/60;
    NSInteger seconds = lroundf(self.playerViewController.userSkipSegments.lastObject.startTime)%60;
    NSString *errorMessage = [NSString stringWithFormat:@"%@ %ld:%02ld", LOC(@"EndTimeLessThanStartTime"), minutes, seconds];

    if ([sender.titleLabel.text isEqualToString:segmentStartsNowTitle]) {
        [self.playerViewController.userSkipSegments addObject:[[SponsorSegment alloc] initWithStartTime:self.playerViewController.currentVideoMediaTime endTime:-1 category:nil UUID:nil]];
        [sender setTitle:segmentEndsNowTitle forState:UIControlStateNormal];
    } else {
        self.playerViewController.userSkipSegments.lastObject.endTime = self.playerViewController.currentVideoMediaTime;
        if (self.playerViewController.userSkipSegments.lastObject.endTime != self.playerViewController.currentVideoMediaTime) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:errorTitle message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [sender setTitle:segmentStartsNowTitle forState:UIControlStateNormal];
    }
    [self setupViews];
}

- (void)submitSegmentsButtonPressed:(UIButton *)sender {
    for (SponsorSegment *segment in self.playerViewController.userSkipSegments) {
        if (segment.endTime == -1 || !segment.category) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"Error") message:LOC(@"UnfinishedSegments") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:LOC(@"OK") style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

    [SponsorBlockRequest postSponsorTimes:self.playerViewController.currentVideoID sponsorSegments:self.playerViewController.userSkipSegments userID:kUserID withViewController:self.previousParentViewController];
    [self.previousParentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableArray *)segmentViewsForSegments:(NSArray <SponsorSegment *> *)segments editable:(BOOL)editable {
    for (SponsorSegment *segment in segments) {
        if (!editable) {
            [self.sponsorSegmentViews addObject:[[SponsorSegmentView alloc] initWithFrame:CGRectMake(0,0,50,30) sponsorSegment:segment editable:editable]];
        }
        else {
            [self.userSponsorSegmentViews addObject:[[SponsorSegmentView alloc] initWithFrame:CGRectMake(0,0,50,30) sponsorSegment:segment editable:editable]];
        }
    }
    if (!editable) return self.sponsorSegmentViews;
    return self.userSponsorSegmentViews;
}


- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                        configurationForMenuAtLocation:(CGPoint)location {
    SponsorSegmentView *sponsorSegmentView = interaction.view;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

    UIContextMenuConfiguration *config = [UIContextMenuConfiguration configurationWithIdentifier:nil
    previewProvider:nil
    actionProvider:^UIMenu* _Nullable(NSArray<UIMenuElement*>* _Nonnull suggestedActions) {
        NSMutableArray *categoryActions = [NSMutableArray array];
        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"Sponsor") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"sponsor";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"sponsor" withViewController:self];
        }]];

        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"Intermission/IntroAnimation") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"intro";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"intro" withViewController:self];
        }]];

        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"Outro") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"outro";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"outro" withViewController:self];
        }]];

        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"InteractionReminder_Subcribe/Like") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"interaction";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"interaction" withViewController:self];
        }]];

        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"Unpaid/SelfPromotion") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"selfpromo";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"selfpromo" withViewController:self];
        }]];

        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"Non-MusicSection") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"music_offtopic";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"music_offtopic" withViewController:self];
        }]];

        [categoryActions addObject:[UIAction actionWithTitle:LOC(@"Preview") image:nil identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
            if (sponsorSegmentView.editable) {
                sponsorSegmentView.sponsorSegment.category = @"preview";
                [self setupViews];
                return;
            }
            [SponsorBlockRequest categoryVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] category:@"preview" withViewController:self];
        }]];

        NSMutableArray* actions = [NSMutableArray array];
        if (sponsorSegmentView.editable) {
            [actions addObject:[UIAction actionWithTitle:LOC(@"EditStartTime") image:[UIImage systemImageNamed:@"arrow.left.to.line"] identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"Edit") message:LOC(@"EditStartTime_Desc") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:LOC(@"OK") style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    f.numberStyle = NSNumberFormatterDecimalStyle;
                    
                    NSArray *strings = [alert.textFields[0].text componentsSeparatedByString:@":"];
                    if (strings.count != 2) return;
                    NSString *minutesString = strings[0];
                    NSString *secondsString = strings[1];
                    
                    CGFloat minutes = [[f numberFromString:minutesString] floatValue];
                    CGFloat seconds = [[f numberFromString:secondsString] floatValue];
                    sponsorSegmentView.sponsorSegment.startTime = (minutes*60)+seconds;
                    [self setupViews];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LOC(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                }];
                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                [alert addTextFieldWithConfigurationHandler:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }]];
            
            [actions addObject:[UIAction actionWithTitle:LOC(@"EditEndTime") image:[UIImage systemImageNamed:@"arrow.right.to.line"] identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"Edit") message:LOC(@"EditEndTime_Desc") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:LOC(@"OK") style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    f.numberStyle = NSNumberFormatterDecimalStyle;
                    
                    NSArray *strings = [alert.textFields[0].text componentsSeparatedByString:@":"];
                    if (strings.count != 2) return;
                    NSString *minutesString = strings[0];
                    NSString *secondsString = strings[1];
                    
                    CGFloat minutes = [[f numberFromString:minutesString] floatValue];
                    CGFloat seconds = [[f numberFromString:secondsString] floatValue];
                    sponsorSegmentView.sponsorSegment.endTime = (minutes*60)+seconds;
                    [self setupViews];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LOC(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                }];
                [alert addAction:defaultAction];
                [alert addAction:cancelAction];
                [alert addTextFieldWithConfigurationHandler:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }]];
            
            UIMenu *categoriesMenu = [UIMenu menuWithTitle:LOC(@"EditCategory") image:[UIImage systemImageNamed:@"square.grid.2x2"] identifier:nil options:0 children:categoryActions];
            [actions addObject:categoriesMenu];
            [actions addObject:[UIAction actionWithTitle:LOC(@"Delete") image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
                [self.playerViewController.userSkipSegments removeObject:sponsorSegmentView.sponsorSegment];
                [self setupViews];
            }]];
            
            UIMenu* menu = [UIMenu menuWithTitle:LOC(@"EditSegment") children:actions];
            return menu;
        }
        else {
            [actions addObject:[UIAction actionWithTitle:LOC(@"Upvote") image:[UIImage systemImageNamed:@"hand.thumbsup.fill"] identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
                [SponsorBlockRequest normalVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] type:YES withViewController:self];
            }]];
            
            [actions addObject:[UIAction actionWithTitle:LOC(@"Downvote") image:[UIImage systemImageNamed:@"hand.thumbsdown.fill"] identifier:nil handler:^(__kindof UIAction* _Nonnull action) {
                [SponsorBlockRequest normalVoteForSegment:sponsorSegmentView.sponsorSegment userID:[settings objectForKey:@"userID"] type:NO withViewController:self];
            }]];
            
            UIMenu *categoriesMenu = [UIMenu menuWithTitle:LOC(@"VoteToChangeCategory") image:[UIImage systemImageNamed:@"square.grid.2x2"] identifier:nil options:0 children:categoryActions];
            UIMenu* menu = [UIMenu menuWithTitle:LOC(@"VoteOnSegment") children:[actions arrayByAddingObject:categoriesMenu]];
            return menu;
        }
    }];
    return config;
}
@end
