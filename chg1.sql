set echo on
spool Report_Chg1.rpt
select name from v$database;
