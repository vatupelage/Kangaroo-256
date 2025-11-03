#!/bin/bash
# CUDA Compute Capability Detection Script
# Attempts to auto-detect the GPU compute capability for optimal builds

ccap=""
cd deviceQuery 2>/dev/null || {
    echo "Warning: deviceQuery directory not found, skipping auto-detection"
    exit 1
}

echo "Attempting to autodetect CUDA compute capability..."

# Try to build and run deviceQuery
if make >cuda_build_log.txt 2>&1; then
    # Successfully built, now try to run it
    if [ -x "./deviceQuery" ]; then
        ccap=$(./deviceQuery 2>/dev/null | grep "CUDA Capability" | awk -F '    ' '{print $2}' | sort -n | head -n 1 | sed 's/\.//')
    fi
fi

# Check if detection succeeded
if [ -n "${ccap}" ] && [ "${ccap}" != "" ]; then
    echo "Successfully detected compute capability: ${ccap}"

    # Map known architectures for informational purposes
    case "${ccap}" in
        "60"|"61"|"62") echo "  Architecture: Pascal (GTX 10xx, Tesla P100)" ;;
        "70"|"72") echo "  Architecture: Volta (Tesla V100, AGX Xavier)" ;;
        "75") echo "  Architecture: Turing (RTX 20xx, GTX 16xx)" ;;
        "80") echo "  Architecture: Ampere (A100 data center)" ;;
        "86") echo "  Architecture: Ampere (RTX 30xx)" ;;
        "87") echo "  Architecture: Ampere (Jetson AGX Orin)" ;;
        "89") echo "  Architecture: Ada Lovelace (RTX 40xx/50xx)" ;;
        "90") echo "  Architecture: Hopper (H100/H200)" ;;
        *) echo "  Architecture: Unknown (ccap=${ccap})" ;;
    esac
else
    echo "Auto-detection failed!"
    echo "This could be due to:"
    echo "  - No CUDA-capable GPU detected"
    echo "  - CUDA driver not installed or not working"
    echo "  - deviceQuery compilation failed"
    echo ""
    echo "Building for multiple architectures instead (slower compile, broader compatibility)"
    cd ..
    exit 1
fi

cd ..
echo ${ccap} > cuda_version.txt
exit 0
