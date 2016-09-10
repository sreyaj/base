create or replace function set_route_permission(
  httpVerb varchar, routePattern varchar, type varchar, allowedRoles text)
  returns void as $$
  declare
    db_allowed_role text;
  begin

    -- insert if not exists
    if not exists (select 1 from "routePermissions" where "httpVerb" = httpVerb and "routePattern" = routePattern) then
       insert into "routePermissions" ("httpVerb", "routePattern", "type", "allowedRoles", "createdAt", "updatedAt")
       values (httpVerb, routePattern, type, allowedRoles, now(), now());
       return;
    end if;

    -- update if exists and allowedRoles is changed

    -- get allowedRoles present in db
    select "allowedRoles" into db_allowed_role from "routePermissions"
    where "httpVerb" = httpVerb and "routePattern" = routePattern;

    -- update allowedRoles if it differs in db and script
    if db_allowed_role != allowedRoles then
      update "routePermissions" set "allowedRoles" = allowedRoles
      where "httpVerb" = httpVerb and "routePattern" = routePattern;
    end if;

    return;
  end
$$ LANGUAGE plpgsql;

do $$
  begin

    -- set accounts routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser", "public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accounts/:id/dependencies',
      type := 'account',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accounts/:id/sync',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accounts/:id/tokens',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accounts/:id/syncPaymentProvider',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accounts/:id/generateSSHKeys',
      type := 'account',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accounts/auth/:systemIntegrationId/link',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accounts/offline',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

    -- set accountCards routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountCards/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountCards',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/accountCards/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accountCards',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountCards/:id/dependencies',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    -- set accountIntegrations routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    -- set accountProfiles routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountProfiles',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accountProfiles',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/accountProfiles/:id',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set accountTokens routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountTokens',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accountTokens/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/accountTokens',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/accountTokens/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    -- set buildJobs routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set buildJobConsoles routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/buildJobConsoles',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set builds routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set clusterNodes routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/clusterNodes/:id/validate',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/clusterNodes/:id/initScript',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/clusterNodes/:id/status',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/clusterNodes/:id/triggerDelete',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    -- set clusterNodeConsoles routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set clusterNodeStats routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/clusterNodeStats/:id',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set dailyAggs routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/dailyAggs',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/dailyAggs',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/dailyAggs/:id',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]'
    );

    -- set jobConsoles routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/jobConsoles',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/jobs/:id/postConsoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/jobs/:jobId/consoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set jobCoverageReports routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/jobCoverageReports/:id',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set job routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/jobs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/jobs',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set jobDependencies routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/jobDependencies',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/jobDependencies',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/jobDependencies/:id',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/jobDependencies/:id',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    -- set jobTestReports routePermissions

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/jobTestReports',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/jobTestReports/:id',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/jobTestReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    -- set masterIntegrationFields routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/masterIntegrationFields',
      type := 'account',
      allowedRoles := '["justUser"]'
    );

    -- set masterIntegrations routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/masterIntegrations',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    -- set passthrough routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/passthrough/systemIntegrations/:id/machines',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/passthrough/systemIntegrations/:id/keyPairs',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/passthrough/accountIntegrations/:accountIntegrationId/repos/:owner/:repo/:branch',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set payments routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/payments/clienttoken',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set plans routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/plans',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set projects routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projects',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projects/:id/validOwner',
      type := 'project',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projects/:id/validCollaborator',
      type := 'project',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projects/:projectId/sync',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projects/postScm',
      type := 'project',
      allowedRoles := '["superUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projects/:projectId/reset',
      type := 'project',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projects/:projectId/disable',
      type := 'project',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projects/:projectId/enable',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projects/:projectId/newBuild',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set projectDailyAggs routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projectDailyAggs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projectDailyAggs/:id',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projectDailyAggs',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/projectDailyAggs/:id',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]'
    );

    -- set projectPermissions routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projectPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/projectPermissions/scmPerm',
      type := 'account',
      allowedRoles := '["superUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/projectPermissions/:id',
      type := 'account',
      allowedRoles := '["superUser","owner"]'
    );

    -- set providers routePermissions

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/providers',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/providers',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/providers/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/providers/:id',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    -- set resources routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/resources/:id/dependencies',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/resources/syncRepo',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/resources/:id/files',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/resources/:id/files',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set runs routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/accounts/:accountId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/projects/:projectId/branchRunStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/runs/:runId/cancel',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    -- set subscriptions routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptions/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptions/postScm',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptions/:id/reset',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptions/:subscriptionId/billing',
      type := 'account',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/subscriptions/:subscriptionId',
      type := 'subscription',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptions/:id/initializeQueues',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptions/:id/destroyQueues',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptions/:id/encrypt',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptions/:id/decrypt',
      type := 'account',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptions/:id/state',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptions/:id/issues',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set subscriptionIntegrations routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptionIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set subscriptionIntegrationPermissions routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/subscriptionIntegrationPermissions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set subscriptionPermissions routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/subscriptionPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/subscriptionPermissions/scmPerm',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/subscriptionPermissions/:id',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set systemCodes routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemCodes',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]'
    );

    -- set systemConfigs routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemConfigs',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    -- set systemImages routePermissions

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/systemImages',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemImages',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/systemImages/:id',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    -- set systemIntegrations routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemIntegrations',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/systemIntegrations',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/systemIntegrations/:id',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemIntegrations/:id',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/systemIntegrations/:id',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set systemMachineImages routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemMachineImages',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemMachineImages/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/systemMachineImages',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set systemProperties routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/systemProperties',
      type := 'foo',
      allowedRoles := '["superUser"]'
    );

    -- set transactions routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/transactions/:id',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/transactions/:id/receipt',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/transactions',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/transactions',
      type := 'transaction',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'PUT',
      routePattern := '/transactions/:id',
      type := 'transaction',
      allowedRoles := '["superUser"]'
    );

    -- set versions routePermissions

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    perform set_route_permission(
      httpVerb := 'DELETE',
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]'
    );

    -- set vortex routePermissions

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/vortex',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

    perform set_route_permission(
      httpVerb := 'POST',
      routePattern := '/vortexSU',
      type := 'account',
      allowedRoles := '["superUser"]'
    );

    perform set_route_permission(
      httpVerb := 'GET',
      routePattern := '/vortex',
      type := 'account',
      allowedRoles := '["owner","justUser"]'
    );

  end
$$;
