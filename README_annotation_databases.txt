DEPICT and LOLA databases downloaded Feb 1, 2018 from:

https://data.broadinstitute.org/mpg/depict/documentation.html
and
http://cloud.databio.org/regiondb/

external
is a copy of what I used for BESTD, putting here as reference

6 June 2018

Moved everything to
/groupvol/med-bio/aberlang/aberlang_group/data/external/

rsync --ignore-errors --delete -vvazPuiL GTEx.zip external LOLA_databases DEPICT_database README.txt aberlang@login.cx1.hpc.ic.ac.uk:/groupvol/med-bio/aberlang/aberlang_group/data/external/