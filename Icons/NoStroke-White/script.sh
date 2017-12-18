#!/bin/bash

ICON="NoStrokeWhite"
OUTPUT="file.plist"
rm $OUTPUT
/usr/libexec/PlistBuddy -c "Add :$ICON dict" $OUTPUT
/usr/libexec/PlistBuddy -c "Add :$ICON:UIPrerenderedIcon bool YES" $OUTPUT
/usr/libexec/PlistBuddy -c "Add :$ICON:CFBundleIconFiles array" $OUTPUT

for item in *.png; do
    filename=`basename $item .png`
    /usr/libexec/PlistBuddy -c "Add :$ICON:CFBundleIconFiles: string $filename" $OUTPUT
done
