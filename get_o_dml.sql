/*set serveroutput on size 200000
set echo off
set feedback off
set verify off
set showmode off
--
ACCEPT l_user CHAR PROMPT  'Username: '
ACCEPT l_table CHAR PROMPT 'Tablename: '
*/
--
declare
 l_user varchar2(20) := 'SR_BANK';
 l_table varchar2(100) := 'DIVISION';

 CURSOR TabCur IS
 SELECT dt.table_name,dt.owner,dt.tablespace_name,
        dt.initial_extent,dt.next_extent,
        dt.pct_used,dt.pct_free,dt.pct_increase, dt.degree,
        tc.COMMENTS
   FROM sys.dba_tables dt
       ,all_tab_comments tc   
  WHERE dt.owner=upper(l_user)
   AND dt.table_name=UPPER(l_table)
   and tc.OWNER = dt.OWNER
   and tc.TABLE_NAME = dt.TABLE_NAME;
--
 CURSOR ColCur(TableName varchar2) IS
 SELECT dtc.column_name col1,
        case dtc.data_type
            when 'LONG'    then     'LONG   '
            when 'LONG RAW'then     'LONG RAW  '
            when 'RAW'     then     'RAW  '
            when 'DATE'    then     'DATE   '
            when 'CHAR'    then     'CHAR' || '(' || dtc.data_length || ') '
            when 'VARCHAR2'then     'VARCHAR' || '(' || dtc.data_length || ') '
            when 'NUMBER'  then
              case
                when dtc.data_scale = 0 then
                   case 
                      when dtc.data_precision < 3 then 'TINYINT'
                      when dtc.data_precision < 5 then 'SMALLINT'
                      when dtc.data_precision < 8 then 'MEDIUMINT'
                      when dtc.data_precision < 11 then 'INT'                        
                      else 'BIGINT'
                   end
                else
                  'FLOAT'
              end  ||
                            DECODE (NVL(dtc.data_precision,0),0, ' ',' (' || dtc.data_precision ||
                            DECODE (NVL(dtc.data_scale, 0),0, ') ',',' || dtc.DATA_SCALE || ') '))
        end ||
        DECODE (dtc.NULLABLE,'N', 'NOT NULL','  ')  col2,
        replace(tc.COMMENTS,'''','"')  as comments,
        data_default
   FROM sys.dba_tab_columns dtc
       ,all_col_comments tc
  WHERE dtc.table_name=TableName
    AND dtc.owner=UPPER(l_user)
    and tc.OWNER(+) = dtc.OWNER
    and tc.TABLE_NAME(+) = dtc.TABLE_NAME
    and tc.COLUMN_NAME(+) = dtc.COLUMN_NAME
 ORDER BY column_id;
--
 ColCount    NUMBER(5);
 MaxCol      NUMBER(5);
 FillSpace   NUMBER(5);
 ColLen      NUMBER(5);
--
BEGIN
 MaxCol:=0;
 --
 FOR TabRec in TabCur LOOP
    SELECT MAX(column_id) INTO MaxCol FROM sys.dba_tab_columns
     WHERE table_name=TabRec.table_name
       AND owner=TabRec.owner;
    --
    dbms_output.put_line('CREATE TABLE '||TabRec.table_name);
    dbms_output.put_line('( ');
    --
    ColCount:=0;
    FOR ColRec in ColCur(TabRec.table_name) LOOP
      ColLen:=length(ColRec.col1);
      FillSpace:=40 - ColLen;
      dbms_output.put(ColRec.col1);
      --
      FOR i in 1..FillSpace LOOP
         dbms_output.put(' ');
      END LOOP;
      --
      dbms_output.put(ColRec.col2);
      ColCount:=ColCount+1;
      --
      if ColRec.data_default is not null then
        dbms_output.put(' default '||(ColRec.data_default)||' ');       
      end if;
      dbms_output.put(' COMMENT '''||ColRec.comments||''' ');
      IF (ColCount < MaxCol) THEN
         dbms_output.put_line(',');
      else
        dbms_output.put_line('');
        dbms_output.put_line('COMMENT '''||TabRec.COMMENTS ||''' ');
        dbms_output.put_line(');');
      END IF;
    END LOOP;
    --
/*
    dbms_output.put_line('TABLESPACE '||TabRec.tablespace_name);
    dbms_output.put_line('PCTFREE '||TabRec.pct_free);
    dbms_output.put_line('PCTUSED '||TabRec.pct_used);
    dbms_output.put_line('STORAGE ( ');
    dbms_output.put_line('  INITIAL     '||TabRec.initial_extent);
    dbms_output.put_line('  NEXT        '||TabRec.next_extent);
    dbms_output.put_line('  PCTINCREASE '||TabRec.pct_increase);
    dbms_output.put_line(' )');
    dbms_output.put_line('PARALLEL '||TabRec.degree);
    dbms_output.put_line('/');
*/    
 END LOOP;
END;
/
