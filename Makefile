.PHONY: setup generate lint lint-fix format

## Run once per clone to install git hooks
setup:
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit
	@echo "Git hooks installed. Run 'make lint' to verify."

## Regenerate Xcode project from project.yml
generate:
	xcodegen generate

## Run SwiftLint
lint:
	swiftlint lint

## Auto-fix SwiftLint violations then lint again
lint-fix:
	swiftlint lint --fix
	swiftlint lint

## Run SwiftFormat across the whole repo
format:
	swiftformat .
