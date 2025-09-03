#!/bin/bash
 
SCHEME='Connected_Hydration_iOS'
DESTINATION='platform=iOS Simulator,OS=latest,name=iPhone 16 Pro'

xcodebuild test -scheme $SCHEME -sdk iphonesimulator -destination "$DESTINATION" CODE_SIGNING_ALLOWED='NO'

