# SkyTrace developer commands.
# Phase 1 targets require only macOS + Xcode 26. Backend targets arrive in Phase 2.

IOS_DIR := apps/ios
SCHEME := SkyTrace
PROJECT := $(IOS_DIR)/SkyTrace.xcodeproj
DESTINATION ?= platform=iOS Simulator,name=iPhone 16

.PHONY: help
help:
	@echo "SkyTrace make targets:"
	@echo "  make ios-project   Regenerate the Xcode project (prefers XcodeGen; falls back to the Python generator)"
	@echo "  make ios-build     Build the app for the simulator"
	@echo "  make ios-test      Run unit + UI tests"
	@echo "  make open          Open the Xcode project"
	@echo "  make lint          Run SwiftLint if installed"

.PHONY: ios-project
ios-project:
	@if command -v xcodegen >/dev/null 2>&1; then \
		echo "Generating with XcodeGen (canonical)"; \
		cd $(IOS_DIR) && xcodegen generate; \
	else \
		echo "XcodeGen not found; using bundled Python generator"; \
		python3 scripts/generate_xcodeproj.py; \
	fi

.PHONY: ios-build
ios-build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' build

.PHONY: ios-test
ios-test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' test

.PHONY: open
open:
	open $(PROJECT)

.PHONY: lint
lint:
	@if command -v swiftlint >/dev/null 2>&1; then swiftlint --quiet $(IOS_DIR); else echo "swiftlint not installed"; fi

# ---- Backend placeholders (Phase 2) ----
.PHONY: dev-backend seed test dev-admin
dev-backend:
	@echo "Phase 2: docker compose up (backend not yet scaffolded)"
seed:
	@echo "Phase 2: seed demo data into local DB"
test: ios-test
dev-admin:
	@echo "Phase 8: Next.js admin console"
