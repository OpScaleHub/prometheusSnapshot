# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o snapshotter .

# Final stage
FROM alpine:3.18
LABEL maintainer="github.com/OpScale"

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/snapshotter /usr/local/bin/snapshotter

# Add non root user
RUN adduser -D -g '' snapshotter

# Set directory permissions
RUN chown -R snapshotter:snapshotter /app

# Use non root user
USER snapshotter

# Command to run
ENTRYPOINT ["/usr/local/bin/snapshotter"]