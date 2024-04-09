set echo on
spool Report_Chg1.rpt
select name, "chg1001" from v$database;
