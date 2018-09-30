
   SELECT 

    name AS FileName, 

    size*1.0/128 AS FileSizeinMB,

    CASE max_size 

        WHEN 0 THEN 'Autogrowth is off.'

        WHEN -1 THEN 'Autogrowth is on.'

        ELSE 'Log file will grow to a maximum size of 2 TB.'

    END,

    growth AS 'GrowthValue',

    'GrowthIncrement' = 

        CASE

            WHEN growth = 0 THEN 'Size is fixed and will not grow.'

            WHEN growth > 0 AND is_percent_growth = 0 

                THEN 'Growth value is in 8-KB pages.'

            ELSE 'Growth value is a percentage.'

        END

FROM tempdb.sys.database_files;

GO



----shrink Tempdb in SQL Server 

use tempdb

GO



DBCC FREEPROCCACHE -- clean cache

DBCC DROPCLEANBUFFERS -- clean buffers

DBCC FREESYSTEMCACHE ('ALL') -- clean system cache

DBCC FREESESSIONCACHE -- clean session cache

DBCC SHRINKDATABASE(tempdb, 10); -- shrink tempdb

dbcc shrinkfile ('tempdev') -- shrink db file

dbcc shrinkfile ('templog') -- shrink log file

GO



-- report the new file sizes

SELECT name, size

FROM sys.master_files

WHERE database_id = DB_ID(N'tempdb');

GO



----remove tempdv files, C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA

--0.0  check how much tempdv files are there

use tempdb

go

EXEC SP_HELPFILE;



--0.1 if 0.2 error error, modify tempdv zsize 

alter database[tempdb] modify file(name=N'templog', size=1024KB);

--0.2 restart SQL server instances and execute the following query

USE tempdb;

go

DBCC SHRINKFILE('templog',EMPTYFILE)

GO

USE master;

GO

ALTER DATABASE tempdb

REMOVE FILE tempdb;



---remove database 'ShanghaiTaxi' log files

-- first shrink file size

use [taxi]

go

DBCC  shrinkfile (N'taxi_log', emptyfile);



USE [taxi];

GO

ALTER DATABASE [taxi] 

REMOVE FILE [taxi_log];

