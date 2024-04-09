set echo on
spool Report_Chg1.rpt
select name, "chg1006" from v$database;
