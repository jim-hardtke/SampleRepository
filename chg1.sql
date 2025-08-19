----set echo on
spool Report_Chg1.rpt
select 1 from dual;
select name, "chg1007" from v$database;
