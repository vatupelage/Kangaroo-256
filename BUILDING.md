# Building Kangaroo-256 - Complete Guide

This guide provides comprehensive instructions for building Kangaroo-256 on various systems.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Build Options](#build-options)
4. [Platform-Specific Instructions](#platform-specific-instructions)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Configuration](#advanced-configuration)
7. [Verification](#verification)

---

## Quick Start

**For most users with modern GPUs:**

```bash
cd Kangaroo-256
make gpu=1 all
./kangaroo-256 -l  # Test GPU detection
```

That's it! The build system will auto-detect your GPU and build an optimized binary.

---

## Prerequisites

### Required Software

#### 1. C++ Compiler (GCC 7.3+)

```bash
# Check version
g++ --version

# Ubuntu/Debian - install if needed
sudo apt update
sudo apt install build-essential g++

# RHEL/CentOS/Fedora
sudo dnf install gcc-c++

# Should show version 7.3 or higher (11+ recommended)
```

#### 2. CUDA Toolkit (10.2+, 12.x recommended)

**Check if already installed:**
```bash
nvcc --version
```

**Install CUDA 12.x (Ubuntu/Debian):**
```bash
# Add NVIDIA package repository
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# Install CUDA toolkit
sudo apt-get install cuda-toolkit-12-4

# Add to PATH and LD_LIBRARY_PATH
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Verify installation
nvcc --version
```

**Install CUDA (RHEL/CentOS/Fedora):**
```bash
# Add repository
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo

# Install
sudo dnf install cuda-toolkit-12-4

# Add to PATH
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

**Other CUDA versions:**
- https://developer.nvidia.com/cuda-downloads

#### 3. NVIDIA Driver

```bash
# Check current driver
nvidia-smi

# Ubuntu/Debian - install if needed
sudo apt update
sudo apt install nvidia-driver-535  # Or newer

# RHEL/CentOS/Fedora
sudo dnf install akmod-nvidia
sudo akmods --force

# Reboot after driver installation
sudo reboot
```

**Minimum driver versions:**
- For RTX 40xx: 525.x+
- For RTX 30xx: 450.x+
- Recommended: 535.x or newer

#### 4. Make

```bash
# Check
make --version

# Install if needed (Ubuntu/Debian)
sudo apt install make

# Install if needed (RHEL/CentOS/Fedora)
sudo dnf install make
```

### Hardware Requirements

- **CPU:** Any x86_64 with SSSE3 (any modern CPU since 2006)
- **GPU:** NVIDIA GPU with compute capability 3.5+ (GTX 700 series or newer)
- **RAM:** 4+ GB recommended (depends on search range)
- **Disk:** ~500 MB for build artifacts

---

## Build Options

### Option 1: Auto-Detect GPU (Recommended)

Automatically detects your GPU and builds optimized binary.

```bash
make gpu=1 all
```

**What happens:**
1. Runs `detect_cuda.sh` to identify GPU compute capability
2. Builds for detected architecture
3. Falls back to multi-arch build if detection fails

**Output example:**
```
Attempting to autodetect CUDA compute capability...
Successfully detected compute capability: 89
  Architecture: Ada Lovelace (RTX 40xx/50xx)
Making Kangaroo-256...
```

### Option 2: Manual Compute Capability

Specify exact compute capability if auto-detect fails or for optimization.

```bash
make gpu=1 ccap=89 all  # For RTX 4090/5090
```

**Common compute capabilities:**
- `60` - GTX 10xx (Pascal)
- `61` - GTX 1080 Ti (Pascal)
- `70` - Tesla V100 (Volta)
- `75` - RTX 20xx (Turing)
- `80` - A100 (Ampere)
- `86` - RTX 30xx (Ampere)
- `89` - RTX 40xx/50xx (Ada Lovelace) ← **Most common**
- `90` - H100 (Hopper)

**Find your GPU's compute capability:**
```bash
nvidia-smi --query-gpu=name,compute_cap --format=csv
```

### Option 3: Multi-Architecture Build (Universal Binary)

Builds for multiple architectures in one binary (larger file, broader compatibility).

```bash
make gpu=1 all  # Without ccap parameter
```

**Includes support for:**
- SM 60, 61 (Pascal)
- SM 70 (Volta)
- SM 75 (Turing)
- SM 80, 86 (Ampere)
- SM 89 (Ada Lovelace)
- SM 90 (Hopper)

**Trade-offs:**
- ✅ Works on any modern GPU without rebuild
- ✅ Forward compatible via JIT PTX compilation
- ❌ Larger binary (~15-20 MB vs ~3-5 MB)
- ❌ Slower compilation (~10-20 min vs ~2-5 min)

**Best for:** Distribution, testing, or if you use multiple GPUs

### Option 4: CPU-Only Build

Build without GPU support (not recommended for serious use).

```bash
make all  # No gpu=1 flag
```

**Performance:** ~10-100× slower than GPU version

### Option 5: Debug Build

Build with debugging symbols for development.

```bash
make gpu=1 debug=1 all
```

**Features:**
- Debug symbols for GDB
- CUDA kernel debugging enabled
- No optimization (-O0)
- Significantly slower performance

---

## Platform-Specific Instructions

### Ubuntu 22.04 / 24.04 LTS

```bash
# Install dependencies
sudo apt update
sudo apt install build-essential g++ make nvidia-driver-535 cuda-toolkit-12-4

# Reboot after driver/CUDA install
sudo reboot

# Clone or navigate to Kangaroo-256
cd Kangaroo-256

# Build
make gpu=1 all

# Test
./kangaroo-256 -l
```

### Ubuntu 20.04 LTS

```bash
# Install GCC 11 (20.04 has GCC 9 by default)
sudo apt update
sudo apt install gcc-11 g++-11
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

# Install CUDA
sudo apt install nvidia-driver-535 cuda-toolkit-11-8

# Build
make gpu=1 all
```

### Debian 11/12

```bash
# Enable contrib and non-free repositories
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository non-free
sudo apt update

# Install dependencies
sudo apt install build-essential g++ make nvidia-driver cuda-toolkit

# Build
make gpu=1 all
```

### RHEL 9 / CentOS Stream 9 / Rocky Linux 9

```bash
# Install EPEL
sudo dnf install epel-release

# Install development tools
sudo dnf groupinstall "Development Tools"
sudo dnf install gcc-c++ make

# Install CUDA (RHEL 9)
sudo dnf config-manager --add-repo \
  https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
sudo dnf clean all
sudo dnf install cuda-toolkit-12-4

# Install NVIDIA driver
sudo dnf install akmod-nvidia
sudo akmods --force
sudo reboot

# Build
make gpu=1 all
```

### Fedora 38/39/40

```bash
# Install development tools
sudo dnf groupinstall "Development Tools"
sudo dnf install gcc-c++ make

# Install RPM Fusion for NVIDIA drivers
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install NVIDIA driver
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo akmods --force
sudo reboot

# Install CUDA
sudo dnf install cuda-toolkit-12-4

# Build
make gpu=1 all
```

### Arch Linux / Manjaro

```bash
# Install dependencies
sudo pacman -S base-devel gcc make cuda nvidia-utils

# Build
make gpu=1 all
```

### Windows (WSL2)

**Recommended approach:** Use WSL2 with Ubuntu

```powershell
# In PowerShell (as Administrator)
# 1. Enable WSL2
wsl --install

# 2. Install Ubuntu from Microsoft Store

# 3. In WSL2 Ubuntu terminal:
# Follow Ubuntu 22.04 instructions above

# 4. Install NVIDIA CUDA on WSL
# Download from: https://developer.nvidia.com/cuda/wsl
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install cuda-toolkit-12-4

# Build
make gpu=1 all
```

**Requirements:**
- Windows 11 or Windows 10 version 21H2+
- NVIDIA driver for Windows (525.x+)
- WSL2 enabled

---

## Troubleshooting

### Issue: "nvcc: command not found"

**Problem:** CUDA toolkit not in PATH

**Solution:**
```bash
# Find nvcc
which nvcc
ls /usr/local/cuda*/bin/nvcc

# Add to PATH
export CUDA=/usr/local/cuda-12.4  # Adjust version
export PATH=$CUDA/bin:$PATH
export LD_LIBRARY_PATH=$CUDA/lib64:$LD_LIBRARY_PATH

# Make permanent
echo "export PATH=/usr/local/cuda/bin:\$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc

# Rebuild
make clean && make gpu=1 all
```

### Issue: "unsupported GNU version" or "gcc version ... is unsupported"

**Problem:** GCC too new for CUDA version

**Solution:**
```bash
# Check compatible versions
# CUDA 11.x: GCC 11 max
# CUDA 12.x: GCC 12 max

# Install older GCC
sudo apt install g++-10  # Ubuntu
sudo dnf install gcc-toolset-10  # RHEL

# Build with specific GCC
make gpu=1 CXXCUDA=/usr/bin/g++-10 all
```

### Issue: "No GPU detected" or deviceQuery fails

**Solution 1: Check driver**
```bash
nvidia-smi
# If this fails, driver issue

# Reinstall driver
sudo apt remove --purge nvidia-*  # Ubuntu
sudo apt install nvidia-driver-535
sudo reboot
```

**Solution 2: Try manual ccap**
```bash
# Check GPU model
lspci | grep -i nvidia

# Look up compute capability online:
# https://developer.nvidia.com/cuda-gpus

# Build with manual ccap
make gpu=1 ccap=89 clean all
```

**Solution 3: Multi-arch build**
```bash
# If detection fails, build for all architectures
make gpu=1 all  # No ccap specified
```

### Issue: "cudaGetDeviceCount: no CUDA-capable device is detected"

**Solution:**
```bash
# Check if driver sees GPU
nvidia-smi

# Check CUDA library path
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Try running with explicit path
LD_LIBRARY_PATH=/usr/local/cuda/lib64 ./kangaroo-256 -l
```

### Issue: Compilation extremely slow

**Cause:** Multi-architecture build compiles for many GPUs

**Solution:**
```bash
# Use single-architecture for faster builds
make gpu=1 ccap=89 all  # ~2-5 minutes

# Multi-arch build takes 10-20 minutes (normal)
```

### Issue: "cannot find -lcudart"

**Problem:** CUDA library not found

**Solution:**
```bash
# Check CUDA installation
ls /usr/local/cuda/lib64/libcudart.so

# Fix library path
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Update Makefile if needed
# Edit line with LFLAGS to match your CUDA path
```

### Issue: Runtime error "libcudart.so.12: cannot open shared object file"

**Problem:** CUDA runtime library not in library path

**Solution:**
```bash
# Temporary fix
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
./kangaroo-256 -l

# Permanent fix
sudo sh -c 'echo "/usr/local/cuda/lib64" > /etc/ld.so.conf.d/cuda.conf'
sudo ldconfig

# Or add to bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## Advanced Configuration

### Custom CUDA Path

```bash
make gpu=1 CUDA=/opt/cuda-12.2 all
```

### Custom Compiler

```bash
make gpu=1 CXX=/usr/bin/g++-11 CXXCUDA=/usr/bin/g++-10 all
```

### Custom Architecture List

Edit `Makefile` line 111-119 to add/remove architectures:

```makefile
GENCODE_FLAGS = -gencode=arch=compute_75,code=sm_75 \
                -gencode=arch=compute_89,code=sm_89 \
                # Add your specific architectures here
```

### Optimization Flags

The Makefile uses `-O3` by default. For experiments:

```bash
# Maximum optimization
make gpu=1 CXXFLAGS="-O3 -march=native -flto" all

# Debug with minimal optimization
make gpu=1 debug=1 all
```

### Cross-Compilation

Not officially supported, but possible with:
```bash
make gpu=1 CXX=aarch64-linux-gnu-g++ all  # For ARM64
# Requires ARM64 CUDA toolkit
```

---

## Verification

### After Build

```bash
# Check binary was created
ls -lh kangaroo-256
# Should see ~3-20 MB file depending on build type

# Test version
./kangaroo-256 -v
# Output: Kangaroo v2.1 (or similar)

# List GPUs
./kangaroo-256 -l
# Should show your GPU with correct core count

# Example output:
# GPU #0: NVIDIA GeForce RTX 4090 (128x128 cores)
```

### Smoke Test

```bash
# Create simple test input
cat > test_simple.txt <<EOF
0
FFFFFFFFFFFF
02E9F43F810784FF1E91D8BC7C4FF06BFEE935DA71D7350734C3472FE305FEF82A
EOF

# Run quick test (should find key quickly)
./kangaroo-256 -t 4 -gpu test_simple.txt

# Expected output includes:
# Key# 0 Pub: 0x02E9F43F...
#      Priv: 0x378ABDEC51BC5D
```

### Performance Test

```bash
# Run on 64-bit puzzle for 60 seconds
timeout 60 ./kangaroo-256 -t 0 -gpu VC_CUDA8/in64.txt

# Check metrics in output:
# [XX.XX MKey/s][GPU XX.XX MKey/s]...
# Should be >50 MK/s on modern GPU
```

---

## Installation

### Option 1: Use in Place
```bash
cd Kangaroo-256
./kangaroo-256 <options>
```

### Option 2: System-Wide Install
```bash
sudo cp kangaroo-256 /usr/local/bin/
kangaroo-256 -v  # Available globally
```

### Option 3: User Install
```bash
mkdir -p ~/bin
cp kangaroo-256 ~/bin/
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
kangaroo-256 -v
```

---

## Clean Build

```bash
# Remove all build artifacts
make clean

# Rebuild from scratch
make gpu=1 all
```

---

## Build Flags Reference

| Flag | Purpose | Example |
|------|---------|---------|
| `gpu=1` | Enable GPU support | `make gpu=1 all` |
| `ccap=XX` | Set compute capability | `make gpu=1 ccap=89 all` |
| `debug=1` | Debug build | `make gpu=1 debug=1 all` |
| `CUDA=/path` | Custom CUDA path | `make CUDA=/opt/cuda gpu=1 all` |
| `CXX=/path/g++` | Custom C++ compiler | `make CXX=/usr/bin/g++-11 gpu=1 all` |
| `CXXCUDA=/path/g++` | Custom CUDA compiler | `make CXXCUDA=/usr/bin/g++-10 gpu=1 all` |

---

## Getting Help

If you encounter issues not covered here:

1. Check `MODERNIZATION_REPORT.md` for detailed technical information
2. Check `GPU_COMPATIBILITY.md` for GPU-specific issues
3. Check `CHANGELOG.md` for recent changes
4. Verify your setup meets all prerequisites
5. Try a clean build: `make clean && make gpu=1 all`

---

**Last Updated:** November 3, 2025
**Maintained by:** Kangaroo-256 Modernization Project
