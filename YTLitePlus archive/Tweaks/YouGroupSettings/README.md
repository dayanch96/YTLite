# YouGroupSettings

A YouTube iOS tweak to allow custom settings (made by tweaks) to be displayed when the grouped settings experiment is active (`YTColdConfig.mainAppCoreClientEnableCairoSettings`), without any extra configurations. This supports YouTube version 19.03.2 and higher (iOS 14.0+).

## Supported Tweaks

Currently, this tweak will group the following YouTube tweaks into a dedicated group named "Tweaks" when the grouped settings experiment is active:

- DontEatMyContent
- Return YouTube Dislike
- YTUHD
- YouChooseQuality
- YouPiP
- YTABConfig
- YTHoldForSpeed
- YTIcons
- YTVideoOverlay
- uYou+
- Gonerino

### Adding Support for a Tweak

You can either create a pull request to this project to add your tweak setting constant or hook `+(NSMutableArray <NSNumber *> *)[YTSettingsGroupData tweaks]` method (added by YouGroupSettings) to add your tweak setting constant to the array. The constant must be unique and not already used by other tweaks.

Alternatively, you can create an entirely new group of settings by basically copying the related hooks from this project and modifying them to fit your needs. The `GROUP_TYPE` constant must be different from what this project already has.

## Setting Icons

If `nil` is provided to the `icon` argument of the setting-adding method `-[YTSettingsViewController setSectionItems:forCategory:title:icon:titleDescription:headerHidden:]` from a tweak that is supported above, the default instance of `YTIIcon` with `iconType` of `YT_SETTINGS` (`44`) will be used. This icon is an outline setting gear.

You can override this icon by supplying a `YTIIcon` instance with a different icon type to the `icon` argument of the method above in your tweak code. For example:

```objc
YTSettingsViewController *settingsViewController = ...;
YTIIcon *icon = [%c(YTIIcon) new];
icon.iconType = <type as number>;

[settingsViewController setSectionItems:items forCategory:category title:title icon:icon titleDescription:titleDescription headerHidden:headerHidden];
```
