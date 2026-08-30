# SkyTrace developer commands.
# iOS targets require macOS + Xcode 26 and XcodeGen.

IOS_DIR := apps/ios
SCHEME := SkyTrace
PROJECT := $(IOS_DIR)/SkyTrace.xcodeproj
DESTINATION ?= platform=iOS Simulator,name=iPhone 16

.PHONY: help
help:
	@echo "SkyTrace make targets:"
	@echo "  make ios-project   Regenerate the canonical Xcode project with XcodeGen"
	@echo "  make ios-build     Build the app for the simulator"
	@echo "  make ios-test      Run unit + UI tests"
	@echo "  make open          Open the Xcode project"
	@echo "  make lint          Run SwiftLint if installed"
	@echo "  make verify        Run the Linux pre-build verification harness"
	@echo "  make fixtures      Extract demo fixtures -> docs/preview/data.json"
	@echo "  make preview       Extract fixtures and serve the interactive web preview"

.PHONY: verify
verify:
	python3 scripts/preflight.py

.PHONY: fixtures
fixtures:
	python3 scripts/extract_fixtures.py

.PHONY: preview
preview: fixtures
	@echo "Serving interactive preview at http://localhost:8001/preview/ (Ctrl-C to stop)"
	@cd docs && python3 -m http.server 8001

.PHONY: ios-project
ios-project:
	@if ! command -v xcodegen >/dev/null 2>&1; then \
		echo "XcodeGen is required. Install it with: brew install xcodegen"; \
		exit 1; \
	fi
	@echo "Generating with XcodeGen (canonical)"
	@cd $(IOS_DIR) && xcodegen generate

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
