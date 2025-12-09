# DontEatMyContent
Prevent the notch/Dynamic Island from munching on 2:1 video content in YouTube

<p align="center">
  <img src="https://github.com/therealFoxster/DontEatMyContent/assets/77606385/c6e7be92-a6a6-4b0c-be97-bf490385fea1" width="640">
  <br>
  <a href="https://github.com/therealFoxster/DontEatMyContent/actions"><img src="https://img.shields.io/github/actions/workflow/status/therealfoxster/donteatmycontent/build.yml" alt="GitHub Actions Workflow Status"></a>
  <a href="https://github.com/therealFoxster/DontEatMyContent/releases/latest"><img src="https://img.shields.io/github/v/release/therealfoxster/donteatmycontent" alt="GitHub Release"></a>
</p>


## How it works
The rendering view is constrained to the [safe area layout guide](https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide?language=objc) of its container so it will always be below the notch and Dynamic Island ([learn more](https://developer.apple.com/documentation/uikit/uiview/positioning_content_relative_to_the_safe_area?language=objc)). These constraints are only activated for videos with 2:1 aspect ratio or wider to prevent unintended effects on videos with smaller aspect ratios. 

## Compatibility
Runs on all devices on iOS/iPadOS 14.0 or later, though I wouldn't recommend enabling the tweak if the notch doesn't cut into your videos.

## Grab it
- IPA file: https://therealfoxster.github.io/uYouPlus
- DEB file: https://github.com/therealFoxster/DontEatMyContent/releases/latest

## Preview - iPhone 15 Pro
### Default
<p align="center">
<img src="https://github.com/therealFoxster/DontEatMyContent/assets/77606385/9fb9de61-e199-431e-adc7-24c055e9f020" width="640">
</p>

### Tweaked
<p align="center">
<img src="https://github.com/therealFoxster/DontEatMyContent/assets/77606385/8bd720a5-554f-44ba-af5f-822d8557578a" width="640">
</p>

### Zoomed to fill
<p align="center">
<img src="https://github.com/therealFoxster/DontEatMyContent/assets/77606385/213bc8b9-0737-45ca-beaa-e8eae1081831" width="640">
</p>

## License
[The MIT License](LICENSE.md)
