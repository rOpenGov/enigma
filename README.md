enigma
=======

[![Build Status](https://api.travis-ci.org/rOpenGov/enigma.png)](https://travis-ci.org/rOpenGov/enigma)

**An R client for [Enigma.io](https://app.enigma.io/)**

## enigma info

+ [enigma home page](https://app.enigma.io/)
+ [API docs](https://app.enigma.io/api)

## LICENSE

MIT, see [LICENSE file](https://github.com/rOpenGov/enigma/blob/master/LICENSE) and [MIT text](http://opensource.org/licenses/MIT)

## Quick start

### Install

```coffee
install.packages("devtools")
library("devtools")
install_github("ropengov/enigma")
library("enigma")
```

### Get data

```coffee
out <- enigma_data(dataset='us.gov.whitehouse.visitor-list', select=c('namelast','visitee_namelast','last_updatedby'))
```

Some metadata on the results

```coffee
out$info
```

```coffee
rows_limit total_results   total_pages  current_page 
           50       3577135         71543             1 
```

Look at the data, first 6 rows for readme brevity

```coffee
head(out$result)
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

### Statistics on dataset columns

```coffee
out <- enigma_stats(dataset='us.gov.whitehouse.visitor-list', select='total_people')
```

Some summary stats

```coffee
out$result[c('sum','avg','stddev','variance','min','max')]
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

$min
[1] "0"

$max
[1] "5730"
```

Frequency details

```coffee
head(out$result$frequency)
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


### Metadata on datasets

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
out$info$immediate_nodes
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
out$info$children_tables
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

### Use case: Plot frequency of flight distances

First, get columns for the air carrier dataset

```coffee
dset <- 'us.gov.dot.rita.trans-stats.air-carrier-statistics.t100d-market-all-carrier'
head(enigma_metadata(dset)$columns$table[,c(1:4)])
```

```coffee
              id          label         type index
1     passengers     Passengers type_varchar     0
2        freight Freight (Lbs.) type_varchar     1
3           mail    Mail (Lbs.) type_varchar     2
4       distance Distance (Mi.) type_varchar     3
5 unique_carrier Unique Carrier type_varchar     4
6     airline_id     Airline ID type_numeric     5
```

Looks like there's a column called _distance_ that we can search on. We by default for `varchar` type columns only `frequency` bake for the column. 

```coffee
out <- enigma_stats(dset, select='distance')
head(out$result$frequency)
```

```coffee
  distance count
1     0.00 15648
2    59.00 12960
3   296.00 12748
4    16.00 12570
5    95.00 11966
6    94.00 11964    
```

Then we can do a bit of tidying and make a plot

```coffee
library("ggplot2")
library("ggthemes")
df <- out$result$frequency
df <- data.frame(distance=as.numeric(df$distance), count=as.numeric(df$count))
ggplot(df, aes(distance, count)) + 
  geom_bar(stat="identity") + 
  geom_point() +
  theme_grey(base_size = 18) +
  labs(y="flights", x="distance (miles)")
```

![](http://f.cl.ly/items/0W1q0i3W0G0e440y2j3X/Screen%20Shot%202014-04-22%20at%206.37.20%20PM.png)