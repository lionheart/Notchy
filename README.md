Notchy
======

This is the full source code to Notchy, an iOS app that was a collaboration between [Ryan Jones](https://twitter.com/rjonesy), [Brad Ellis](https://twitter.com/bradellis), and [I](https://twitter.com/dwlz).

## What is Notchy?

Notchy is an iOS app that makes pretty, shareable screenshots for the iPhone X and the iPhone XS.

App Store Link: https://itunes.apple.com/us/app/notchy/id1311762771?ls=1&mt=8&uo=4&at=1l3vbEC

Landing page: https://lionheartsw.com/software/notchy/

## Why Open Source

A few reasons:

1. The app doesn't make *that* much money, so it makes more sense to convert it to a community project.
2. I open source a lot of stuff, but I've never open sourced a complete iOS app. Seemed like a good opportunity to do that.
3. There are some goodies in here that couldn't be released in the live app ([hint hint](https://github.com/lionheart/Notchy/tree/master/App%20Review%20Blacklist.xcassets)).

### This is awesome. How can I give you money?

You can contribute in a few ways:

1. The *best* way to contribute is to fork the code and make an improvement.
2. Reach out to Ryan and I if you ever decide to visit Austin and buy us a coffee.
3. If you use any of the Notchy code in a proprietary, closed-source app, you can purchase a selling exception (see [below](#license)).
4. If you just want to send us money (you really don't need to do this though):

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MKLMSDV7HL9VJ"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!" /></a>

### I want to contribute! What can I work on?

Main TODOs (as I see them right now):

* [ ] Add support for the iPhone XS Max.
* [ ] Add support for the iPhone-that-shall-not-be-named-as-of-2018-09-28 per App Review.

### I have an idea. What should I do?

The first thing you should do is open an issue so we can discuss your plan in a little more detail before you work on a large pull request. I'd rather reject an idea *before* you put the time into it (I don't like wasting my time and don't want to waste yours, either). Once we've discussed your proposal, you can get started on writing code and then submit a PR.

## The code is confusing. Can you write more documentation?

Unfortunately, no. Not right now. I don't have time to write any more docs, but I'll happily accept pull requests that makes the code clearer for others.

## Local Setup

1. Install the Ruby in `.ruby-version` and Bundler.

        rbenv install
        gem install bundler

2. Install gems:

        bundle install

3. Then install iOS dependencies from CocoaPods.

        pod install

3. Open `Notchy.xcworkspace` to compile and run the project.

License
-------

Notchy is licensed under the [GNU GPL version 3 or any later version](https://www.gnu.org/licenses/gpl-3.0.html), which is considered a strict open-source license.

In short: you can modify and distribute the source code to others (and even sell it!) as long as you make the source code modifications freely available.

If you would like to sell a modified version of the software (or any component thereof) and do *not* want to release the source code, you may contact me and you can purchase a [selling exception](https://www.gnu.org/philosophy/selling-exceptions).
