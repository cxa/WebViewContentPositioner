# WebViewContentPositioner

`WebViewContentPositioner` is a scroll position maintainer for `UIWebView`. Never losing scroll position when view resizing on device rotation, split window changing, etc., even if view restoration.

## How to Use

1. Add the `WebViewContentPositioner` repository as a submodule of your application’s repository.
2. Drag and drop `WebViewContentPositioner.xcodeproj` into your application’s Xcode project or workspace.
3. On the “General” tab of your application target’s settings, add `WebViewContentPositioner.framework` to the “Embedded Binaries” section.

Or, If you would prefer to use Carthage or CocoaPods, please pull request.

`WebViewContentPositioner` tracks scroll position automatically for device rotation and split window size changing (by swizzling `- traitCollectionDidChange:`). Plus, you can save current position as a JSON String by `[UIWebView -currentPosition]` and restore by `[UIWebView -restorePosition:]` if needed.

See a real usage inside `Demo` folder.


## Gotcha

`WebViewContentPositioner` may fail if web page contains position-fixed elements on top. It's not intent to be used in a browser but EPUB reader like project.

## About Me

* Twitter: [@_cxa](https://twitter.com/_cxa)
* Apps available in App Store: <http://lazyapps.com>
* PayPal: xianan.chen+paypal 📧 gmail.com, buy me a cup of coffee if you find it's useful for you.

## License

`DOMContentLoadedDelegate` is released under the MIT license. In short, it's royalty-free but you must keep the copyright notice in your code or software distribution.

Some functions in JS are derived from [Firebug](https://github.com/firebug/firebug), it is free and open source software distributed under the BSD License.
