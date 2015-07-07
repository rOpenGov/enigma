enigma 0.2.0
===============

### NEW FEATURES

* New parameter `conjunction` added to `enigma_data()`,
`enigma_stats()`, and `enigma_fetch()` (#16)
* New parameters added to `enigma_fetch()`: `select`, `search`,
`where`, `conjunction`, and `sort` (#18)
* Added a print method for output of `enigma_data()` to provide more
brief output (#17)

### MINOR IMPROVEMENTS

* Using skip on cran now for tests (#14)
* Importing all non-base R functions now, including from `methods`, 
and `utils` pacakges (#15)

### BUG FIXES

* Fixed issues related to `httr` `v1` where can no longer pass empty 
list to `query` parameter (#13)

enigma 0.1.1
===============

### MINOR IMPROVEMENTS

* Libraries use in examples now in Suggests in DESCRIPTION file. (#12)
* Fixed a bug in a helper function to check for Api keys. (#9)
* Added URL and BugReports fields to DESCRIPTION file. (#11)


enigma 0.1.0
===============

### NEW FEATURES

* released to CRAN
