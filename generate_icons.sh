#!/bin/bash

# Create the icon directory if it doesn't exist
mkdir -p InfiniVision/Assets.xcassets/AppIcon.appiconset

# Copy the source icon
cp icon.png InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png

# macOS icons
sips -z 16 16 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_16.png
sips -z 32 32 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_16@2x.png
sips -z 32 32 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_32.png
sips -z 64 64 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_32@2x.png
sips -z 128 128 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_128.png
sips -z 256 256 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_128@2x.png
sips -z 256 256 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_256.png
sips -z 512 512 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_256@2x.png
sips -z 512 512 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_512.png
cp InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_512@2x.png

# iOS icons
sips -z 20 20 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_20.png
sips -z 40 40 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_20@2x.png
sips -z 60 60 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_20@3x.png
sips -z 29 29 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_29.png
sips -z 58 58 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_29@2x.png
sips -z 87 87 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_29@3x.png
sips -z 40 40 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_40.png
sips -z 80 80 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_40@2x.png
sips -z 120 120 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_40@3x.png
sips -z 120 120 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_60@2x.png
sips -z 180 180 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_60@3x.png
sips -z 76 76 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_76.png
sips -z 152 152 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_76@2x.png
sips -z 167 167 InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png --out InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_83.5@2x.png

# visionOS icon
cp InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_1024.png InfiniVision/Assets.xcassets/AppIcon.appiconset/icon_visionos.png 