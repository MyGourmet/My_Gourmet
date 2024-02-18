
.PHONY: setup
setup:
	fvm install --setup
	$(MAKE) run-build-runner

.PHONY: clean
clean:
	fvm flutter clean
	fvm flutter pub get

.PHONY: run-build-runner
run-build-runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

.PHONY: watch-build-runner
watch-build-runner:
	fvm flutter pub run build_runner watch --delete-conflicting-outputs

.PHONY: fix
fix:
	fvm dart fix --apply
