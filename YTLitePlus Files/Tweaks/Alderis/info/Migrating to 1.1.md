## Migrating to 1.1

### ColorPickerConfiguration
A variety of configuration options have been added, configured on a new `ColorPickerConfiguration` class.

Code that looks like this:

```swift
let colorPicker = ColorPickerViewController()
colorPicker.color = UIColor(red: 1, green: 0, blue: 1, alpha: 0)
present(colorPicker, animated: true, completion: nil)
```

Should now become:

```swift
let configuration = ColorPickerConfiguration(color: UIColor(red: 1, green: 0, blue: 1, alpha: 0))
// Do any other configuration you want here…
let colorPicker = ColorPickerViewController(configuration: configuration)
present(colorPicker, animated: true, completion: nil)
```

### Delegate changes
`ColorPickerDelegate.colorPicker(_:didSelect:)` is now fired with every change made within the color picker interface. Ensure any work done in this method does not assume the value is the user’s final selection. You might use this to update your user interface based on the current selection. If there is nothing useful you can do to improve the user experience, don’t implement this method.

The new `ColorPickerDelegate.colorPicker(_:didAccept:)` method is now used to signal the user dismissing the color picker with a positive response, by tapping the Done button or dismissing the popover.

For compatibility, if the color is set via the deprecated `ColorPickerViewController.color` API, the delegate behaves as it did in Alderis 1.0.

### Popover style
Alderis now uses popovers, providing a more integrated interface design on iPad and Mac Catalyst. In order to support this, some popover presentation parameters must be set. If they are not set, UIKit throws an exception on presenting the view controller.

For example:

```swift
@IBAction func presentColorPicker(_ sender: UIView) {
	let configuration = ColorPickerConfiguration(color: UIColor(red: 1, green: 0, blue: 1, alpha: 0))
	let colorPicker = ColorPickerViewController(configuration: configuration)
	colorPicker.popoverPresentationController?.sourceView = sender
	present(colorPicker, animated: true, completion: nil)
}
```
