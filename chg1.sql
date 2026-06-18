set echo on
spool Report_Chg1.rpt
select name, "chg10001" from v$database;
