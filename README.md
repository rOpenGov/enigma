enigma
=======

[![Build Status](https://api.travis-ci.org/rOpenGov/enigma.png)](https://travis-ci.org/rOpenGov/enigma)

**An R client for [Enigma.io](https://app.enigma.io/)**

### enigma info

+ [enigma home page](https://app.enigma.io/)
+ [API docs](https://app.enigma.io/api)

### Quick start

#### Install

```coffee
install.packages("devtools")
library("devtools")
install_github("ropengov/enigma")
library("enigma")
```

#### Get data

```coffee
out <- enigma_data(dataset='us.gov.whitehouse.visitor-list', select=c('namelast','visitee_namelast','last_updatedby'))
out$success
```

Was call successful

```coffee
[1] TRUE
```

Some metadata on the results

```coffee
out$meta
```

```coffee
rows_limit total_results   total_pages  current_page 
       50       3577135         71543             1 
```

Look at the data, first 6 rows for readme brevity

```coffee
head(out$data)
```

```coffee
  namelast visitee_namelast last_updatedby
1   BELBAS           OFFICE             T1
2     BOUL            POTUS             J7
3   VITALE             TING             GB
4   VITALE             TING             GB
5   VITALE             TING             GB
6   VITALE             TING             GB
```

#### Statistics on dataset columns

```coffee
out <- enigma_stats(dataset='us.gov.whitehouse.visitor-list', select='total_people')
```

Some summary stats

```coffee
out$sum_stats
```

```coffee
$sum
[1] "1028567261"

$avg
[1] "289.0040005540871372"

$stddev
[1] "520.769872911814"

$variance
[1] "271201.260532586939"

$max
[1] "5730"

$min
[1] "0"
```

Frequency details

```coffee
head(out$frequency)
```

```coffee
  total_people  count
1            1 158256
2            2  98349
3            6  96922
4            3  79896
5            4  79100
6            5  67575
```


#### Metadata on datasets

```coffee
out <- enigma_metadata(dataset='us.gov.whitehouse')
```

Paths 

```coffee
out$meta$paths
```

```coffee
[[1]]
[[1]]$level
[1] "us"

[[1]]$label
[1] "United States"

[[1]]$description
[1] "United States"


[[2]]
[[2]]$level
[1] "gov"

[[2]]$label
[1] "U.S. Federal Government"

[[2]]$description
[1] "Government comprising the Legislative, Executive, and Judicial branches of the United States of America."


[[3]]
[[3]]$level
[1] "whitehouse"

[[3]]$label
[1] "The White House"

[[3]]$description
[1] "Located at 1600 Pennsylvania Avenue in Washington D.C., the White House has served as the home and office for every U.S. president since John Adams."
```

Immediate nodes

```coffee
out$meta$immediate_nodes
```

```coffee
[[1]]
[[1]]$datapath
[1] "us.gov.whitehouse.salaries"

[[1]]$label
[1] "White House Salaries"

[[1]]$description
[1] "The White House report to Congress listing the title and salary of every White House Office employee since 1995."
```

Children tables

```coffee
out$meta$children_tables
```

```coffee
[[1]]
[[1]]$datapath
[1] "us.gov.whitehouse.nom-and-app"

[[1]]$label
[1] "Nominations & Appointments"

[[1]]$description
[1] "The nominees and appointees names, positions, agencies under which they are nominated or appointed, the agency's websites, nomination dates, and vote confirmation dates."

[[1]]$db_boundary_datapath
[1] "us.gov.whitehouse"

[[1]]$db_boundary_label
[1] "The White House"
```