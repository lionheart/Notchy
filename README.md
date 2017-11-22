Notchy
======

## Local Setup

1. Install the Ruby in `.ruby-version` and Bundler.

        rbenv install
        gem install bundler

2. Install gems:

        bundle install

3. Then install iOS dependencies from CocoaPods.

        pod install

3. Open `Notchy.xcworkspace` to compile and run the project.

## Submitting to the App Store

```
bundle exec fastlane release
```


