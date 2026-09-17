set -e
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
flutter config --enable-web
flutter pub get
flutter build web --release

