SumAll Foundation Homelessness Project
--------------------------------------

Code related to SumAll Homelessness project

SQL Files
---------

__ExportCSVProc.sql__

_GetEvictionsC.sql_

_GetEvictionsW.sql_

_GetEvictionsX.sql:_  Define the xrefs table and read data from a fixed format
text file as supplied by NY City DHS. The lines are initally read in accessible
as a long string, then parsed to get individual variables.

_CreateEvictions.sql_

_JoinEvictions.sql_

_ProcessEvictionAddresses.sql_

_GetGeocodedExits.sql_

_GetGeocodedAddresses.sql_


Python Files
------------
_CleanseAddresses.py_
