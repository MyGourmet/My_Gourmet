
clean:
	fvm flutter clean && \
	fvm flutter pub get

run-build-runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

watch-build-runner:
	fvm flutter pub run build_runner watch --delete-conflicting-outputs

fix:
	fvm dart fix --apply