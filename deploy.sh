#!/bin/bash

# Build the Flutter web app
flutter build web --base-href "/news_explorer_app/"

# Copy the contents of build/web to the root directory
cp -r build/web/* . 