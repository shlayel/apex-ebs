Rem  Copyright (c) Oracle Corporation 1999 - 2022. All Rights Reserved.
Rem
Rem    NAME
Rem      apex_ebs_setup.sql
Rem
Rem    DESCRIPTION
Rem      Installs packages and views and grants rights for integrating APEX Demonstration application.
Rem
Rem    NOTES
Rem      Assumes connected as SYS as SYSDAB user.
Rem
Rem    REQUIREMENTS
Rem      - Oracle 12.1.0.2 or later
Rem      - Oracle E*Business Suite 12.2 or later
Rem      - Oracle APEX 22.1 or later
Rem
Rem    Arguments:
Rem     NONE
Rem
Rem    Example:
Rem
Rem    1)Local
Rem      sqlplus "sys/sys_password" as sysdba
Rem      SQL> @apex_ebs_setup
Rem
Rem    2)With connect string
Rem      sqlplus "sys/sys_password@vision" as sysdba
Rem      SQL> @apex_ebs_setup
Rem
Rem    MODIFIED   (MM/DD/YYYY)
Rem      dpeake    02/14/2019 - Created
Rem      shlayel   02/21/2022 - Modified, allowing complex password by using "" in the connect statement
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

select 'apex_ebs_setup_'||to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss')||'.log' foo3 from dual;

spool ^log1

prompt .
prompt .  << Enter Criteria >>
prompt .
accept EBSVERSION CHAR default '12.2'             prompt '.   Version of EBS [12.2]: '
accept APPS char default 'APPS'                   prompt '.   EBS APPS Username [APPS]: '
accept APPSPWD char                               prompt '.   Password for EBS APPS Username: ' HIDE
accept APEX char default 'XX_APEX'                prompt '.   APEX Schema Name [XX_APEX]: '
accept APEXPWD char                               prompt '.   Password for APEX Schema: ' HIDE
prompt .

whenever sqlerror continue

prompt .
prompt ... Enable editions in APEX Schema
prompt .

declare
  l_stmt varchar2(4000);
begin
  if '^EBSVERSION' = '12.2' then
    l_stmt := 'alter user '|| '^APEX' ||' enable editions';
    execute immediate l_stmt;
  end if;
exception
  when others then null;
end;
/

prompt .
prompt ... Connect to the ^APPS Schema using ^APPSPWD Password
prompt .

connect ^APPS/"^APPSPWD"

prompt .
prompt ... Create views for use in APEX Applications
prompt .

create or replace view xx_apex_ebs_user
    (  user_id
     , user_name
     , start_date
     , end_date
     , description
     , email_address
     , user_guid
     , person_party_id
     , constraint xx_apex_ebs_user_pk
        primary key (user_id)
        rely disable novalidate
    )
  as
    select user_id
    ,      user_name
    ,      start_date
    ,      end_date
    ,      description
    ,      email_address
    ,      user_guid        /* Used for Single-Sign On */
    ,      person_party_id  /* FK to party information */
    from fnd_user;

grant select on xx_apex_ebs_user to ^APEX;
grant select on fnd_responsibility_vl to ^APEX;

prompt .
prompt ... Create Sample APIs to be called from APEX applications
prompt .

create or replace package xx_apex_sample_apis as
function apex_validate_login (  p_username   in  varchar2
                              , p_password   in  varchar2
                             ) return boolean;

procedure apex_update_email (  p_username        in varchar2
                             , p_owner           in varchar2
                             , p_email_address   in varchar2
                            );

end;
/

create or replace package body xx_apex_sample_apis as
function apex_validate_login (  p_username   in  varchar2
                              , p_password   in  varchar2
                             ) return boolean
is
begin
    return fnd_user_pkg.validatelogin(p_username, p_password);
end apex_validate_login;

procedure apex_update_email (  p_username        in varchar2
                             , p_owner           in varchar2
                             , p_email_address   in varchar2
                            )
is
begin
    wf_event.setdispatchmode('async');
    fnd_user_pkg.updateuser(x_user_name=>p_username, x_owner=>p_owner, x_email_address=>p_email_address);
end apex_update_email;

end xx_apex_sample_apis;
/
show errors

grant execute on xx_apex_sample_apis to ^APEX;

prompt .
prompt ... Create APEX Global package for use with EBS Responsibilities
prompt .

create or replace package xx_apex_global authid definer as
  procedure apps_initialize(
     user_id in number,
     resp_id in number,
     resp_appl_id in number,
     security_group_id in number default 0,
     server_id in number default -1);

  function function_test(function_name in varchar2) return boolean;
end;
/

create or replace package body xx_apex_global as
  procedure apps_initialize(
    user_id in number,
    resp_id in number,
    resp_appl_id in number,
    security_group_id in number default 0,
    server_id in number default -1) is
  begin
    fnd_global.apps_initialize(user_id, resp_id, resp_appl_id,
                               security_group_id, server_id);
  end;

  function function_test(function_name in varchar2) return boolean is
  begin
    return fnd_function.test(function_name);
  end;
end;
/
show errors

grant execute on xx_apex_global to ^APEX;

spool off
exit;
