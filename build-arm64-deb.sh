#!/bin/bash
set -e

# 1. Build the Flutter App
echo "Building Flutter Linux App..."
flutter build linux --release

# 2. Prepare staging directory
echo "Preparing staging directory..."
STAGING_DIR="deb_staging_arm64"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR/DEBIAN"
mkdir -p "$STAGING_DIR/usr/bin"
mkdir -p "$STAGING_DIR/usr/lib/edgex_ui_flutter"

# 3. Create Control File
cat <<EOF > "$STAGING_DIR/DEBIAN/control"
Package: edgex-ui-flutter
Version: 1.0.0
Section: utils
Priority: optional
Architecture: arm64
Maintainer: Amit <amit@example.com>
Depends: libgtk-3-0, libblkid1, liblzma5
Description: EdgeX UI Flutter Application (ARM64)
 A lightweight Flutter-based UI for monitoring and managing EdgeX Foundry V3 services.
EOF

# 4. Copy Build Artifacts
echo "Copying build artifacts..."
cp -r build/linux/arm64/release/bundle/* "$STAGING_DIR/usr/lib/edgex_ui_flutter/"
ln -sf /usr/lib/edgex_ui_flutter/edgex_ui_flutter "$STAGING_DIR/usr/bin/edgex-ui-flutter"

# 5. Build DEB Package
echo "Building DEB package..."
DEB_FILE="edgex-ui-flutter_1.0.0_arm64.deb"
dpkg-deb --build "$STAGING_DIR" "$DEB_FILE"

echo "✅ Success! ARM64 package created: $DEB_FILE"
