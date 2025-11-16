/*
* This file is part of the BSGS distribution (https://github.com/JeanLucPons/Kangaroo).
* Copyright (c) 2020 Jean Luc PONS.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, version 3.
*
* This program is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef CONSTANTSH
#define CONSTANTSH

// Release number
#define RELEASE "2.3"

// Use symmetry
//#define USE_SYMMETRY

// Number of random jumps
// Max 512 for the GPU
#define NB_JUMP 32

// GPU group size
#define GPU_GRP_SIZE 128

// GPU number of run per kernel call
#define NB_RUN 64

// Kangaroo type
#define TAME 0  // Tame kangaroo
#define WILD 1  // Wild kangaroo

// SendDP Period in sec
#define SEND_PERIOD 2.0

// Maximum DPs buffered per GPU before dropping (adjust based on -d and GPU speed)
// Default: 256K DPs ≈ 20MB RAM per GPU
// With -d 11, RTX 4090 generates ~130K DPs per 2 seconds, so 256K provides 2x headroom
#define MAX_DP_BUFFER 262144

// Timeout before closing connection idle client in sec
#define CLIENT_TIMEOUT 3600.0

// Number of merge partition
#define MERGE_PART 256

#endif //CONSTANTSH
