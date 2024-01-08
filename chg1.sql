set echo on
spool Report_chg1.rpt
select name from v$database;
