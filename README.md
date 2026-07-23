# Ada Fuzzing Pipeline

[![Fuzzing](https://github.com/madcap-syd/ada-fuzz-lab/actions/workflows/fuzz.yml/badge.svg)](https://github.com/madcap-syd/ada-fuzz-lab/actions/workflows/fuzz.yml)

CI/CD pipeline for fuzzing Ada code using AFL++ in Docker and GitHub Actions.

## Quick Start

bash
make clean && make
./fuzz_target testcases/valid_seed.txt

## Structure
- `.github/workflows/fuzz.yml` - GitHub Actions pipeline
- `src/` - Ada source code with intentional vulnerability
- `harness.c` - C wrapper for AFL++
- `Makefile` - Build script

**Expected Result:** `CRASH DETECTED! Signal: 6 (SIGABRT)`

**Author:** madcap-syd


