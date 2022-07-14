Rem  Copyright (c) Oracle Corporation 1999 - 2019. All Rights Reserved.
Rem
Rem    NAME
Rem      apexebs_apex_dblink_setup.sql
Rem
Rem    DESCRIPTION
Rem      Create views and triggers for integrating APEX Demonstration application, specifically when APEX is installed on a different database server to E-Business Suite.
Rem
Rem    NOTES
Rem      Assumes the schema associated with the APEX Workspace [XX_APEX_LOCAL] is connected on the local database (not running on the EBS Database).
Rem
Rem    REQUIREMENTS
Rem      - Oracle 11.2.0.4 or later
Rem      - User (schema) must have CREATE DATABASE LINK privilege
Rem
Rem    Arguments:
Rem     NONE
Rem
Rem    Example:
Rem
Rem    1)Local
Rem      sqlplus "apex_schema/apex_schema_password" @apexebs_apex_dblink_setup 
Rem
Rem    2)With connect string
Rem      sqlplus "apex_schema/apex_schema_password@vision" @apexebs_apex_dblink_setup
Rem
Rem    MODIFIED   (MM/DD/YYYY)
Rem      dpeake    08/21/2014 - Created
Rem      dpeake    08/29/2014 - Using ACCEPT to recieve / default input
Rem      dpeake    02/14/2019 - Updated references to XX_APEX
Rem      dpeake    04/01/2019 - Updated database object names
Rem      shlayel   07/14/2022 - Modified, allowing complex password by using "" in the connect statement
Rem      shlayel   07/14/2022 - Modified the minimum REQUIREMENTS and rename Application Express to APEX

prompt .  ____   ____           ____        ____
prompt . /    \ |    \   /\    /     |     /
prompt .|      ||    /  /  \  |      |    |
prompt .|      ||---    ----  |      |    |---
prompt .|      ||   \  /    \ |      |    |
prompt . \____/ |    \/      \ \____ |____ \____
prompt .
prompt .
prompt . APEX E*Business Suite Integration Example Setup.
prompt .................................................................
prompt .

set define '^'
set concat on
set concat .
set verify off
set termout off
spool off
set termout on


column foo3 new_val log1

select 'apexebs_apex_dblink_setup_'||to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss')||'.log' foo3 from dual;

spool ^log1

prompt .
prompt .  << Enter Criteria >> 
prompt .
accept DBLINK_NAME char default 'XX_APEX_DBLINK'          prompt '.   Database Link Name [XX_APEX_DBLINK]: '
prompt .
prompt .  *** Note: The remote details requested are related to the minimially privileged user (schema) created on the E-Business Suite Database ***
prompt .
accept REMOTE_USER char default 'XX_APEX'                 prompt '.   Remote Schema Name [XX_APEX]: '
accept REMOTE_PASSWORD char                               prompt '.   Remote Schema (case-sensitive) Password: '
accept REMOTE_HOST char                                   prompt '.   Remote Host Address: '
accept REMOTE_PORT char default '1521'                    prompt '.   Remote Port [1521]: '
accept REMOTE_SERVICE_NAME char                           prompt '.   Remote Service Name: '
prompt .

whenever sqlerror continue

prompt .
prompt ... Create the DB Link to APEX schema on the EBS Server
prompt .
create database link ^DBLINK_NAME
connect to ^REMOTE_USER
identified by "^REMOTE_PASSWORD"
using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=^REMOTE_HOST)(PORT=^REMOTE_PORT))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=^REMOTE_SERVICE_NAME)))';
 
spool off

exit

