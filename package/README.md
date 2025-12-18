# Delve Debugger Docker Package

This directory contains the Docker image configuration for the delve-debugger tool.

## Files

- **Dockerfile**: Multi-stage Docker build configuration for the delve-debugger image
- **entrypoint.sh**: Container entrypoint script that attaches Delve to a running process
- **VERSIONS.md**: Version tracking and update policy documentation
- **test-dockerfile.sh**: Validation script to test Dockerfile syntax and versions

## Building the Image

### Using Make (Recommended)

From the repository root:
```bash
make build
```

This will:
1. Extract version numbers from the Dockerfile
2. Build the image with appropriate tags
3. Tag as: `ghcr.io/moio/delve-debugger:${DLV_VERSION}-${DELVE_DEBUGGER_VERSION}`

### Manual Build

```bash
cd package/
docker build -t delve-debugger:latest .
```

### With Specific Versions

```bash
docker build \
  --build-arg GO_VERSION=1.25 \
  --build-arg DLV_VERSION=1.25.2 \
  --build-arg DELVE_DEBUGGER_VERSION=1 \
  -t delve-debugger:1.25.2-1 \
  .
```

## Testing

Run the validation script to test the Dockerfile:

```bash
./test-dockerfile.sh
```

This will:
- Extract and display current version numbers
- Attempt to build the Docker image (if network access available)
- Verify Delve version in the built image
- Fall back to basic syntax validation if build fails

### Expected Output

When network access is available:
```
=== Delve Debugger Dockerfile Test ===

Extracting versions from Dockerfile...
  GO_VERSION: 1.25
  DLV_VERSION: 1.25.2
  DELVE_DEBUGGER_VERSION: 1

Attempting Docker build...
✓ Dockerfile built successfully
✓ Delve version matches expected: 1.25.2

=== All tests passed! ===
```

When network access is restricted:
```
=== Basic validation passed! ===

Note: Full Docker build test requires network access to SUSE registry.
```

## Version Updates

When updating versions:

1. Research latest stable versions:
   - Go: Check SUSE package repositories
   - Delve: Check https://github.com/go-delve/delve/releases
   - Base image: Check SUSE Linux Enterprise release notes

2. Update `Dockerfile`:
   - Modify `ARG GO_VERSION=X.XX`
   - Modify `ARG DLV_VERSION=X.XX.X`
   - Increment `ARG DELVE_DEBUGGER_VERSION=X`
   - Update comments with verification date

3. Update `VERSIONS.md`:
   - Update version numbers
   - Update "Last Updated" date
   - Add any relevant notes

4. Test the build:
   ```bash
   ./test-dockerfile.sh
   make build
   ```

5. Commit changes:
   ```bash
   git add Dockerfile VERSIONS.md
   git commit -m "Bump versions to Go X.XX and Delve X.XX.X"
   ```

## Current Versions (Dec 2025)

- **Base Image**: SUSE Linux Enterprise 15 SP7 (registry.suse.com/suse/sle15:15.7)
- **Go**: 1.25 (SUSE package, corresponds to Go 1.25.x)
- **Delve**: 1.25.2 (latest stable release)
- **Internal Version**: 1

See [VERSIONS.md](VERSIONS.md) for detailed version information.

## Requirements

- Docker or compatible container runtime
- Network access to SUSE Container Registry (registry.suse.com)
- For testing: Bash shell

## Troubleshooting

### Build fails with registry access error

```
ERROR: failed to authorize: failed to fetch anonymous token
```

**Solution**: This is a network connectivity issue. Ensure you have:
- Internet access
- Access to registry.suse.com
- No firewall blocking the connection

### Go package not found

```
ERROR: Package 'goX.XX' not found
```

**Solution**: The specified Go version may not be available in SUSE repositories. Check:
- Available versions: `docker run --rm registry.suse.com/suse/sle15:15.7 zypper search go`
- Update `GO_VERSION` in Dockerfile to an available version

### Delve installation fails

```
go: downloading github.com/go-delve/delve vX.XX.X failed
```

**Solution**: 
- Verify the Delve version exists at https://github.com/go-delve/delve/releases
- Check network connectivity
- Try a different version

## Links

- [Delve GitHub Repository](https://github.com/go-delve/delve)
- [SUSE Container Registry](https://registry.suse.com)
- [Go Releases](https://go.dev/dl/)
- [Repository Root README](../README.md)
