## 0.4.0

### Enhancements
- **Scripting Changes**
  - Edfize now provides an enumerator to iterate through a folder of EDFs:
    - `Edfize.edfs` # Current directory and subdirectories
    - `Edfize.edfs(recursive: false)` # Only current directory
  - Deprecated `edfs_in_current_directory_and_subdirectories` in favor of
    `edf_paths`
    - Note that while `edf_paths` is a direct replacement for
      `edfs_in_current_directory_and_subdirectories`, it is recommended to use
      the new `edfs` enumerator instead
  - Added `Edf::update` method that allows portions of the header to be updated
    - Change an EDF's start_date_of_recording to the clipping date, 1 Jan 1985
    - `edf.update(start_date_of_recording: '01.01.85')`
    - Change an EDF's start_time_of_recording to midnight
    - `edf.update(start_time_of_recording: '00.00.00')`
- **Test Changes**
  - Removed `reserved_signal_areas_blank` check as it was flagging too many
    false positives

## 0.3.0 (December 7, 2016)

### Enhancements
- **Test Changes**
  - Added a test to make sure date in EDF and EDF+ formats are valid
    - The EDF header date is checked in the following manner: (a) Is the EDF+
      header (29-FEB-2100) a valid date, if (yes) check that the EDF header date
      (29.02.00) matches the EDF+ date, if (no) check that the EDF header date
      (29.02.00) is a valid date. The EDF+ header date is checked first since
      (29-FEB-2100) is NOT a valid date as leap years only occur in a century
      years divisible by 400, while the truncated EDF date would be (02.29.00)
      which would be incorrectly seen as valid since 2000 is a leap year.
- **Gem Changes**
  - Updated to Ruby 2.3.3
  - Updated to colorize 0.8.1
  - Updated simplecov to 0.11.2
  - Removed minitest-reporters
  - Updated to simplecov 0.12.0
  - Updated to bundler 1.13

### Bug Fix
- Fixed an issue where EDFs using `.EDF` instead of `.edf` weren't being tested
  by `edfize t`

## 0.2.0 (March 12, 2015)

### Enhancements
- EDFs can now be partially loaded by specifying the epoch number and epoch size
  in seconds
- Use of Ruby 2.2.1 is now recommended

### Testing
- Updated to minitest test framework along with simplecov for coverage

## 0.1.0 (May 28, 2014)
- Initial EDF class to load headers and signals into Ruby objects
- `edfize` command has the following actions:
  - `test`: Validates EDFs in the current directory and subdirectories for
    errors
    - To only show failing tests, add the flag `--failing`
      - `edfize test --failing`
    - To suppress descriptive test failures, add the flag `--quiet`
      - `edfize test --quiet`
    - Both flags can be used together
      - `edfize test --failing --quiet`
  - `run`: Prints out the headers of all EDFs in the current directory and
    subdirectories
  - `help`: Displays information about `edfize` along with all available
    commands
  - `version`: Displays the current `edfize` version
- `edfize test` checks for the following:
  - Expected Length Check: The expected total size is computed from the (`number
    of data records` * `total samples across all signals`) + `size of header`
    and this is compared to the actual file size.
  - Reserved Area Checks: The header and the individual header reserved areas
    are checked to validate that they are blank. Non-blank areas are a sign that
    the EDF header is corrupt and that data from the signal data block have
    leaked into the header itself.
