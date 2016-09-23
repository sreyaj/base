do $$
  begin

    -- Remove old masterIntegrationFields from github auth
    delete from "masterIntegrationFields" where id in (76, 77, 78);

    -- Remove redundant masterIntegrationFields from bitbucket auth
    delete from "masterIntegrationFields" where id in (82, 83, 84);

    -- Remove old masterIntegrationFields from bitbucket server auth
    delete from "masterIntegrationFields" where id in (95, 96, 98, 99, 100, 101);

    -- Remove old masterIntegrationFields from github enterprise auth
    delete from "masterIntegrationFields" where id in (104, 105, 106);

    -- Remove systemCodes.id and set code as primary key
    if exists (select 1 from information_schema.columns where table_name = 'systemCodes' and column_name = 'id') then
      alter table "systemCodes" drop column id;
      alter table "systemCodes" add constraint "systemCodes_pkey" primary key (code);
    end if;

    -- Remove systemProperties.id and set fieldName as primary key
    if exists (select 1 from information_schema.columns where table_name = 'systemProperties' and column_name = 'id') then
      alter table "systemProperties" drop column id;
      alter table "systemProperties" add constraint "systemProperties_pkey" primary key ("fieldName");
    end if;

    -- Update  systemMachineImages.systemIntegrationId and set allowedNull to true
    if exists (select 1 from information_schema.columns where table_name = 'systemMachineImages' and column_name = 'systemIntegrationId') then
      alter table "systemMachineImages" alter column "systemIntegrationId" drop not null;
    end if;

    -- insert all systemCodes
    if not exists (select 1 from "systemCodes" where code = 1000) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1000, 'gitRepo', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1001) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1001, 'image', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1003) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1003, 'dockerOptions', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1004) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1004, 'params', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1006) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1006, 'replicas', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1008) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1008, 'kickStart', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1010) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1010, 'time', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1012) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1012, 'version', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1013) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1013, 'trigger', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1014) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1014, 'syncRepo', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1015) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1015, 'cluster', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1016) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1016, 'notification', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1017) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1017, 'loadBalancer', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1018) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1018, 'integration', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 1019) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1019, 'file', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2000) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2000, 'manifest', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2005) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2005, 'runCI', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2007) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2007, 'runSh', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2008) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2008, 'release', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2009) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2009, 'rSync', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2010) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2010, 'deploy', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 2011) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2011, 'jenkinsJob', 'resource', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 4000) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4000, 'queued', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4001) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4001, 'processing', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4002) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4002, 'success', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4003) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4003, 'failure', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4004) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4004, 'error', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4005) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4005, 'waiting', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4006) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4006, 'cancelled', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;
    if not exists (select 1 from "systemCodes" where code = 4007) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4007, 'unstable', 'status', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5000) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5000, 'scm', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5001) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5001, 'hub', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5002) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5002, 'deploy', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5003) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5003, 'notification', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5004) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5004, 'key', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5005) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5005, 'cloudproviders', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5006) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5006, 'secretsBackend', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5007) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5007, 'auth', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5008) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5008, 'payment', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 5009) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5009, 'externalci', 'integration', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 0) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (0, 'WAITING', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 10) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (10, 'QUEUED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 20) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (20, 'PROCESSING', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 30) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (30, 'SUCCESS', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 40) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (40, 'SKIPPED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 50) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (50, 'UNSTABLE', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 60) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (60, 'TIMEOUT', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 70) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (70, 'CANCELED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 80) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (80, 'FAILED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 90) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (90, 'STOPPED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 100) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (100, 'NOTINITIALIZED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 101) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (101, 'NOTDEPLOYED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 110) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (110, 'DELETING', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 120) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (120, 'DELETED', 'statusCodes', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 6000) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (6000, 'member', 'roles', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 6010) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (6010, 'collaborator', 'roles', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemCodes" where code = 6020) then
      insert into "systemCodes" ("code", "name", "group", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values (6020, 'admin', 'roles', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- insert all systemProperties
    if not exists (select 1 from "systemProperties" where "fieldName" = 'sysUserName') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sysUserName', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'sysPassword') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sysPassword', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'sysDeployKey') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sysDeployKey', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'sysDeployKeyExternalId') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sysDeployKeyExternalId', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'sysWebhookExternalId') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sysWebhookExternalId', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'processQueue') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('processQueue', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'registryUserName') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('registryUserName', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'registryAccessKey') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('registryAccessKey', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'registrySecretKey') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('registrySecretKey', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'nodeUserName') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('nodeUserName', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'nodePassword') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('nodePassword', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'execQueue') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('execQueue', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'sshPrivateKey') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sshPrivateKey', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'deployPrivateKey') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('deployPrivateKey', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemProperties" where "fieldName" = 'webhookSecret') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('webhookSecret', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    -- insert all masterIntegrations
    -- Git Store
    if not exists (select 1 from "masterIntegrations" where "name" = 'Git store' and "typeCode" = 5000) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('574ee696d49b091400b75f19', 1, 'Git store', 'Internal Gitlab Server', 'scm', true, 'account', 5000, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Git Store
    if not exists (select 1 from "masterIntegrationFields" where "id" = 1) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (1, '574ee696d49b091400b75f19', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 2) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (2, '574ee696d49b091400b75f19', 'password', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 3) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (3, '574ee696d49b091400b75f19', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Docker
    if not exists (select 1 from "masterIntegrations" where "name" = 'Docker' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('5553a7ac3566980c00a3bf0e', 2, 'Docker', 'Docker', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Docker
    if not exists (select 1 from "masterIntegrationFields" where "id" = 4) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (4, '5553a7ac3566980c00a3bf0e', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 5) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (5, '5553a7ac3566980c00a3bf0e', 'password', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 6) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (6, '5553a7ac3566980c00a3bf0e', 'email', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Private Docker Registry
    if not exists (select 1 from "masterIntegrations" where "name" = 'Private Docker Registry' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('559e8f3e90252e0c00672376', 3, 'Private Docker Registry', 'Private Docker Registry', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Private Docker Registry
    if not exists (select 1 from "masterIntegrationFields" where "id" = 7) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (7, '559e8f3e90252e0c00672376', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 8) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (8, '559e8f3e90252e0c00672376', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 9) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (9, '559e8f3e90252e0c00672376', 'password', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 10) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (10, '559e8f3e90252e0c00672376', 'email', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- slack
    if not exists (select 1 from "masterIntegrations" where "name" = 'Slack' and "typeCode" = 5003) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('55bba7932c6c780b00e4426c', 4, 'Slack', 'Slack', 'notification', true, 'account', 5003, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Slack
    if not exists (select 1 from "masterIntegrationFields" where "id" = 11) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (11, '55bba7932c6c780b00e4426c', 'webhookUrl', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- webhook
    if not exists (select 1 from "masterIntegrations" where "name" = 'webhook' and "typeCode" = 5003) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('573aab7c5419f10f00bef322', 5, 'webhook', 'Event Trigger', 'notification', true, 'account', 5003, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for webhook
    if not exists (select 1 from "masterIntegrationFields" where "id" = 13) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (13, '573aab7c5419f10f00bef322', 'project', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 14) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (14, '573aab7c5419f10f00bef322', 'webhookURL', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 15) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (15, '573aab7c5419f10f00bef322', 'authorization', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- GCR
    if not exists (select 1 from "masterIntegrations" where "name" = 'GCR' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('5553a8333566980c00a3bf1b', 6, 'GCR', 'GCR', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrations" where "name" = 'braintree' and "typeCode" = 5008) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57aafd0673ea26cb053fe1ca', 32, 'braintree', 'braintree', 'payment', true, 'system', 5008, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for GCR
    if not exists (select 1 from "masterIntegrationFields" where "id" = 16) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (16, '5553a8333566980c00a3bf1b', 'JSON_key', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- ECR
    if not exists (select 1 from "masterIntegrations" where "name" = 'ECR' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('5673c6561895ca4474669507', 7, 'ECR', 'Amazon ECR', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for ECR
    if not exists (select 1 from "masterIntegrationFields" where "id" = 17) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (17, '5673c6561895ca4474669507', 'aws_access_key_id', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 18) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (18, '5673c6561895ca4474669507', 'aws_secret_access_key', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- AWS
    if not exists (select 1 from "masterIntegrations" where "name" = 'AWS' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('55c8d2333399590c007982f8', 8, 'AWS', 'AWS', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for AWS
    if not exists (select 1 from "masterIntegrationFields" where "id" = 19) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (19, '55c8d2333399590c007982f8', 'aws_access_key_id', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 20) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (20, '55c8d2333399590c007982f8', 'aws_secret_access_key', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 22) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (22, '55c8d2333399590c007982f8', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- AWS_IAM
    if not exists (select 1 from "masterIntegrations" where "name" = 'AWS_IAM' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('571032a897aadea0ee186900', 9, 'AWS_IAM', 'Amazon Web Services (IAM)', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-23', '2016-06-23');
    end if;

    -- masterIntegrationFields for AWS_IAM
    if not exists (select 1 from "masterIntegrationFields" where "id" = 24) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (24, '571032a897aadea0ee186900', 'assumeRoleARN', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-23', '2016-06-23');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 26) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (26, '571032a897aadea0ee186900', 'output', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-23', '2016-06-23');
    end if;
    if not exists (select 1 from "masterIntegrationFields" where "id" = 27) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (27, '571032a897aadea0ee186900', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-23', '2016-06-23');
    end if;

    -- AWS-ROOT
    if not exists (select 1 from "masterIntegrations" where "name" = 'AWS' and "typeCode" = 5005) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57467326b3cbfc0c004f9110', 10, 'AWS', 'AWS-ROOT', 'cloudproviders', true, 'system', 5005, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for AWS-ROOT
    if not exists (select 1 from "masterIntegrationFields" where "id" = 28) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (28, '57467326b3cbfc0c004f9110', 'accessKey', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 29) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (29, '57467326b3cbfc0c004f9110', 'secretKey', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- GKE
    if not exists (select 1 from "masterIntegrations" where "name" = 'GKE' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d417653270aa438861cf65', 11, 'GKE', 'Google Container Engine', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

     -- masterIntegrationFields for GKE
    if not exists (select 1 from "masterIntegrationFields" where "id" = 30) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (30, '56d417653270aa438861cf65', 'JSON_key', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 31) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (31, '56d417653270aa438861cf65', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- DCL
    if not exists (select 1 from "masterIntegrations" where "name" = 'DCL' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('570651b5f028a50b008bd955', 12, 'DCL', 'Docker Cloud', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

     -- masterIntegrationFields for DCL
    if not exists (select 1 from "masterIntegrationFields" where "id" = 32) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (32, '570651b5f028a50b008bd955', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 33) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (33, '570651b5f028a50b008bd955', 'token', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 34) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (34, '570651b5f028a50b008bd955', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- ACS
    if not exists (select 1 from "masterIntegrations" where "name" = 'ACS' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('5723561699ddf70c00be27ed', 13, 'ACS', 'Azure Container Service', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for ACS
    if not exists (select 1 from "masterIntegrationFields" where "id" = 35) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (35, '5723561699ddf70c00be27ed', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 36) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (36, '5723561699ddf70c00be27ed', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- ghe
    if not exists (select 1 from "masterIntegrations" where "name" = 'ghe' and "typeCode" = 5000) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('563347d6046d220c002a3474', 15, 'ghe', 'Github Enterprise', 'scm', true, 'account', 5000, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for ghe
    if not exists (select 1 from "masterIntegrationFields" where "id" = 39) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (39, '563347d6046d220c002a3474', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 40) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (40, '563347d6046d220c002a3474', 'token', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- bitbucket
    if not exists (select 1 from "masterIntegrations" where "name" = 'bitbucket' and "typeCode" = 5000) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('562dc347b84b390c0083e72e', 16, 'bitbucket', 'BitBucket', 'scm', true, 'account', 5000, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for bitbucket
    if not exists (select 1 from "masterIntegrationFields" where "id" = 41) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (41, '562dc347b84b390c0083e72e', 'token', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 42) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (42, '562dc347b84b390c0083e72e', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Email
    if not exists (select 1 from "masterIntegrations" where "name" = 'Email' and "typeCode" = 5003) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('55816ffb4d96360c000ec6f3', 18, 'Email', 'Email', 'notification', true, 'account', 5003, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Email
    if not exists (select 1 from "masterIntegrationFields" where "id" = 44) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (44, '55816ffb4d96360c000ec6f3', 'Email address', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Quay.io
    if not exists (select 1 from "masterIntegrations" where "name" = 'Quay.io' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('559eab320a31140d00a15d3a', 19, 'Quay.io', 'Quay.io', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Quay.io
    if not exists (select 1 from "masterIntegrationFields" where "id" = 45) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (45, '559eab320a31140d00a15d3a', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 46) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (46, '559eab320a31140d00a15d3a', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 47) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (47, '559eab320a31140d00a15d3a', 'password', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 48) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (48, '559eab320a31140d00a15d3a', 'email', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 49) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (49, '559eab320a31140d00a15d3a', 'accessToken', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- github
    if not exists (select 1 from "masterIntegrations" where "name" = 'github' and "typeCode" = 5000) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('562dc2f048095b0d00ceebcd', 20, 'github', 'GitHub', 'scm', true, 'account', 5000, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for github
    if not exists (select 1 from "masterIntegrationFields" where "id" = 50) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (50, '562dc2f048095b0d00ceebcd', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 51) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (51, '562dc2f048095b0d00ceebcd', 'token', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- gitlab
    if not exists (select 1 from "masterIntegrations" where "name" = 'gitlab' and "typeCode" = 5000) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('5728e13b3d93990c000fd8e4', 21, 'gitlab', 'GitLab', 'scm', true, 'account', 5000,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for gitlab
    if not exists (select 1 from "masterIntegrationFields" where "id" = 52) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (52, '5728e13b3d93990c000fd8e4', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 53) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (53, '5728e13b3d93990c000fd8e4', 'token', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- bitbucketServer
    if not exists (select 1 from "masterIntegrations" where "name" = 'bitbucketServer' and "typeCode" = 5000) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('572af430ead9631100f7f64d', 22, 'bitbucketServer', 'BitBucket Server', 'scm', true, 'account', 5000, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for bitbucketServer
    if not exists (select 1 from "masterIntegrationFields" where "id" = 54) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (54, '572af430ead9631100f7f64d', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 55) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (55, '572af430ead9631100f7f64d', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 56) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (56, '572af430ead9631100f7f64d', 'token', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- ssh-key
    if not exists (select 1 from "masterIntegrations" where "name" = 'ssh-key' and "typeCode" = 5004) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('568aa7c3368a090c006da702', 23, 'ssh-key', 'SSH Key', 'key', true, 'account', 5004, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for ssh-key
    if not exists (select 1 from "masterIntegrationFields" where "id" = 57) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (57, '568aa7c3368a090c006da702', 'publicKey', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 58) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (58, '568aa7c3368a090c006da702', 'privateKey', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- pem-key
    if not exists (select 1 from "masterIntegrations" where "name" = 'pem-key' and "typeCode" = 5004) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('568aa74cd43b0d0c004fec91', 24, 'pem-key', 'PEM Key', 'key', true, 'account', 5004, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for pem-key
    if not exists (select 1 from "masterIntegrationFields" where "id" = 59) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (59, '568aa74cd43b0d0c004fec91', 'key', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- hipchat
    if not exists (select 1 from "masterIntegrations" where "name" = 'hipchat' and "typeCode" = 5003) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56fb978f1cc7210f00bd5e72', 25, 'hipchat', 'HipChat', 'notification', true, 'account', 5003, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for hipchat
    if not exists (select 1 from "masterIntegrationFields" where "id" = 60) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (60, '56fb978f1cc7210f00bd5e72', 'token', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Docker Trusted Registry
    if not exists (select 1 from "masterIntegrations" where "name" = 'Docker Trusted Registry' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57110b987ed9d269c9d71ac1', 26, 'Docker Trusted Registry', 'Docker Trusted Registry', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Docker Trusted Registry
    if not exists (select 1 from "masterIntegrationFields" where "id" = 61) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (61, '57110b987ed9d269c9d71ac1', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 62) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (62, '57110b987ed9d269c9d71ac1', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 63) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (63, '57110b987ed9d269c9d71ac1', 'password', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 64) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (64, '57110b987ed9d269c9d71ac1', 'email', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- DDC
    if not exists (select 1 from "masterIntegrations" where "name" = 'DDC' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('571f081b37803a0d00455d25', 27, 'DDC', 'Docker DataCenter', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for DDC
    if not exists (select 1 from "masterIntegrationFields" where "id" = 65) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (65, '571f081b37803a0d00455d25', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 66) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (66, '571f081b37803a0d00455d25', 'password', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 67) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (67, '571f081b37803a0d00455d25', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- TRIPUB
    if not exists (select 1 from "masterIntegrations" where "name" = 'TRIPUB' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('576ce63321333398d11a35ab', 28, 'TRIPUB', 'Joyent Triton Public Cloud ', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for TRIPUB
    if not exists (select 1 from "masterIntegrationFields" where "id" = 68) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (68, '576ce63321333398d11a35ab', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 69) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (69, '576ce63321333398d11a35ab', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 70) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (70, '576ce63321333398d11a35ab', 'validityPeriod', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if exists (select 1 from "systemMachineImages" where "provider" = 'AWS') then
      update "systemMachineImages" set "systemIntegrationId" = NULL where "provider" = 'AWS';
    end if;

    if exists (select 1 from "masterIntegrationFields" where "id" = 71 and "isRequired" = true) then
      update "masterIntegrationFields" set "isRequired" = false where "id" = 71;
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 71) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (71, '576ce63321333398d11a35ab', 'publicKey', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if exists (select 1 from "masterIntegrationFields" where "id" = 72 and "isRequired" = true) then
      update "masterIntegrationFields" set "isRequired" = false where "id" = 72;
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 72) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (72, '576ce63321333398d11a35ab', 'privateKey', 'string', false, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if exists (select 1 from "masterIntegrationFields" where "id" = 73 and "isRequired" = true) then
      update "masterIntegrationFields" set "isRequired" = false where "id" = 73;
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 73) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (73, '576ce63321333398d11a35ab', 'certificates', 'string', false, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- github auth
    if not exists (select 1 from "masterIntegrations" where "name" = 'github' and "typeCode" = 5007) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('577de63321333398d11a35ac', 30, 'github', 'github auth', 'auth', true, 'system', 5007, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for github auth
    if not exists (select 1 from "masterIntegrationFields" where "id" = 74) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (74, '577de63321333398d11a35ac', 'clientId', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 75) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (75, '577de63321333398d11a35ac', 'clientSecret', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 111) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (111, '577de63321333398d11a35ac', 'wwwUrl', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 79) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (79, '577de63321333398d11a35ac', 'providerId', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- bitbucket auth
    if not exists (select 1 from "masterIntegrations" where "name" = 'bitbucket' and "typeCode" = 5007) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('577de63321333398d11a35ad', 31, 'bitbucket', 'bitbucket auth', 'auth', true, 'system', 5007, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for bitbucket auth
    if not exists (select 1 from "masterIntegrationFields" where "id" = 80) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (80, '577de63321333398d11a35ad', 'clientId', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 81) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (81, '577de63321333398d11a35ad', 'clientSecret', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 108) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (108, '577de63321333398d11a35ad', 'wwwUrl', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 85) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (85, '577de63321333398d11a35ad', 'providerId', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;


    -- SMTP
    if not exists (select 1 from "masterIntegrations" where "name" = 'SMTP' and "typeCode" = 5003) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57cea8056ce9c71800d31ab3', 33, 'SMTP', 'SMTP', 'notification', true, 'system', 5003, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for SMTP
    if not exists (select 1 from "masterIntegrationFields" where "id" = 86) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (86, '57cea8056ce9c71800d31ab3', 'emailAuthUser', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 87) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (87, '57cea8056ce9c71800d31ab3', 'emailAuthPassword', 'string', false, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 88) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (88, '57cea8056ce9c71800d31ab3', 'emailSender', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 89) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (89, '57cea8056ce9c71800d31ab3', 'emailServiceName', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Amazon S3
    if not exists (select 1 from "masterIntegrations" where "name" = 'amazons3' and "typeCode" = 5005) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57cecf81c3d9bb70153d8249', 34, 'amazons3', 'Amazon S3', 'cloudproviders', true, 'system', 5005, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for Amazon S3
    if not exists (select 1 from "masterIntegrationFields" where "id" = 90) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (90, '57cecf81c3d9bb70153d8249', 'bucketName', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 91) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (91, '57cecf81c3d9bb70153d8249', 'accessKey', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 92) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (92, '57cecf81c3d9bb70153d8249', 'secretKey', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- bitbucket server auth
    if not exists (select 1 from "masterIntegrations" where "name" = 'bitbucketServer' and "typeCode" = 5007) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('577de63321333398d11a35ae', 35, 'bitbucketServer', 'bitbucket server auth', 'auth', true, 'system', 5007, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for bitbucket server auth
    if not exists (select 1 from "masterIntegrationFields" where "id" = 93) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (93, '577de63321333398d11a35ae', 'clientId', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 94) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (94, '577de63321333398d11a35ae', 'clientSecret', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 109) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (109, '577de63321333398d11a35ae', 'wwwUrl', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 97) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (97, '577de63321333398d11a35ae', 'providerId', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- github enterprise auth
    if not exists (select 1 from "masterIntegrations" where "name" = 'githubEnterprise' and "typeCode" = 5007) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('507f1f77bcf86cd799439011', 36, 'githubEnterprise', 'github enterprise auth', 'auth', true, 'system', 5007, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for github enterprise
    if not exists (select 1 from "masterIntegrationFields" where "id" = 102) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (102, '507f1f77bcf86cd799439011', 'clientId', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 103) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (103, '507f1f77bcf86cd799439011', 'clientSecret', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 110) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (110, '507f1f77bcf86cd799439011', 'wwwUrl', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 107) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (107, '507f1f77bcf86cd799439011', 'providerId', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- JENKINS
    if not exists (select 1 from "masterIntegrations" where "name" = 'jenkinsJob' and "typeCode" = 5009) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57dbab5d15c59206bf4fbb50', 37, 'jenkinsJob', 'Jenkins', 'externalci', true, 'account', 5009, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for JENKINS
    if not exists (select 1 from "masterIntegrationFields" where "id" = 108) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (108, '57dbab5d15c59206bf4fbb50', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 109) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (109, '57dbab5d15c59206bf4fbb50', 'password/apiToken', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 110) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (110, '57dbab5d15c59206bf4fbb50', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- artifactory
    if not exists (select 1 from "masterIntegrations" where "name" = 'artifactory' and "typeCode" = 5001) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('57dbab5d15c59206bf4fbb51', 38, 'artifactory', 'JFrog Artifactory', 'hub', true, 'account', 5001, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for artifactory
    if not exists (select 1 from "masterIntegrationFields" where "id" = 115) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (115, '57dbab5d15c59206bf4fbb51', 'username', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 116) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (116, '57dbab5d15c59206bf4fbb51', 'API_key', 'string', true, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 117) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (117, '57dbab5d15c59206bf4fbb51', 'url', 'string', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- CLUSTER
    if not exists (select 1 from "masterIntegrations" where "name" = 'CLUSTER' and "typeCode" = 5002) then
      insert into "masterIntegrations" ("id", "masterIntegrationId", "name", "displayName", "type", "isEnabled", "level", "typeCode", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('576ce63321333398d11a35ac', 39, 'CLUSTER', 'Node Cluster', 'deploy', true, 'account', 5002, '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- masterIntegrationFields for CLUSTER
    if not exists (select 1 from "masterIntegrationFields" where "id" = 118) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (118, '576ce63321333398d11a35ac', 'nodes', 'array', true, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 119) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (119, '576ce63321333398d11a35ac', 'publicKey', 'string', false, false,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "masterIntegrationFields" where "id" = 120) then
      insert into "masterIntegrationFields" ("id", "masterIntegrationId", "name", "dataType", "isRequired", "isSecure","createdBy", "updatedBy", "createdAt", "updatedAt")
      values (120, '576ce63321333398d11a35ac', 'privateKey', 'string', false, true,'54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a', '2016-06-01', '2016-06-01');
    end if;

    -- Add systemImages

    if not exists (select 1 from "systemImages" where "systemImageId" = 1) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('565c404911614a47280079d8', 1, 'shippable/minv2', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 2) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4164e71e4ea0c00a87562', 2, 'drydock/u12nod', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 3) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4165571e4ea0c00a876ab', 3, 'drydock/u12pyt', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 4) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4165c71e4ea0c00a87815', 4, 'drydock/u12jav', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 5) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d416622d28670c0001d9e5', 5, 'drydock/u12sca', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 6) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4166821e3800d00186af0', 6, 'drydock/u12rub', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 7) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4166d2d28670c0001daf9', 7, 'drydock/u12php', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 8) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d416742d28670c0001de37', 8, 'drydock/u12gol', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 9) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4167a71e4ea0c00a87e97', 9, 'drydock/u12clo', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 10) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4167f21e3800d00186eb1', 10, 'drydock/u14nod', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 11) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4168421e3800d001871b9', 11, 'drydock/u14pyt', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 12) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d416882d28670c0001e5d4', 12, 'drydock/u14jav', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 13) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4168e8d5d8b0d003ba048', 13, 'drydock/u14sca', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 14) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d416922d28670c0001e9c1', 14, 'drydock/u14rub', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 15) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4169821e3800d001876c0', 15, 'drydock/u14php', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 16) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4169d2d28670c0001eecb', 16, 'drydock/u14gol', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 17) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d416a321e3800d00187afd', 17, 'drydock/u14clo', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 18) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d447d362e4000d0072fded', 18, 'drydock/u12nodpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 19) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d447e070def30c00cb9bd2', 19, 'drydock/u12nodall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 20) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d447ed70def30c00cba197', 20, 'drydock/u12pytpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 21) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d447f570def30c00cba434', 21, 'drydock/u12pytall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 22) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4480270def30c00cba8a1', 22, 'drydock/u12javpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 23) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4480b70def30c00cbaaf7', 23, 'drydock/u12javall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 24) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4481670def30c00cbad96', 24, 'drydock/u12scapls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 25) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4481d7ba0490c008571cd', 25, 'drydock/u12scaall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 26) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4482362e4000d00731976', 26, 'drydock/u12rubpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 27) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4482970def30c00cbb19b', 27, 'drydock/u12ruball', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 28) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4482f7ba0490c008575bb', 28, 'drydock/u12phppls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 29) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4483762e4000d00731e7d', 29, 'drydock/u12phpall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 30) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4483e62e4000d00731ff0', 30, 'drydock/u12golpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 31) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4484562e4000d00732325', 31, 'drydock/u12golall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 32) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448527ba0490c00857b1e', 32, 'drydock/u12clopls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 33) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4485b70def30c00cbbfbc', 33, 'drydock/u12cloall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 34) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4486562e4000d00732a3a', 34, 'drydock/u14nodpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 35) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4486c62e4000d00732c21', 35, 'drydock/u14nodall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 36) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4487870def30c00cbc5b1', 36, 'drydock/u14pytpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 37) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d44881805a410c003a5b6c', 37, 'drydock/u14pytall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 38) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4489b70def30c00cbd5b0', 38, 'drydock/u14javpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 39) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448a470def30c00cbda5f', 39, 'drydock/u14javall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 40) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448c070def30c00cbe87e', 40, 'drydock/u14scapls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 41) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448c970def30c00cbea2b', 41, 'drydock/u14scaall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 42) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448e070def30c00cc06e7', 42, 'drydock/u14rubpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 43) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448e870def30c00cc0f11', 43, 'drydock/u14ruball', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 44) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448ed70def30c00cc164e', 44, 'drydock/u14phppls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 45) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448f470def30c00cc1aca', 45, 'drydock/u14phpall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 46) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d448fc70def30c00cc235f', 46, 'drydock/u14golpls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 47) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4490470def30c00cc2d0d', 47, 'drydock/u14golall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 48) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4490b70def30c00cc32fe', 48, 'drydock/u14clopls', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 49) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('56d4491570def30c00cc3ae1', 49, 'drydock/u14cloall', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 50) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('570631d5c72afc0c00c3cd54', 50, 'drydock/u14cpp', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    if not exists (select 1 from "systemImages" where "systemImageId" = 51) then
      insert into "systemImages" ("id", "systemImageId", "name", "isActive","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('570631e08317100c00ef87b9', 51, 'drydock/u12cpp', true, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;

    -- Add sourceName to resources and migrate name to sourceName
    if not exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'sourceName') then
      alter table "resources" add column "sourceName" varchar(255);
      UPDATE "resources" SET "sourceName" = "name";
    end if;

    -- Add sysIntegrationName to systemProperties
    if not exists (select 1 from "systemProperties" where "fieldName" = 'sysIntegrationName') then
      insert into "systemProperties" ("fieldName", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('sysIntegrationName', '54188262bc4d591ba438d62a', '54188262bc4d591ba438d62a',  '2016-06-01', '2016-06-01');
    end if;

    -- Add subscriptionIntegrationId to resources
    if not exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'subscriptionIntegrationId') then
      alter table "resources" add column "subscriptionIntegrationId" integer;
    end if;

    -- Add projectId to resources
    if not exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'projectId') then
      alter table "resources" add column "projectId" varchar(24);
    end if;

    -- Add nextTriggerTime to resources
    if not exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'nextTriggerTime') then
      alter table "resources" add column "nextTriggerTime" timestamp with time zone;
    end if;

    -- Add resourceNextTriggerTimeI Index on resources
    create index if not exists "resourceNextTriggerTimeI" on "resources" using btree("nextTriggerTime");

    -- Remove accountIntegrationId in resources
    if exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'accountIntegrationId') then
      alter table "resources" drop column "accountIntegrationId";
    end if;

    -- Remove isJobStep in resources
    if exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'isJobStep') then
      alter table "resources" drop column "isJobStep";
    end if;

    -- Change jobLengthInMS of dailyAggs from int to big int
    if exists (select 1 from information_schema.columns where table_name = 'dailyAggs' and column_name = 'jobLengthInMS' and data_type = 'int') then
      alter table "dailyAggs" ALTER COLUMN "jobLengthInMS" type bigint;
    end if;

    -- Change jobLengthInMS of dailyAggs from int to big int
    if exists (select 1 from information_schema.columns where table_name = 'projectDailyAggs' and column_name = 'jobLengthInMS' and data_type = 'int') then
      alter table "projectDailyAggs" ALTER COLUMN "jobLengthInMS" type bigint;
    end if;

  -- Make "formJSONValues" nullable in systemIntegrations table
    if exists (select 1 from information_schema.columns where table_name = 'systemIntegrations' and column_name = 'formJSONValues') then
      alter table "systemIntegrations" alter column "formJSONValues" drop not null;
    end if;

    -- Add isConsistent to resources and set it as false
    if not exists (select 1 from information_schema.columns where table_name = 'resources' and column_name = 'isConsistent') then
      alter table "resources" add column "isConsistent" boolean;
      UPDATE "resources" SET "isConsistent" = false;
    end if;

    -- Set default values true for buildJobs.isSerial
    if exists (select 1 from information_schema.columns where table_name = 'buildJobs' and column_name = 'isSerial' and column_default IS NOT NULL) then
      alter table "buildJobs" alter column "isSerial" SET DEFAULT true;
    end if;

    --Add execImage column to systemMachineImages
    if not exists (select 1 from information_schema.columns where table_name = 'systemMachineImages' and column_name = 'execImage') then
      alter table "systemMachineImages" add column "execImage" varchar(80);
      update "systemMachineImages" set "execImage"='shipimg/mexec:master.3859' where "execImage" is null;
      alter table "systemMachineImages" alter column "execImage" set not null;
    end if;

    --Add runShImage column to systemMachineImages
    if not exists (select 1 from information_schema.columns where table_name = 'systemMachineImages' and column_name = 'runShImage') then
      alter table "systemMachineImages" add column "runShImage" varchar(80);
      update "systemMachineImages" set "runShImage"='374168611083.dkr.ecr.us-east-1.amazonaws.com/micro50:stepExec.v4.10.13' where "runShImage" is null;
      alter table "systemMachineImages" alter column "runShImage" set not null;
    end if;

    --Add execImage column to systemConfigs
    if not exists (select 1 from information_schema.columns where table_name = 'systemConfigs' and column_name = 'execImage') then
      alter table "systemConfigs" add column "execImage" varchar(255);
      update "systemConfigs" set "execImage"='shipimg/mexec:master.3859' where "execImage" is null;
      alter table "systemConfigs" alter column "execImage" set not null;
    end if;

    -- Add systemMachineImages to postgres
    if not exists (select 1 from "systemMachineImages" where "systemMachineImageId" = 1) then
      insert into "systemMachineImages" ("id", "systemMachineImageId","externalId",  "provider", "name", "description", "isAvailable","isDefault","securityGroup", "keyName", "execImage", "runShImage","region","createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('572c81cb39a5440c0031b61c', 1, 'ami-1015f47d', 'AWS', 'Stable-EC2', 'Stable AMI version of ec2', true, true,'"sg-89eb30f1','shippable-beta', (select "execImage" from "systemConfigs" where id=1), '374168611083.dkr.ecr.us-east-1.amazonaws.com/micro50:stepExec.v4.10.13', 'us-east-1','540e7734399939140041d882', '540e7734399939140041d882', '2016-05-06T11:36:43.715Z', '2016-06-11T02:33:27.469Z');
    end if;

    -- Add versionName to versions
    if not exists (select 1 from information_schema.columns where table_name = 'versions' and column_name = 'versionName') then
      alter table "versions" add column "versionName" varchar(255);
    end if;

    -- Add projectId to versions
    if not exists (select 1 from information_schema.columns where table_name = 'versions' and column_name = 'projectId') then
      alter table "versions" add column "projectId" varchar(24);
    end if;

    -- Add github in providers
    if not exists (select 1 from "providers" where "url" = 'https://api.github.com') then
      insert into "providers" ("id", "masterIntegrationId", "url", "name", "createdAt", "updatedAt")
      values ('562dbd9710c5980d003b0451', '562dc2f048095b0d00ceebcd', 'https://api.github.com', 'github', '2016-02-29T00:00:00.000Z', '2016-02-29T00:00:00.000Z');
    end if;

    -- Add bitbucket in providers
    if not exists (select 1 from "providers" where "url" = 'https://bitbucket.org') then
      insert into "providers" ("id", "masterIntegrationId", "url", "name", "createdAt", "updatedAt")
      values ('562dbda348095b0d00ce6a43', '562dc347b84b390c0083e72e', 'https://bitbucket.org', 'bitbucket', '2016-02-29T00:00:00.000Z', '2016-02-29T00:00:00.000Z');
    end if;

    -- Make "sourceId" nullable in projects table
    if exists (select 1 from information_schema.columns where table_name = 'projects' and column_name = 'sourceId') then
      alter table "projects" alter column "sourceId" drop not null;
    end if;

    -- change type of "sourceDefaultBranch" to varchar(255) in projects table
    if exists (select 1 from information_schema.columns where table_name = 'projects' and column_name = 'sourceDefaultBranch') then
      alter table "projects" alter column "sourceDefaultBranch" type varchar(255);
    end if;

    -- Add "isInternal" to accountTokens table
    if not exists (select 1 from information_schema.columns where table_name = 'accountTokens' and column_name = 'isInternal') then
      alter table "accountTokens" add column "isInternal" BOOLEAN DEFAULT false;
    end if;

    -- Add "privateJobQuota" to subscriptions table
    if not exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'privateJobQuota') then
      alter table "subscriptions" add column "privateJobQuota" INTEGER;
      -- Initial default for existing rows
      update "subscriptions" set "privateJobQuota" = 150;
      alter table "subscriptions" alter column "privateJobQuota" set not null;
    end if;

    -- Add "privateJobCount" to subscriptions table
    if not exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'privateJobCount') then
      alter table "subscriptions" add column "privateJobCount" INTEGER default 0 not null;
    end if;

    -- Add "privateJobQuotaResetsAt" to subscriptions table
    if not exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'privateJobQuotaResetsAt') then
      alter table "subscriptions" add column "privateJobQuotaResetsAt" TIMESTAMP WITH TIME ZONE;
      -- Initial default for existing rows
      update "subscriptions" set "privateJobQuotaResetsAt" = '2016-09-01';
      alter table "subscriptions" alter column "privateJobQuotaResetsAt" set not null;
    end if;

    -- Drop not null constraint on formJSONValues for accountIntegrations
    if exists (select 1 from information_schema.columns where table_name = 'accountIntegrations' and column_name = 'formJSONValues') then
      alter table "accountIntegrations" alter column "formJSONValues" drop not null;
    end if;

    -- Remove unused systemCodes
    delete from "systemCodes" where "code" = 1002 and "name" = 'ecsCluster' and "group" = 'resource';

    delete from "systemCodes" where "code" = 1005 and "name" = 'dclCluster' and "group" = 'resource';

    delete from "systemCodes" where "code" = 1007 and "name" = 'gkeCluster' and "group" = 'resource';

    delete from "systemCodes" where "code" = 1009 and "name" = 'ddcCluster' and "group" = 'resource';

    delete from "systemCodes" where "code" = 1011 and "name" = 'tripubCluster' and "group" = 'resource';

    delete from "systemCodes" where "code" = 2001 and "name" = 'ecsDeploy' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3001 and "name" = 'ecsDeploySteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 2003 and "name" = 'gkeDeploy' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3003 and "name" = 'gkeDeploySteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 2006 and "name" = 'tripubDeploy' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3006 and "name" = 'tripubDeploySteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 2002 and "name" = 'dclDeploy' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3002 and "name" = 'dclDeploySteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 2004 and "name" = 'ddcDeploy' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3004 and "name" = 'ddcDeploySteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3000 and "name" = 'manifestSteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3005 and "name" = 'runCISteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3007 and "name" = 'runShSteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3008 and "name" = 'releaseSteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3009 and "name" = 'rSyncSteps' and "group" = 'resource';

    delete from "systemCodes" where "code" = 3010 and "name" = 'deploySteps' and "group" = 'resource';

    -- Vault
    create table if not exists "vault_kv_store" (
      parent_path text collate "C" not null,
      path        text collate "C",
      key         text collate "C",
      value       bytea,
      constraint pkey primary key (path, key)
    );
    create index if not exists parent_path_idx on vault_kv_store(parent_path);
    alter table "vault_kv_store" owner to "apiuser";

    -- Add braintreeSubscriptionId in subscriptions
     if not exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'braintreeSubscriptionId') then
       alter table "subscriptions" add column "braintreeSubscriptionId" character varying(255);
     end if;

    -- Add minionCount in subscriptions
     if not exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'minionCount') then
       alter table "subscriptions" add column "minionCount" integer NOT NULL DEFAULT 1;
     end if;

  -- Add pipelineCount in subscriptions
     if not exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'pipelineCount') then
       alter table "subscriptions" add column "pipelineCount" integer NOT NULL DEFAULT 1;
     end if;

  -- Add discount in transactions
     if not exists (select 1 from information_schema.columns where table_name = 'transactions' and column_name = 'discount') then
       alter table "transactions" add column "discount" float NOT NULL DEFAULT 0;
     end if;

  -- Add price in transactions
     if not exists (select 1 from information_schema.columns where table_name = 'transactions' and column_name = 'price') then
       alter table "transactions" add column "price" float NOT NULL DEFAULT 0;
     end if;

  -- Adds serviceUser account details in accounts table for local
    if not exists (select 1 from "accounts" where "id" = '540e55445e5bad6f98764522' and "systemRoles" like '%serviceUser%') then
      insert into "accounts" ("id", "systemRoles", "createdAt", "updatedAt")
      values ('540e55445e5bad6f98764522', '[ "serviceUser", "superUser" ]', '2016-02-29T00:00:00Z', '2016-02-29T00:00:00Z');
    end if;

  -- Adds serviceUser token in accountTokens table for local
    if not exists (select 1 from "accountTokens" where "name" = 'serviceUser' and "isInternal" = true) then
      insert into "accountTokens" ("id", "name", "accountId", "apiToken", "isInternal", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values ('540e55445e5bad6f98764522', 'serviceUser', '540e55445e5bad6f98764522', (select "serviceUserToken" from "systemConfigs" where id=1), true, '540e55445e5bad6f98764522', '540e55445e5bad6f98764522', '2016-02-29T00:00:00Z', '2016-02-29T00:00:00Z');
    end if;

  -- Update routePermissions.routePattern to use 255 characters
    if exists (select 1 from information_schema.columns where table_name = 'routePermissions' and column_name = 'routePattern') then
      alter table "routePermissions" alter column "routePattern" type varchar(255);
    end if;

  -- Update mailChimpId columns in accounts table to use 80 characters
    if exists (select 1 from information_schema.columns where table_name = 'accounts' and column_name = 'mailChimpId' and character_maximum_length = 24) then
      alter table "accounts" alter column "mailChimpId" type varchar(80);
    end if;

  -- Remove paidSubCount from dailyAggs
    if exists (select 1 from information_schema.columns where table_name = 'dailyAggs' and column_name = 'paidSubCount') then
      alter table "dailyAggs" drop column "paidSubCount";
    end if;

   -- Remove isNewPipeline from subscriptions
    if exists (select 1 from information_schema.columns where table_name = 'subscriptions' and column_name = 'isNewPipeline') then
      alter table "subscriptions" drop column "isNewPipeline";
    end if;

  -- Add externalBuildUrl in builds
    if not exists (select 1 from information_schema.columns where table_name = 'builds' and column_name = 'externalBuildUrl') then
      alter table "builds" add column "externalBuildUrl" varchar(510);
    end if;

  -- Add projectId in builds
    if not exists (select 1 from information_schema.columns where table_name = 'builds' and column_name = 'projectId') then
      alter table "builds" add column "projectId" varchar(24);
    end if;

  -- Set projectIds for builds where projectId is null
    UPDATE builds SET "projectId" = (SELECT "projectId" FROM resources WHERE id="resourceId") WHERE "projectId" IS NULL;

  -- Add projectId in buildJobs
    if not exists (select 1 from information_schema.columns where table_name = 'buildJobs' and column_name = 'projectId') then
      alter table "buildJobs" add column "projectId" varchar(24);
    end if;

  -- Set projectIds for buildJobs where projectId is null
    UPDATE "buildJobs" SET "projectId" = (SELECT "projectId" FROM builds WHERE id="buildJobs"."buildId") WHERE "projectId" IS NULL;

  -- Set projectId column of builds table set to not null
    if exists (select 1 from information_schema.columns where table_name = 'builds' and column_name = 'projectId') then
      alter table "builds" alter column "projectId" set not null;
    end if;

  -- Set projectId column of buildJobs table set to not null
    if exists (select 1 from information_schema.columns where table_name = 'buildJobs' and column_name = 'projectId') then
      alter table "buildJobs" alter column "projectId" set not null;
    end if;

  -- Remove vault systemIntegration
    delete from "systemIntegrations" where "name" = 'vault';

  -- Remove masterIntegrationFields for Vault
    delete from "masterIntegrationFields" where "masterIntegrationId"= (select id from "masterIntegrations" where "typeCode" = 5006 and
"name" = 'VAULT');

  -- Remove vault masterIntegration
    delete from "masterIntegrations" where "typeCode" = 5006 and "name" = 'VAULT';

  -- Rename systemConfigs.braintreeEnabled to systemConfigs.serverEnabled
    if exists (select 1 from information_schema.columns where table_name = 'systemConfigs' and column_name = 'braintreeEnabled') then
      alter table "systemConfigs" drop column "braintreeEnabled";
      alter table "systemConfigs" add column "serverEnabled" boolean NOT NULL DEFAULT true;
    end if;

  -- Update subscriptions to set "isCustomHost"=true
    UPDATE "subscriptions" SET "isUsingCustomHost" = true where "isUsingCustomHost" = false;

    -- username is no longer a required field for bitbucketServer account integrations
    update "masterIntegrationFields" set "isRequired" = false where "id" = 54;

    -- "port" is not a required field for github auth master integration
    update "masterIntegrationFields" set "isRequired" = false where "id" = 77;

    -- "port" is not a required field for bitbucket auth master integration
    update "masterIntegrationFields" set "isRequired" = false where "id" = 83;

    -- Remove braintree systemIntegration
    delete from "systemIntegrations" where "name" = 'braintree' and "masterType" = 'payment';

  -- Adds foreign key relationships for resources
    if not exists (select 1 from pg_constraint where conname = 'resources_subscriptionId_fkey') then
      alter table "resources" add constraint "resources_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'resources_subscriptionIntegrationId_fkey') then
      alter table "resources" add constraint "resources_subscriptionIntegrationId_fkey" foreign key ("subscriptionIntegrationId") references "subscriptionIntegrations"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'resources_projectId_fkey') then
      alter table "resources" add constraint "resources_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'resources_typeCode_fkey') then
      alter table "resources" add constraint "resources_typeCode_fkey" foreign key ("typeCode") references "systemCodes"(code) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for versions
    if not exists (select 1 from pg_constraint where conname = 'versions_subscriptionId_fkey') then
      alter table "versions" add constraint "versions_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'versions_projectId_fkey') then
      alter table "versions" add constraint "versions_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for jobDependencies
    if not exists (select 1 from pg_constraint where conname = 'jobDependencies_subscriptionId_fkey') then
      alter table "jobDependencies" add constraint "jobDependencies_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for buildJobs
    if not exists (select 1 from pg_constraint where conname = 'buildJobs_subscriptionId_fkey') then
      alter table "buildJobs" add constraint "buildJobs_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'buildJobs_projectId_fkey') then
      alter table "buildJobs" add constraint "buildJobs_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for buildJobConsoles
    if not exists (select 1 from pg_constraint where conname = 'buildJobConsoles_buildJobId_fkey') then
      alter table "buildJobConsoles" add constraint "buildJobConsoles_buildJobId_fkey" foreign key ("buildJobId") references "buildJobs"(id) on update restrict on delete restrict;
    end if;

  --Adds foreign key relationships for accountIntegrations
    if not exists (select 1 from pg_constraint where conname = 'accountIntegrations_accountId_fkey') then
      alter table "accountIntegrations" add constraint "accountIntegrations_accountId_fkey" foreign key ("accountId") references "accounts"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'accountIntegrations_providerId_fkey') then
      alter table "accountIntegrations" add constraint "accountIntegrations_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'accountIntegrations_masterIntegrationId_fkey') then
      alter table "accountIntegrations" add constraint "accountIntegrations_masterIntegrationId_fkey" foreign key ("masterIntegrationId") references "masterIntegrations"(id) on update restrict on delete restrict;
    end if;

  --Adds foreign key relationships for systemMachineImages
    if not exists (select 1 from pg_constraint where conname = 'systemMachineImages_systemIntegrationId_fkey') then
      alter table "systemMachineImages" add constraint "systemMachineImages_systemIntegrationId_fkey" foreign key ("systemIntegrationId") references "systemIntegrations"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for accountTokens
    if not exists (select 1 from pg_constraint where conname = 'accountTokens_accountId_fkey') then
      alter table "accountTokens" add constraint "accountTokens_accountId_fkey" foreign key ("accountId") references "accounts"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for accountProfiles
    if not exists (select 1 from pg_constraint where conname = 'accountProfiles_accountId_fkey') then
      alter table "accountProfiles" add constraint "accountProfiles_accountId_fkey" foreign key ("accountId") references "accounts"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'accountProfiles_providerId_fkey') then
      alter table "accountProfiles" add constraint "accountProfiles_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;

  --Adds foreign key relationships for systemIntegrations
    if not exists (select 1 from pg_constraint where conname = 'systemIntegrations_masterIntegrationId_fkey') then
      alter table "systemIntegrations" add constraint "systemIntegrations_masterIntegrationId_fkey" foreign key ("masterIntegrationId") references "masterIntegrations"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for projectPermissions
    if not exists (select 1 from pg_constraint where conname = 'projectPermissions_accountId_fkey') then
      alter table "projectPermissions" add constraint "projectPermissions_accountId_fkey" foreign key ("accountId") references "accounts"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'projectPermissions_providerId_fkey') then
      alter table "projectPermissions" add constraint "projectPermissions_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'projectPermissions_projectId_fkey') then
      alter table "projectPermissions" add constraint "projectPermissions_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'projectPermissions_subscriptionId_fkey') then
      alter table "projectPermissions" add constraint "projectPermissions_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for subscriptionIntegrations
    if not exists (select 1 from pg_constraint where conname = 'subscriptionIntegrations_subscriptionId_fkey') then
      alter table "subscriptionIntegrations" add constraint "subscriptionIntegrations_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'subscriptionIntegrations_accountIntegrationId_fkey') then
      alter table "subscriptionIntegrations" add constraint "subscriptionIntegrations_accountIntegrationId_fkey" foreign key ("accountIntegrationId") references "accountIntegrations"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for subscriptionPermissions
    if not exists (select 1 from pg_constraint where conname = 'subscriptionPermissions_accountId_fkey') then
      alter table "subscriptionPermissions" add constraint "subscriptionPermissions_accountId_fkey" foreign key ("accountId") references "accounts"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'subscriptionPermissions_providerId_fkey') then
      alter table "subscriptionPermissions" add constraint "subscriptionPermissions_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'subscriptionPermissions_subscriptionId_fkey') then
      alter table "subscriptionPermissions" add constraint "subscriptionPermissions_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  --Adds foreign key relationships for projects
    if not exists (select 1 from pg_constraint where conname = 'projects_providerId_fkey') then
      alter table "projects" add constraint "projects_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'projects_subscriptionId_fkey') then
      alter table "projects" add constraint "projects_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  --Adds foreign key relationships for projectDailyAggs
    if not exists (select 1 from pg_constraint where conname = 'projectDailyAggs_projectId_fkey') then
      alter table "projectDailyAggs" add constraint "projectDailyAggs_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'projectDailyAggs_subscriptionId_fkey') then
      alter table "projectDailyAggs" add constraint "projectDailyAggs_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for transactions
    if not exists (select 1 from pg_constraint where conname = 'transactions_accountId_fkey') then
      alter table "transactions" add constraint "transactions_accountId_fkey" foreign key ("accountId") references "accounts"(id) on update restrict on delete restrict;
    end if;
    if not exists (select 1 from pg_constraint where conname = 'transactions_subscriptionId_fkey') then
      alter table "transactions" add constraint "transactions_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for builds
    if not exists (select 1 from pg_constraint where conname = 'builds_subscriptionId_fkey') then
      alter table "builds" add constraint "builds_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'builds_projectId_fkey') then
      alter table "builds" add constraint "builds_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for clusterNodeStats
    if not exists (select 1 from pg_constraint where conname = 'clusterNodeStats_clusterNodeId_fkey') then
      alter table "clusterNodeStats" add constraint "clusterNodeStats_clusterNodeId_fkey" foreign key ("clusterNodeId") references "clusterNodes"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for clusterNodeConsoles
    if not exists (select 1 from pg_constraint where conname = 'clusterNodeConsoles_clusterNodeId_fkey') then
      alter table "clusterNodeConsoles" add constraint "clusterNodeConsoles_clusterNodeId_fkey" foreign key ("clusterNodeId") references "clusterNodes"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for jobConsoles
    if not exists (select 1 from pg_constraint where conname = 'jobConsoles_jobId_fkey') then
      alter table "jobConsoles" add constraint "jobConsoles_jobId_fkey" foreign key ("jobId") references "jobs"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for clusterNodes
    if not exists (select 1 from pg_constraint where conname = 'clusterNodes_subscriptionId_fkey') then
      alter table "clusterNodes" add constraint "clusterNodes_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'clusterNodes_statusCode_fkey') then
      alter table "clusterNodes" add constraint "clusterNodes_statusCode_fkey" foreign key ("statusCode") references "systemCodes"(code) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'clusterNodes_systemMachineImageId_fkey') then
      alter table "clusterNodes" add constraint "clusterNodes_systemMachineImageId_fkey" foreign key ("systemMachineImageId") references "systemMachineImages"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for jobTestReports
    if not exists (select 1 from pg_constraint where conname = 'jobTestReports_jobId_fkey') then
      alter table "jobTestReports" add constraint "jobTestReports_jobId_fkey" foreign key ("jobId") references "jobs"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for jobCoverageReports
    if not exists (select 1 from pg_constraint where conname = 'jobCoverageReports_jobId_fkey') then
      alter table "jobCoverageReports" add constraint "jobCoverageReports_jobId_fkey" foreign key ("jobId") references "jobs"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for jobs
    if not exists (select 1 from pg_constraint where conname = 'jobs_statusCode_fkey') then
      alter table "jobs" add constraint "jobs_statusCode_fkey" foreign key ("statusCode") references "systemCodes"(code) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'jobs_subscriptionId_fkey') then
      alter table "jobs" add constraint "jobs_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'jobs_projectId_fkey') then
      alter table "jobs" add constraint "jobs_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'jobs_runId_fkey') then
      alter table "jobs" add constraint "jobs_runId_fkey" foreign key ("runId") references "runs"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for runs
    if not exists (select 1 from pg_constraint where conname = 'runs_statusCode_fkey') then
      alter table "runs" add constraint "runs_statusCode_fkey" foreign key ("statusCode") references "systemCodes"(code) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'runs_projectId_fkey') then
      alter table "runs" add constraint "runs_projectId_fkey" foreign key ("projectId") references "projects"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'runs_providerId_fkey') then
      alter table "runs" add constraint "runs_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'runs_subscriptionId_fkey') then
      alter table "runs" add constraint "runs_subscriptionId_fkey" foreign key ("subscriptionId") references "subscriptions"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for providers
    if not exists (select 1 from pg_constraint where conname = 'providers_masterIntegrationId_fkey') then
      alter table "providers" add constraint "providers_masterIntegrationId_fkey" foreign key ("masterIntegrationId") references "masterIntegrations"(id) on update restrict on delete restrict;
    end if;

  -- Adds foreign key relationships for subscriptions
    if not exists (select 1 from pg_constraint where conname = 'subscriptions_providerId_fkey') then
      alter table "subscriptions" add constraint "subscriptions_providerId_fkey" foreign key ("providerId") references "providers"(id) on update restrict on delete restrict;
    end if;

    if not exists (select 1 from pg_constraint where conname = 'subscriptions_systemMachineImageId_fkey') then
      alter table "subscriptions" add constraint "subscriptions_systemMachineImageId_fkey" foreign key ("systemMachineImageId") references "systemMachineImages"(id) on update restrict on delete restrict;
    end if;

    -- Add systemRoles to accountTokens
    if not exists (select 1 from information_schema.columns where table_name = 'accountTokens' and column_name = 'systemRoles') then
      alter table "accountTokens" add column "systemRoles" text default '[]' NOT NUll;
    end if;

    -- Drop clusterNodes_jobId_fkey constraint from clusterNodes table
    if exists (select 1 from pg_constraint where conname = 'clusterNodes_jobId_fkey') then
      alter table "clusterNodes" drop constraint "clusterNodes_jobId_fkey";
    end if;

    -- Adds consolidateReports coloumn in projects table
    if not exists (select 1 from information_schema.columns where table_name = 'projects' and column_name = 'consolidateReports') then
      alter table "projects" add column "consolidateReports" BOOLEAN DEFAULT false;
    end if;

     -- Adds externalBuildId column in builds table
    if not exists (select 1 from information_schema.columns where table_name = 'builds' and column_name = 'externalBuildId') then
      alter table "builds" add column "externalBuildId" varchar(255);
    end if;

  end
$$;
