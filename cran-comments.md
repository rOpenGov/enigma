R CMD CHECK passed on my local OS X install with R 3.1.2 and R development version, Ubuntu running on Travis-CI, and Win builder.

This version now includes packages in Suggests field in the DESCRIPTION file
that are mentioned in examples. 

In addition, all examples are in \dontrun instead of \donttest given the upcoming change of running examples in \donttest on R CMD CHECk. This is needed because requests to the Enigma API require an API key, so examples
won't run if a key is not provided. 

Thanks! Scott Chamberlain
