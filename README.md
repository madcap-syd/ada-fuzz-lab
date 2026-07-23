# Ada Fuzzing Pipeline

[![fuzzing](https://github.com/madcap-syd/ada-fuzz-lab/actions/workflows/fuzz.yml/badge.svg)](https://github.com/madcap-syd/ada-fuzz-lab/actions/workflows/fuzz.yml)

**Universal CI/CD pipeline for fuzzing Ada code using AFL++ and GitHub Actions.**

## Features

✅ **Automatic harness generation** - scans `src/*.ads` и генерирует harness автоматически  
✅ **5 vulnerability modules** - Integer Overflow, Null Pointer, Use-After-Free, Division by Zero, Out-of-Bounds  
✅ **Email notifications** - уведомления при обнаружении крашей  
✅ **Artifact upload** - crash файлы сохраняются в GitHub Actions  
✅ **Cleanup script** - автоматическая очистка старых failed jobs  

## Quick Start

### Local testing
```bash
# Generate harness automatically
python3 scripts/generate_harness.py

# Build
make clean && make

# Test with seed
./fuzz_target testcases/parse_from_c_seed.bin

# Run AFL++
afl-fuzz -i testcases/ -o findings/ -- ./fuzz_target @@

GitHub Actions
Просто запушь изменения в src/ - pipeline автоматически:

    Сгенерирует harness
    Скомпилирует все модули
    Запустит AFL++ на 120 секунд
    Загрузит артефакты при обнаружении крашей
    Отправит email уведомление

Vulnerability Library
1. vulnerable_parser - Out-of-Bounds Read

procedure Parse_From_C (
   Data : in System.Address;
   Len  : in Interfaces.C.size_t
);
pragma Export (C, Parse_From_C, "parse_from_c");
Trigger: Input containing 'X' character

2. integer_overflow - Integer Overflow

procedure Process_Buffer (
   Data : in System.Address;
   Len  : in Interfaces.C.size_t
);
pragma Export (C, Process_Buffer, "process_buffer");
Trigger: Sum of bytes > 255

3. null_pointer - Null Pointer Dereference

procedure Process_Data (
   Data : in System.Address;
   Len  : in Interfaces.C.size_t
);
pragma Export (C, Process_Data, "process_data");
Trigger: First byte = 0xFF

4. use_after_free - Use-After-Free

procedure Process_Memory (
   Data : in System.Address;
   Len  : in Interfaces.C.size_t
);
pragma Export (C, Process_Memory, "process_memory");
Trigger: First byte = 0xDE

5. division_by_zero - Division by Zero

procedure Calculate (
   Data : in System.Address;
   Len  : in Interfaces.C.size_t
);
pragma Export (C, Calculate, "calculate");
Trigger: First byte = 0x01 (1-1=0)

Project Structure

ada-fuzz-lab/
├── .github/workflows/
│   └── fuzz.yml              # GitHub Actions pipeline
├── scripts/
│   ├── generate_harness.py   # Auto-generate harness
│   └── cleanup_failed_runs.py # Cleanup old failed jobs
├── src/
│   ├── vulnerable_parser.*   # Out-of-Bounds Read
│   ├── integer_overflow.*    # Integer Overflow
│   ├── null_pointer.*        # Null Pointer Dereference
│   ├── use_after_free.*      # Use-After-Free
│   ── division_by_zero.*    # Division by Zero
├── harness.c                 # C wrapper (auto-generated)
├── Makefile                  # Build script (auto-generated)
├── testcases/                # Seed files (auto-generated)
── README.md


Scripts

generate_harness.py

python3 scripts/generate_harness.py

Автоматически сканирует src/*.ads, находит pragma Export (C, ...) и генерирует:

    harness.c - C wrapper для AFL++
    Makefile - скрипт сборки
    testcases/*.bin - seed файлы для каждой функции

cleanup_failed_runs.py

# Dry run (preview)
python3 scripts/cleanup_failed_runs.py --dry-run

# Delete failed runs older than 7 days
python3 scripts/cleanup_failed_runs.py --status failed --days 7

# Delete ALL failed runs
python3 scripts/cleanup_failed_runs.py --status failed --days 0 --force

Email Notifications
Pipeline отправляет email при обнаружении крашей.
Setup

    GitHub Settings → Notifications → Enable "Send notifications for workflow failures"
    Custom email (опционально):
        Add secrets: EMAIL_USERNAME, EMAIL_PASSWORD, EMAIL_TO
        Use Gmail App Password для EMAIL_PASSWORD

Expected Result

🚨 CRASH DETECTED! AFL++ found a vulnerability.
Signal: 6 (SIGABRT)
Executions: 100-1000
Time: < 2 seconds

Workflow

graph LR
    A[Push to src/] --> B[GitHub Actions]
    B --> C[Generate Harness]
    C --> D[Build with GNAT]
    D --> E[Run AFL++]
    E --> F{Crash?}
    F -->|Yes| G[Upload Artifacts]
    F -->|Yes| H[Send Email]
    F -->|No| I[Success]

Requirements

    GNAT 13+ (Ada compiler)
    AFL++ (fuzzer)
    Python 3.8+ (for harness generator)
    GitHub Actions (CI/CD)

Author
madcap-syd
License
MIT License - feel free to use for learning and testing!
Acknowledgments

    AFL++ by Michal Zalewski et al.
    GNAT by AdaCore
    GitHub Actions







