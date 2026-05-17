# ============================================
# Build Stage
# ============================================
# 上限に引っかかったためパブリックに変更
FROM public.ecr.aws/docker/library/golang:1.21-alpine AS builder

WORKDIR /app

# Copy go.mod first for better layer caching
COPY go.mod ./

# Copy source code
COPY main.go ./

# Build the binary with optimizations
# CGO_ENABLED=0: Static binary (no C dependencies)
# -ldflags="-s -w": Strip debug info for smaller binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o omikuji-api main.go

# ============================================
# Production Stage
# ============================================
# 上限に引っかかったためパブリックに変更
FROM public.ecr.aws/docker/library/alpine:3.19

# Install stress-ng for /stress endpoint
RUN apk add --no-cache stress-ng

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/omikuji-api .

# Expose port 80
EXPOSE 80

# Start the application
CMD ["./omikuji-api"]
