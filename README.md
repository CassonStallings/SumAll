SumAll Foundation Homelessness Project
--------------------------------------

Code related to SumAll Homelessness project

SQL Files
---------

__ExportCSVProc.sql__

_GetEvictionsC.sql_

_GetEvictionsW.sql_

__GetEvictionsX.sql:__  Define the xrefs table and read data from a fixed format
text file as supplied by NY City DHS. Each line is initally read in as a long string, then parsed to get individual variables.

_CreateEvictions.sql_

_JoinEvictions.sql_

_ProcessEvictionAddresses.sql_

_GetGeocodedExits.sql_

_GetGeocodedAddresses.sql_


Python Files
------------
_CleanseAddresses.py_
