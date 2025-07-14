#!/bin/bash

# Create icons directory if it doesn't exist
mkdir -p web/icons

# Generate different sizes of icons
convert arcade.png -resize 16x16 web/icons/arcade-16.png
convert arcade.png -resize 32x32 web/icons/arcade-32.png
convert arcade.png -resize 96x96 web/icons/arcade-96.png
convert arcade.png -resize 192x192 web/icons/arcade-192.png
convert arcade.png -resize 512x512 web/icons/arcade-512.png

# Generate maskable icons (with padding for safe area)
convert arcade.png -resize 192x192 -gravity center -background none -extent 192x192 web/icons/arcade-maskable-192.png
convert arcade.png -resize 512x512 -gravity center -background none -extent 512x512 web/icons/arcade-maskable-512.png

# Copy 32x32 version as favicon
cp web/icons/arcade-32.png web/favicon.png

echo "Icons generated successfully!" 