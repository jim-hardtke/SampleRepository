set echo on
spool report_chg1.rpt
select name from v$database;
