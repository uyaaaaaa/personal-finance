####################### Build stage #######################
FROM golang:1.24-alpine AS builder

# Define working directory
WORKDIR /app

# Copy dependencies of modules
COPY ./backend/go.*  ./
RUN go mod download

# Copy source code
COPY ./backend .

# Build applications
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./cmd/api/main.go

####################### Run stage #######################
FROM alpine:3.13

# Define working directory
WORKDIR /app

# Copy binary from build stage
COPY --from=builder /app/server .

# Add ca certificate(for HTTPS)
RUN apk --no-cache add ca-certificates

# Expose ports for application
EXPOSE 8080

# Run application when wake up container
ENTRYPOINT ["./server"]