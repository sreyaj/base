create or replace function set_route_permission(
  httpVerb varchar, routePattern varchar,
  roleCode int, isPublic boolean, isSuperUser boolean)

  returns void as $$
  begin

    -- insert if not exists
    if not exists (select 1 from "routePermissions"
      where "httpVerb" = httpVerb and
        "routePattern" = routePattern and
        -- temp fix to avoid multiple entries for null roleCode (true-> update, false->insert)
        ("roleCode" = roleCode OR "roleCode" IS NULL)
    ) then
      insert into "routePermissions" ("httpVerb", "routePattern",
        "roleCode", "isPublic", "isSuperUser", "createdAt", "updatedAt")
      values (httpVerb, routePattern,
        roleCode, isPublic, isSuperUser, now(), now());
      return;
    end if;

  -- update
    update "routePermissions"
    set "roleCode" = roleCode, "isPublic" = isPublic, "isSuperUser" = isSuperUser
    where "httpVerb" = httpVerb and
    "routePattern" = routePattern and
    ("roleCode" = roleCode OR "roleCode" IS NULL);

    return;
  end
$$ LANGUAGE plpgsql;

do $$
  begin

    -- set accounts routePermissions

    perform set_route_permission(
      routePattern := '/accounts',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/sync',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/sync',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/tokens',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/syncPaymentProvider',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/generateSSHKeys',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/auth/:systemIntegrationId/link',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/auth/:systemIntegrationId/link',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/offline',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set accountCards routePermissions

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set accountIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set accountProfiles routePermissions

    perform set_route_permission(
      routePattern := '/accountProfiles',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountProfiles',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accountProfiles/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set accountTokens routePermissions

    perform set_route_permission(
      routePattern := '/accountTokens',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set betaUsers routePermissions

    perform set_route_permission(
      routePattern := '/betaUsers',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/betaUsers',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/betaUsers/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set buildJobs routePermissions

    perform set_route_permission(
      routePattern := '/buildJobs',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set buildJobConsoles routePermissions

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set builds routePermissions

    perform set_route_permission(
      routePattern := '/builds',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set clusterNodes routePermissions

    perform set_route_permission(
      routePattern := '/clusterNodes',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/validate',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/validate',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/validate',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/initScript',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/initScript',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/initScript',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/status',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/status',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/status',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/triggerDelete',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/triggerDelete',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/triggerDelete',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set clusterNodeConsoles routePermissions

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set clusterNodeStats routePermissions

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeStats',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeStats',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeStats',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set dailyAggs routePermissions

    perform set_route_permission(
      routePattern := '/dailyAggs',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/dailyAggs',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/dailyAggs/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set jobConsoles routePermissions

    perform set_route_permission(
      routePattern := '/jobConsoles',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobConsoles',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobConsoles',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:id/postConsoles',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:id/postConsoles',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:id/postConsoles',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId/consoles',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId/consoles',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId/consoles',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set jobCoverageReports routePermissions

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set job routePermissions

    perform set_route_permission(
      routePattern := '/jobs',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set jobDependencies routePermissions

    perform set_route_permission(
      routePattern := '/jobDependencies',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobDependencies',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobDependencies/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobDependencies/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    -- set jobTestReports routePermissions

    perform set_route_permission(
      routePattern := '/jobTestReports',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    -- set masterIntegrationFields routePermissions

    perform set_route_permission(
      routePattern := '/masterIntegrationFields',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    -- set masterIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/masterIntegrations',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/masterIntegrations',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set passthrough routePermissions

    perform set_route_permission(
      routePattern := '/passthrough/systemIntegrations/:id/machines',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/passthrough/systemIntegrations/:id/keyPairs',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/passthrough/accountIntegrations/:accountIntegrationId/repos/:owner/:repo/:branch',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/passthrough/accountIntegrations/:accountIntegrationId/jenkins/:jobName/builds',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set payments routePermissions

    perform set_route_permission(
      routePattern := '/payments/clienttoken',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/payments/clienttoken',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/payments/clienttoken',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set plans routePermissions

    perform set_route_permission(
      routePattern := '/plans',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/plans',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/plans',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set projects routePermissions

    perform set_route_permission(
      routePattern := '/projects',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:id/validOwner',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projects/:id/validCollaborator',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/sync',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/sync',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/sync',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- Changing the roleCode to a different value won't update the existing row
    -- rather add a new row, so add a delete query in migrations.sql
    perform set_route_permission(
      routePattern := '/projects/postScm',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/reset',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/reset',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/disable',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/disable',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/enable',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/enable',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/enable',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/newBuild',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/newBuild',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/newBuild',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set projectDailyAggs routePermissions

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs/:id',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set projectAccounts routePermissions

    perform set_route_permission(
      routePattern := '/projectAccounts',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectAccounts',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectAccounts',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectAccounts',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectAccounts/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set projectPermissions routePermissions

    perform set_route_permission(
      routePattern := '/projectPermissions',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectPermissions',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectPermissions',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectPermissions/scmPerm',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectPermissions/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := true
    );

    -- set providers routePermissions

    perform set_route_permission(
      routePattern := '/providers',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/providers',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set resources routePermissions

    perform set_route_permission(
      routePattern := '/resources',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/syncRepo',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/syncRepo',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/syncRepo',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set runs routePermissions

    perform set_route_permission(
      routePattern := '/runs',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:accountId/runStatus',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:accountId/runStatus',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:accountId/runStatus',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/branchRunStatus',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/branchRunStatus',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/branchRunStatus',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId/cancel',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId/cancel',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId/cancel',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set subscriptionAccounts routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set subscriptions routePermissions

    perform set_route_permission(
      routePattern := '/subscriptions',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/postScm',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/reset',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/reset',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/billing',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/billing',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/initializeQueues',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/destroyQueues',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/encrypt',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/encrypt',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/encrypt',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/decrypt',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/state',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/state',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/state',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/issues',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set subscriptionIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id/dependencies',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set subscriptionIntegrationPermissions routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set subscriptionPermissions routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionPermissions',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions/scmPerm',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set superUsers routePermissions

    perform set_route_permission(
      routePattern := '/superUsers',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/superUsers',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/superUsers/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemCodes routePermissions

    perform set_route_permission(
      routePattern := '/systemCodes',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemCodes',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemCodes',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    -- set systemConfigs routePermissions

    perform set_route_permission(
      routePattern := '/systemConfigs',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemImages routePermissions

    perform set_route_permission(
      routePattern := '/systemImages',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemImages',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemImages/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/systemIntegrations',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id/dependencies',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemMachineImages routePermissions

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemNodes routePermissions

    perform set_route_permission(
      routePattern := '/systemNodes',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/initScript',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/validate',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemNodes',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/status',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/triggerDelete',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemNodeConsoles routePermissions

    perform set_route_permission(
      routePattern := '/systemNodeConsoles',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodeConsoles',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/systemNodeConsoles',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemNodeStats routePermissions

    perform set_route_permission(
      routePattern := '/systemNodeStats',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodeStats',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/systemNodeStats',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemProperties routePermissions

    perform set_route_permission(
      routePattern := '/systemProperties',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set transactions routePermissions

    perform set_route_permission(
      routePattern := '/transactions/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions/:id/receipt',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions/:id/receipt',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/transactions/:id',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set versions routePermissions

    perform set_route_permission(
      routePattern := '/versions',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set vortex routePermissions

    perform set_route_permission(
      routePattern := '/vortex',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/vortex',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/vortexSU',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/vortex',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/vortex',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

  end
$$;
