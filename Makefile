.PHONY: install install-buf install-protoc-gen-go install-protoc-gen-connect-go install-golangci-lint check format lint generate test build run clean help

.DEFAULT_GOAL = build
SERVICE_NAME = quiz-registry

# Install all tools
install: install-buf install-protoc-gen-go install-protoc-gen-connect-go install-golangci-lint
	@echo "All tools installed successfully!"

install-buf:
	@echo "Installing buf..."
	go install github.com/bufbuild/buf/cmd/buf@latest

install-protoc-gen-go:
	@echo "Installing protoc-gen-go..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

install-protoc-gen-connect-go:
	@echo "Installing protoc-gen-connect-go..."
	go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest

install-golangci-lint:
	@echo "Installing golangci-lint..."
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

# Check if tools are installed and show versions
check:
	@echo "Checking installed tools..."
	@which buf >/dev/null 2>&1 && echo "✓ buf v$$(buf --version)" || echo "✗ buf not found"
	@which protoc-gen-go >/dev/null 2>&1 && echo "✓ $$(protoc-gen-go --version)" || echo "✗ protoc-gen-go not found"
	@which protoc-gen-connect-go >/dev/null 2>&1 && echo "✓ protoc-gen-connect-go v$$(protoc-gen-connect-go --version)" || echo "✗ protoc-gen-connect-go not found"
	@which golangci-lint >/dev/null 2>&1 && echo "✓ golangci-lint v$$(golangci-lint version --short)" || echo "✗ golangci-lint not found"

format:
	@echo "Formatting protobuf definitions..."
	buf format -w
	@echo "Formatting Go source files..."
	golangci-lint fmt

lint:
	@echo "Running Go linters with golangci-lint..."
	golangci-lint run
	@echo "Linting protobuf definitions with buf..."
	buf lint

generate:
	@echo "Generating protobuf/connect code with buf..."
	buf generate --clean

test: generate
	@echo "Running Go tests..."
	go test ./...

build: generate
	@echo "Building Go binaries..."
	mkdir -p bin
	go build -o bin/$(SERVICE_NAME) ./cmd/$(SERVICE_NAME)

run:
	@echo "Starting $(SERVICE_NAME) service..."
	go run ./cmd/$(SERVICE_NAME)

clean:
	@echo "Cleaning generated binaries..."
	rm -rf bin

help:
	@echo "Available targets:"
	@echo "  install                            - Install all tools"
	@echo "  install-buf                        - Install buf only"
	@echo "  install-protoc-gen-go              - Install protoc-gen-go only"
	@echo "  install-protoc-gen-connect-go      - Install protoc-gen-connect-go only"
	@echo "  install-golangci-lint              - Install golangci-lint only"
	@echo "  check                              - Check if tools are installed"
	@echo "  format                             - Format proto and Go source files"
	@echo "  lint                               - Run Go and proto linters"
	@echo "  generate                           - Generate protobuf/connect code"
	@echo "  test                               - Run Go tests"
	@echo "  build                              - Build packages"
	@echo "  run                                - Build and start the service locally"
	@echo "  clean                              - Clean generated code and binaries"
	@echo "  help                               - Show this help message"
