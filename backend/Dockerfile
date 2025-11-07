FROM golang:1.18-alpine as build

WORKDIR /app

# Copy the Go module files
COPY go.mod .
COPY go.sum .

# Download the Go module dependencies
RUN go mod download

COPY . .


# Build statically linked binary
RUN  go build  -o /goapp .


FROM alpine:latest as run

# Copy the application executable from the build image
COPY --from=build /goapp /goapp
RUN chgrp 0 /goapp && \
    chmod g+x /goapp

# Run as non-root user
USER 1001

EXPOSE 8000
CMD ["/goapp"]
