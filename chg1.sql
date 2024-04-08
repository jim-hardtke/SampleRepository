set echo on
spool Report_Chg1.rpt
select name, 1 from v$database;
