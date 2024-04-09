set echo on
spool Report_Chg1.rpt
select name, "chg1000" from v$database;
