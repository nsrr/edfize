## 0.1.0
- Initial EDF class to load headers and signals into Ruby objects
- `edfize` command has the following actions:
  - `check`: Validates EDFs in the current directory for errors
  - `test`: Same as `check`
  - `run`: Prints out the headers of all edfs in the current directory
  - `help`: Displays information about `edfize` along with all available commands
  - `version`: Displays the current `edfize` version
- `edfize test` checks for the following:
  - Expected Length Check: The expected total size is computed from the (`number
    of data records` * `total samples across all signals`) + `size of header` and
    this is compared to the actual file size.
