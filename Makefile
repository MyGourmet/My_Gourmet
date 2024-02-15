
.PHONY: setup
setup:
	$(MAKE) setup-fvm
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

.PHONY: setup-fvm
setup-fvm:
	dart pub global activate fvm
	@echo "# fvm" >> $(HOME)/.zshrc
	@echo 'export PATH="$$PATH:$$HOME/.pub-cache/bin"' >> $(HOME)/.zshrc
	@FLUTTER_VERSION=$$(cat ".fvm/fvm_config.json" | grep flutterSdkVersion | cut -d '"' -f 4) && \
	fvm install $(FLUTTER_VERSION)  && \
	fvm use $(FLUTTER_VERSION)