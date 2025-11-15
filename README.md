# Visual Image Compare

A macOS application for visually comparing two images side-by-side to identify differences.

## Overview

Visual Image Compare is a native macOS app built with SwiftUI that helps you quickly spot differences between two images. Perfect for designers, developers, QA testers, and anyone who needs to compare image versions or verify visual changes.

## Features

- **Drag & Drop Interface**: Simply drag and drop images into the comparison zones
- **Visual Difference Highlighting**: Automatically generates a difference map showing where images differ
- **Identical Image Detection**: Instantly identifies when two images are pixel-perfect matches
- **Customizable Background Color**: Change the background color for better difference visibility
- **Size Validation**: Ensures images are the same dimensions before comparison
- **Automatic Scaling**: Handles large images by automatically scaling them to fit (max height: 800px)

## How to Use

1. **Load Images**: Drag and drop your first image into the left drop zone and your second image into the right drop zone
2. **Compare**: Click the "Compare" button in the center
3. **View Results**: The difference map appears on the right, highlighting areas where the images differ
   - White/background color areas indicate identical pixels
   - Colored areas show differences between the images
4. **Adjust Background**: Use the **View > Background Color** menu to change the background color for better contrast

## Use Cases

- **Design Review**: Compare design iterations to see exactly what changed
- **QA Testing**: Verify UI consistency across different builds or platforms
- **Asset Verification**: Ensure images match specifications or previous versions
- **Screenshot Comparison**: Compare before/after screenshots to validate fixes or changes

## Screenshots

### Comparing Similar Images

![Visual Image Compare Example](screenshots/Output.png)

*Example showing two similar images with subtle differences highlighted*

## Requirements

- macOS Tahoe 26.0 or later

## Tips

- Images must be the same size (dimensions) to be compared
- The app automatically scales large images to fit on screen
- Use the background color setting to improve visibility of differences
- The "Images are Identical" overlay appears when images are pixel-perfect matches

## License

Copyright © 2025 hot-n-GUI, LLC. All rights reserved.

<br>
<b>If you want to support my work, you can by me a coffee (umm, make that a coke zero...)<br>

<a href='https://ko-fi.com/F1F4UHD6J' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coke Zero	 at ko-fi.com' /></a>


---

**Note**: This app performs pixel-level comparison, so even minor differences (anti-aliasing, compression artifacts, etc.) will be detected.
