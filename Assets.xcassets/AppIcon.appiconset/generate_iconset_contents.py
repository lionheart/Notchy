#!/usr/bin/env python

# Usage: ls *.png | ./generate_iconset_contents.py

import sys
import re
import json

r = re.compile(".*(AppStore|iPhone|iPad).*-([\d\.]+)(@\dx)?\.png")

idioms = {
    'AppStore': "ios-marketing",
    'iPhone': "iphone",
    'iPad': "ipad"
}

items = {
    'images': [],
    'info': {
        'version': 1,
        'author': "xcode",
    }
}

filenames = sys.stdin
for filename in filenames:
    print(filename)
    match = r.match(filename)
    groups = match.groups()

    item = {
        'filename': filename.strip(),
        'idiom': idioms[groups[0]],
        'size': "{0}x{0}".format(groups[1]),
    }

    if groups[2]:
        item['scale'] = groups[2][1:]
    else:
        item['scale'] = '1x'

    items['images'].append(item)

with open("Contents.json", 'w') as f:
    json.dump(items, f)
