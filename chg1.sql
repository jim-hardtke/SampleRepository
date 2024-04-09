set echo on
spool Report_Chg1.rpt
select name, "chg1003" from v$database;
