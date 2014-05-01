## 0.1.0
- Initial EDF class to load headers and signals into Ruby objects
- `edfize` command has the following actions:
  - `test`: Validates EDFs in the current directory for errors
    - To only show failing tests, add the flag `--failing`
      - `edfize test --failing`
    - To suppress descriptive test failures, add the flag `--quiet`
      - `edfize test --quiet`
    - Both flags can be used together
      - `edfize test --failing --quiet`
  - `check`: Same as `test`
  - `run`: Prints out the headers of all edfs in the current directory
  - `help`: Displays information about `edfize` along with all available commands
  - `version`: Displays the current `edfize` version
- `edfize test` checks for the following:
  - Expected Length Check: The expected total size is computed from the (`number
    of data records` * `total samples across all signals`) + `size of header` and
    this is compared to the actual file size.
  - Reserved Area Checks: The header and the individual header reserved areas are
    checked to validate that they are blank. Non-blank areas are a sign that the
    edf header is corrupt and that data from the signal data block have leaked into
    the header itself.
