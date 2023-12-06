clean:
	fvm flutter clean

install:
	fvm flutter pub get

generate:
	fvm flutter packages pub run build_runner build --delete-conflicting-outputs

localize:
	fvm flutter gen-l10n

analyze:
	fvm flutter analyze

format:
	fvm dart format . --line-length 120

test:
	fvm flutter test tests/unit_tests

dependency_check:
	fvm flutter pub outdated --no-dev-dependencies --up-to-date --no-dependency-overrides

launcher_icons:
	fvm flutter pub run flutter_launcher_icons
