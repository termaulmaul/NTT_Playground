# DBA Tools Docker Images

This directory contains multiple Dockerfile options for the DBA Tools container.

## Available Options

### 1. Dockerfile (Default) - Ubuntu 22.04
- **Base:** Ubuntu 22.04 LTS
- **Size:** ~1.5GB
- **Pros:** Most compatible, well-tested, extensive package repository
- **Cons:** Larger image size
- **Use when:** You need maximum compatibility and don't mind the size

### 2. Dockerfile.debian - Debian Bookworm Slim  
- **Base:** Debian 12 (Bookworm) Slim
- **Size:** ~1.2GB (20% smaller than Ubuntu)
- **Pros:** Smaller than Ubuntu, still very stable, good compatibility
- **Cons:** Slightly fewer packages than Ubuntu
- **Use when:** You want a balance between size and compatibility

### 3. Dockerfile.alpine - Alpine Linux (Experimental)
- **Base:** Alpine Linux with gcompat
- **Size:** ~800MB (50% smaller than Ubuntu)
- **Pros:** Very small, security-focused
- **Cons:** Uses musl libc (requires gcompat for Oracle), may have compatibility issues
- **Use when:** Size is critical and you're okay with potential issues

## Usage

### Using Default (Ubuntu)
```bash
docker-compose up -d
```

### Using Debian (Recommended for lighter setup)
```bash
# Temporarily rename files
cd dba-tools
mv Dockerfile Dockerfile.ubuntu
mv Dockerfile.debian Dockerfile
cd ..
docker-compose build dba-tools
docker-compose up -d
```

### Size Comparison

| Dockerfile | Base Image | Final Size | Savings |
|------------|-----------|------------|---------|
| Dockerfile (Ubuntu) | Ubuntu 22.04 | ~1.5GB | Baseline |
| Dockerfile.debian | Debian Slim | ~1.2GB | -20% |
| Dockerfile.alpine | Alpine | ~800MB | -50% |

## Recommendation

For **presentation and learning purposes**, stick with the default **Ubuntu** or **Debian** versions:
- More reliable
- Better Oracle support
- Easier troubleshooting
- All required tools work out of the box

Only consider **Alpine** if:
- You have strict disk space constraints
- You're comfortable with debugging compatibility issues
- You've tested thoroughly before presentation