#import "Headers/SponsorBlockSettingsController.h"
#import "Headers/Localization.h"

@implementation SponsorBlockTableCell
- (void)colorPicker:(id)colorPicker didSelectColor:(UIColor *)color {
    self.colorWell.color = color;
    NSString *hexString = hexFromUIColor(color);

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
    NSDictionary *categorySettings = [settings objectForKey:@"categorySettings"];

    [categorySettings setValue:hexString forKey:[NSString stringWithFormat:@"%@Color", self.category]];
    [settings setValue:categorySettings forKey:@"categorySettings"];
    [settings writeToURL:[NSURL fileURLWithPath:settingsPath isDirectory:NO] error:nil];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.galacticdev.isponsorblockprefs.changed"), NULL, NULL, YES);
}

- (void)presentColorPicker:(UITableViewCell *)sender {
    HBColorPickerViewController *viewController = [[objc_getClass("HBColorPickerViewController") alloc] init];
    viewController.delegate = self;
    viewController.popoverPresentationController.sourceView = self;

    HBColorPickerConfiguration *configuration = [[objc_getClass("HBColorPickerConfiguration") alloc] initWithColor:self.colorWell.color];
    configuration.supportsAlpha = NO;
    viewController.configuration = configuration;

    UIViewController *rootViewController = self._viewControllerForAncestor;
    [rootViewController presentViewController:viewController animated:YES completion:nil];
    
    //fixes the bottom of the color picker from getting cut off
    viewController.view.frame = CGRectMake(0,-50, viewController.view.frame.size.width, viewController.view.frame.size.height);
}
@end

@implementation SponsorBlockSettingsController
- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *dismissButton;

    dismissButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(dismissButtonTapped:)];

    dismissButton.tintColor = [UIColor labelColor];
    self.navigationItem.leftBarButtonItem = dismissButton;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.settingsPath = [documentsDirectory stringByAppendingPathComponent:@"iSponsorBlock.plist"];
    self.settings = [NSMutableDictionary dictionary];
    [self.settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:self.settingsPath]];

    self.view.backgroundColor = UIColor.systemBackgroundColor;

    //detects if device is an se gen 1 or not, crude fix for text getting cut off
    if ([UIScreen mainScreen].bounds.size.width > 320) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
    }
    else {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    }

    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    NSBundle *tweakBundle = iSponsorBlockBundle();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"LogoSponsorBlocker128px" ofType:@"png"]]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    label.text = @"iSponsorBlock";
    label.font = [UIFont boldSystemFontOfSize:48];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,200)];
    [self.tableView.tableHeaderView addSubview:imageView];
    [self.tableView.tableHeaderView addSubview:label];

    self.tweakTitle = label.text;

    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [imageView.topAnchor constraintEqualToAnchor:self.tableView.tableHeaderView.topAnchor constant:5].active = YES;
    [label.centerXAnchor constraintEqualToAnchor:imageView.centerXAnchor].active = YES;
    [label.topAnchor constraintEqualToAnchor:imageView.bottomAnchor constant:5].active = YES;

    //for dismissing num pad when tapping anywhere on the string
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    self.sectionTitles = @[LOC(@"Sponsor"), LOC(@"Intermission/IntroAnimation"), LOC(@"Endcards/Credits"), LOC(@"InteractionReminder"), LOC(@"Unpaid/SelfPromotion"), LOC(@"Non-MusicSection"), LOC(@"Preview"), LOC(@"SponsorBlockUserID"), LOC(@"SponsorBlockAPIInstance")];
}

//Add iSponsorBlock text to Navbar label if header text out of screen
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect labelCellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGRect visibleRect = CGRectMake(self.tableView.contentOffset.x,
                                    self.tableView.contentOffset.y + self.navigationController.navigationBar.frame.size.height,
                                    self.tableView.bounds.size.width,
                                    self.tableView.bounds.size.height - self.navigationController.navigationBar.frame.size.height);

    if (!CGRectContainsRect(visibleRect, labelCellRect)) {
        self.title = self.tweakTitle;
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationItem.titleView.alpha = 1.0;
        }];
    } else {
        self.title = nil;
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationItem.titleView.alpha = 0.0;
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 19;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else if (section <= 7 || section == 18) return 2;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SponsorBlockCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SponsorBlocKCell"];
    }

    if (indexPath.section == 0) {
        cell.textLabel.text = LOC(@"Enabled");
        UISwitch *enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,51,31)];
        cell.accessoryView = enabledSwitch;
        [enabledSwitch addTarget:self action:@selector(enabledSwitchToggled:) forControlEvents:UIControlEventValueChanged];
        if ([self.settings valueForKey:@"enabled"]) {
            [enabledSwitch setOn:[[self.settings valueForKey:@"enabled"] boolValue] animated:NO];
        }
        else {
            [enabledSwitch setOn:YES animated:NO];
            [self enabledSwitchToggled:enabledSwitch];
        }
        return cell;
    }

    if (indexPath.section <= 7) {
        SponsorBlockTableCell *tableCell = [[SponsorBlockTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SponsorBlockCell2"];
        NSDictionary *categorySettings = [self.settings objectForKey:@"categorySettings"];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[LOC(@"Disable"), LOC(@"AutoSkip"), LOC(@"ShowInSeekBar"), LOC(@"ManualSkip")]];

        //make it so "Show in Seek Bar" text won't be cut off on certain devices
        NSMutableArray *segments = [segmentedControl valueForKey:@"_segments"];
        UISegment *segment = segments[2];
        UILabel *label = [segment valueForKey:@"_info"];
        label.adjustsFontSizeToFitWidth = YES;

        switch (indexPath.section) {
            case 1:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"sponsor"] intValue];
                tableCell.category = @"sponsor";
                break;
            case 2:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"intro"] intValue];
                tableCell.category = @"intro";
                break;
            case 3:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"outro"] intValue];
                tableCell.category = @"outro";
                break;
            case 4:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"interaction"] intValue];
                tableCell.category = @"interaction";
                break;
            case 5:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"selfpromo"] intValue];
                tableCell.category = @"selfpromo";
                break;
            case 6:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"music_offtopic"] intValue];
                tableCell.category = @"music_offtopic";
                break;
            case 7:
                segmentedControl.selectedSegmentIndex = [[categorySettings objectForKey:@"preview"] intValue];
                tableCell.category = @"preview";
                break;
                
            default:
                break;
        }
        if (indexPath.row == 0) {
            [segmentedControl addTarget:self action:@selector(categorySegmentSelected:) forControlEvents:UIControlEventValueChanged];
            segmentedControl.apportionsSegmentWidthsByContent = YES;
            [tableCell.contentView addSubview:segmentedControl];
            segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
            [segmentedControl.centerYAnchor constraintEqualToAnchor:tableCell.contentView.centerYAnchor].active = YES;
            [segmentedControl.widthAnchor constraintEqualToAnchor:tableCell.contentView.widthAnchor].active = YES;
        }
        else {
            tableCell.textLabel.text = LOC(@"SetColorToShowInSeekBar");
            tableCell.textLabel.adjustsFontSizeToFitWidth = YES;
            HBColorWell *colorWell = [[objc_getClass("HBColorWell") alloc] initWithFrame:CGRectMake(0,0,32,32)];
            [colorWell addTarget:tableCell action:@selector(presentColorPicker:) forControlEvents:UIControlEventTouchUpInside];
            UIColor *color = colorWithHexString([categorySettings objectForKey:[NSString stringWithFormat:@"%@Color", tableCell.category]]);
            colorWell.color = color;
            tableCell.accessoryView = colorWell;
            tableCell.colorWell = colorWell;
        }
        return tableCell;
    }
    if (indexPath.section == 8) {
        UITableViewCell *textCell = [[UITableViewCell alloc] initWithStyle:1000 reuseIdentifier:@"SponsorBlockTextCell"];
        textCell.textLabel.text = LOC(@"UserID");
        textCell.textLabel.adjustsFontSizeToFitWidth = YES;
        [textCell editableTextField].text = [self.settings valueForKey:@"userID"];
        [textCell editableTextField].delegate = self;
        return textCell;
    }
    if (indexPath.section == 9) {
        UITableViewCell *textCell = [[UITableViewCell alloc] initWithStyle:1000 reuseIdentifier:@"SponsorBlockTextCell"];
        textCell.textLabel.text = LOC(@"API_URL");
        textCell.textLabel.adjustsFontSizeToFitWidth = YES;
        [textCell editableTextField].text = [self.settings valueForKey:@"apiInstance"];
        [textCell editableTextField].delegate = self;
        return textCell;
    }
    if (indexPath.section == 10) {
        UITableViewCell *textCell = [[UITableViewCell alloc] initWithStyle:1000 reuseIdentifier:@"SponsorBlockTextCell"];
        textCell.textLabel.text = LOC(@"MinimumSegmentDuration");
        textCell.textLabel.adjustsFontSizeToFitWidth = YES;
        [textCell editableTextField].text = [NSString stringWithFormat:@"%.1f", [[self.settings valueForKey:@"minimumDuration"] floatValue]];
        [textCell editableTextField].keyboardType = UIKeyboardTypeDecimalPad;
        [textCell editableTextField].delegate = self;
        return textCell;
    }
    if (indexPath.section == 11) {
        UITableViewCell *textCell = [[UITableViewCell alloc] initWithStyle:1000 reuseIdentifier:@"SponsorBlockTextCell"];
        textCell.textLabel.text = LOC(@"HowLongNoticeWillAppear");
        textCell.textLabel.adjustsFontSizeToFitWidth = YES;
        [textCell editableTextField].text = [NSString stringWithFormat:@"%.1f", [[self.settings valueForKey:@"skipNoticeDuration"] floatValue]];
        [textCell editableTextField].keyboardType = UIKeyboardTypeDecimalPad;
        [textCell editableTextField].delegate = self;
        return textCell;
    }
    if (indexPath.section >= 12 && indexPath.section < 18) {
        NSArray *titles = @[LOC(@"ShowSkipNotice"), LOC(@"ShowButtonsInPlayer"), LOC(@"HideStartEndButtonInPlayer"), LOC(@"ShowModifiedTime"), LOC(@"AudioNotificationOnSkip"), LOC(@"EnableSkipCountTracking")];
        NSArray *titlesNames = @[@"showSkipNotice", @"showButtonsInPlayer", @"hideStartEndButtonInPlayer", @"showModifiedTime", @"skipAudioNotification", @"enableSkipCountTracking"];
        UITableViewCell *tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SponsorBlockCell3"];

        tableCell.textLabel.text = titles[indexPath.section-12];
        tableCell.textLabel.adjustsFontSizeToFitWidth = YES;

        UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0,0,51,31)];
        tableCell.accessoryView = toggleSwitch;
        [toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        if ([self.settings valueForKey:titlesNames[indexPath.section-12]]) {
            [toggleSwitch setOn:[[self.settings valueForKey:titlesNames[indexPath.section-12]] boolValue] animated:NO];
        } else {
            [toggleSwitch setOn:YES animated:NO];
            [self switchToggled:toggleSwitch];
        }
        return tableCell;
    }
    if (indexPath.section == 18) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SponsorBlockDonationCell"];
        cell.textLabel.text = indexPath.row == 0 ? LOC(@"DonateOnVenmo") : LOC(@"DonateOnPayPal");
        cell.imageView.image = [UIImage systemImageNamed:@"dollarsign.circle.fill"];
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return nil;
    if (section <= 9) return self.sectionTitles[section-1];
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) return LOC(@"RestartFooter");
    if (section == 8) return LOC(@"UserIDFooter");
    if (section == 9) return LOC(@"APIFooter");
    if (section == 16) return LOC(@"AudioFooter");
    return nil;
}

//To allow highlights only for certain sections
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 18) {
        return YES;
    } else {
        return NO;
    }
}

- (void)dismissButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 18) {
        if (indexPath.row == 0) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"venmo://"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"venmo://venmo.com/code?user_id=3178620965093376215"] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://venmo.com/code?user_id=3178620965093376215"] options:@{} completionHandler:nil];
            }

        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/DBrett684"] options:@{} completionHandler:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //To prevent highlight sticking after pressing on buttons
}

- (void)enabledSwitchToggled:(UISwitch *)sender {
    [self.settings setValue:@(sender.on) forKey:@"enabled"];
    [self writeSettings];
}

- (void)switchToggled:(UISwitch *)sender {
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSArray *titlesNames = @[@"showSkipNotice", @"showButtonsInPlayer", @"hideStartEndButtonInPlayer", @"showModifiedTime", @"skipAudioNotification", @"enableSkipCountTracking"];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.settings setValue:@(sender.on) forKey:titlesNames[indexPath.section-12]];
    [self writeSettings];
}

- (void)categorySegmentSelected:(UISegmentedControl *)segmentedControl {
    NSMutableDictionary *categorySettings = [self.settings valueForKey:@"categorySettings"];
    [categorySettings setValue:@(segmentedControl.selectedSegmentIndex) forKey:[(SponsorBlockTableCell *)segmentedControl.superview.superview category]];

    [self.settings setValue:categorySettings forKey:@"categorySettings"];
    [self writeSettings];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;

    NSString *minimumDurationTitle = LOC(@"MinimumSegmentDuration");
    NSString *skipNoticeDurationTitle = LOC(@"HowLongNoticeWillAppear");
    NSString *userIDTitle = LOC(@"UserID");
    NSString *apiURLTitle = LOC(@"API_URL");

    if ([cell.textLabel.text isEqualToString:minimumDurationTitle]) {
        [self.settings setValue:[f numberFromString:textField.text] forKey:@"minimumDuration"];
    } else if ([cell.textLabel.text isEqualToString:skipNoticeDurationTitle]) {
        [self.settings setValue:[f numberFromString:textField.text] forKey:@"skipNoticeDuration"];
    } else if ([cell.textLabel.text isEqualToString:userIDTitle]) {
        [self.settings setValue:textField.text forKey:@"userID"];
    } else if ([cell.textLabel.text isEqualToString:apiURLTitle]) {
        [self.settings setValue:textField.text forKey:@"apiInstance"];
    }
    [self writeSettings];
}

- (void)writeSettings {
    [self.settings writeToURL:[NSURL fileURLWithPath:self.settingsPath isDirectory:NO] error:nil];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.galacticdev.isponsorblockprefs.changed"), NULL, NULL, YES);
}
@end
