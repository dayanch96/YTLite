# Return-YouTube-Dislikes

An iOS tweak that brings back dislikes on YouTube app, sideloadable.

## How it works

The tweak accesses the [Return YouTube Dislike](https://www.returnyoutubedislike.com) database. The 11-digit identifier of videos and shorts you watch will be shared with the Return YouTube Dislike server in order to retrieve dislike count data and have that replaced the "Dislike" text with the actual number.

The tweak also provides an option to submit your like/dislike data to their RYD database, along with your uniquely generated anonymous ID and the video identifier. Head over to Settings > "Return YouTube Dislike" and you will see "Enable vote submission" option near the bottom. This option is disabled by default.

## Building

- Clone this project (of course).
- Use latest [Theos](https://github.com/theos/theos).
- Clone [YouTubeHeader](https://github.com/PoomSmart/YouTubeHeader) to `$THEOS/include/YouTubeHeader`.
- Run `make` or `make package FINALPACKAGE=1` or `make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless` in your Terminal.

## Credits

Vote submission code is ported to Objective-C, from https://github.com/Anarios/return-youtube-dislike
