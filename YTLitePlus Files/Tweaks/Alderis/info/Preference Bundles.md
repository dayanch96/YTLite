## Alderis with Preference Bundles
Alderis acts as a drop-in replacement for [libcolorpicker](https://github.com/atomikpanda/libcolorpicker), an abandoned but still very popular color picker library on jailbroken iOS. Packages can simply change their dependencies list to replace `org.thebigboss.libcolorpicker` with `ws.hbang.alderis (>= 1.1)` to switch the color picker to Alderis. No other changes required!

Alderis also provides a replacement, cleaner interface for preference bundles. Example usage:

```xml
<dict>
	<key>cell</key>
	<string>PSLinkCell</string>
	<key>cellClass</key>
	<string>HBColorPickerTableCell</string>
	<key>defaults</key>
	<string>com.example.myawesomething</string>
	<key>default</key>
	<string>#33b5e5</string>
	<key>label</key>
	<string>Tint Color</string>
	<key>showAlphaSlider</key>
	<true/>
	<key>PostNotification</key>
	<string>com.example.myawesomething/ReloadPrefs</string>
</dict>
```

Compared to libcolorpicker’s API design, this leans on the fundamentals of Preferences.framework, including using the framework’s built-in preference value getters/setters system. In fact, the only two distinct parts are the `cellClass` and the `showAlphaSlider` key. The rest should seem natural to typical Preference specifier plist usage.

Remember to link against the `libcolorpicker` library from the preference bundle. With Theos, this might look like:

```make
MyAwesomeThing_LIBRARIES = colorpicker
```

The functionality described in this section is only available in the jailbreak package for Alderis, specifically in the `libcolorpicker.dylib` binary ([lcpshim](https://github.com/hbang/Alderis/tree/main/lcpshim)), and is not included in the App Store (CocoaPods/Carthage) version.
