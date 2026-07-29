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
	@echo "  make dev-backend   Run the local mock API server (services/api)"
	@echo "  make api-test      Run the backend contract tests (pytest)"

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

# ---- Backend (Phase 2: local mock server; docs/openapi is the contract) ----
API_DIR := services/api

.PHONY: api-install
api-install:
	cd $(API_DIR) && pip install -r requirements.txt

.PHONY: dev-backend
dev-backend: api-install
	cd $(API_DIR) && uvicorn app.main:app --reload --port 8000

.PHONY: api-test
api-test: api-install
	cd $(API_DIR) && pytest tests/ -v

seed:
	@echo "Phase 3+: seed demo data into a real DB once PostgreSQL/PostGIS is scaffolded"

.PHONY: test
test: ios-test api-test

.PHONY: dev-admin
dev-admin:
	@echo "Phase 8: Next.js admin console"
