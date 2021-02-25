# Start from golang base image
FROM golang:alpine as builder

LABEL maintainer="Caleb Todd <caleb.e.todd@gmail.com>"

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Install git.
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o .

# Start a new stage from scratch
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage.
COPY --from=builder /build/hello-api .
# copying the .env file
COPY --from=builder /build/.env .

# Expose port 8080 to the outside world
EXPOSE 8080

#Command to run the executable
CMD ["./hello-api"]
