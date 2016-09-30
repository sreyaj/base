create or replace function set_route_permission(
  httpVerb varchar, routePattern varchar, type varchar, allowedRoles text,
  roleCode int, isPublic boolean, isSuperUser boolean)

  returns void as $$
  declare
    db_allowed_role text;
  begin

    -- insert if not exists
    if not exists (select 1 from "routePermissions"
      where "httpVerb" = httpVerb and
        "routePattern" = routePattern and
        -- temp fix to avoid multiple entries for null roleCode (true-> update, false->insert)
        ("roleCode" = roleCode OR "roleCode" IS NULL)
    ) then
      insert into "routePermissions" ("httpVerb", "routePattern", "type",
        "allowedRoles", "roleCode", "isPublic", "isSuperUser", "createdAt", "updatedAt")
      values (httpVerb, routePattern, type,
        allowedRoles, roleCode, isPublic, isSuperUser, now(), now());
      return;
    end if;

  -- update allowedRoles
    update "routePermissions"
    set "allowedRoles" = allowedRoles, "roleCode" = roleCode, "isPublic" = isPublic, "isSuperUser" = isSuperUser
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
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser", "public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser", "public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser", "public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/dependencies',
      type := 'account',
      allowedRoles := '["justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/sync',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/sync',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/tokens',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/syncPaymentProvider',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accounts/:id/generateSSHKeys',
      type := 'account',
      allowedRoles := '["justUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/auth/:systemIntegrationId/link',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/auth/:systemIntegrationId/link',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/offline',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:id',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set accountCards routePermissions

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id/dependencies',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountCards/:id/dependencies',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set accountIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountIntegrations/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set accountProfiles routePermissions

    perform set_route_permission(
      routePattern := '/accountProfiles',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountProfiles',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/accountProfiles/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set accountTokens routePermissions

    perform set_route_permission(
      routePattern := '/accountTokens',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accountTokens/:id',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set betaUsers routePermissions

    perform set_route_permission(
      routePattern := '/betaUsers',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/betaUsers',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/betaUsers/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set buildJobs routePermissions

    perform set_route_permission(
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobs/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set buildJobConsoles routePermissions

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/buildJobConsoles/:buildJobId',
      type := 'buildConsole',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set builds routePermissions

    perform set_route_permission(
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/builds/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set clusterNodes routePermissions

    perform set_route_permission(
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/validate',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/validate',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/validate',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/initScript',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/initScript',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/initScript',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/status',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/status',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/status',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/triggerDelete',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/triggerDelete',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/triggerDelete',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set clusterNodeConsoles routePermissions

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeConsoles',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set clusterNodeStats routePermissions

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats/:id',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats/:id',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodeStats/:id',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/clusterNodes/:id/clusterNodeStats',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set dailyAggs routePermissions

    perform set_route_permission(
      routePattern := '/dailyAggs',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/dailyAggs',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/dailyAggs/:id',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set jobConsoles routePermissions

    perform set_route_permission(
      routePattern := '/jobConsoles',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobConsoles',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobConsoles',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:id/postConsoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:id/postConsoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:id/postConsoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId/consoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId/consoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId/consoles',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set jobCoverageReports routePermissions

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports/:id',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports/:id',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports/:id',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobCoverageReports',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set job routePermissions

    perform set_route_permission(
      routePattern := '/jobs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobs/:jobId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set jobDependencies routePermissions

    perform set_route_permission(
      routePattern := '/jobDependencies',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobDependencies',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobDependencies/:id',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobDependencies/:id',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    -- set jobTestReports routePermissions

    perform set_route_permission(
      routePattern := '/jobTestReports',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports/:id',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports/:id',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports/:id',
      type := 'build',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/jobTestReports',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    -- set masterIntegrationFields routePermissions

    perform set_route_permission(
      routePattern := '/masterIntegrationFields',
      type := 'account',
      allowedRoles := '["justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    -- set masterIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/masterIntegrations',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/masterIntegrations',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set passthrough routePermissions

    perform set_route_permission(
      routePattern := '/passthrough/systemIntegrations/:id/machines',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/passthrough/systemIntegrations/:id/keyPairs',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/passthrough/accountIntegrations/:accountIntegrationId/repos/:owner/:repo/:branch',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/passthrough/accountIntegrations/:accountIntegrationId/jenkins/:jobName/builds',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set payments routePermissions

    perform set_route_permission(
      routePattern := '/payments/clienttoken',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/payments/clienttoken',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/payments/clienttoken',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set plans routePermissions

    perform set_route_permission(
      routePattern := '/plans',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/plans',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/plans',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set projects routePermissions

    perform set_route_permission(
      routePattern := '/projects',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:id/validOwner',
      type := 'project',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projects/:id/validCollaborator',
      type := 'project',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/sync',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/sync',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/sync',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/postScm',
      type := 'project',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/reset',
      type := 'project',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/reset',
      type := 'project',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/disable',
      type := 'project',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/disable',
      type := 'project',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/enable',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/enable',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/enable',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/newBuild',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/newBuild',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/newBuild',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId',
      type := 'project',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set projectDailyAggs routePermissions

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs/:id',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectDailyAggs/:id',
      type := 'account',
      allowedRoles := '["opsUser","superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set projectAccounts routePermissions

    perform set_route_permission(
      routePattern := '/projectAccounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectAccounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectAccounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectAccounts',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectAccounts/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set projectPermissions routePermissions

    perform set_route_permission(
      routePattern := '/projectPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projectPermissions/scmPerm',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/projectPermissions/:id',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := true
    );

    -- set providers routePermissions

    perform set_route_permission(
      routePattern := '/providers',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/providers',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/providers/:id',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set resources routePermissions

    perform set_route_permission(
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/dependencies',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/dependencies',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/dependencies',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/syncRepo',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/syncRepo',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/syncRepo',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/resources/:id/files',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set runs routePermissions

    perform set_route_permission(
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:accountId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:accountId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/accounts/:accountId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/runStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/branchRunStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/branchRunStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/projects/:projectId/branchRunStatus',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId/cancel',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId/cancel',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId/cancel',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/runs/:runId',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set subscriptionAccounts routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptionAccounts/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set subscriptions routePermissions

    perform set_route_permission(
      routePattern := '/subscriptions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/postScm',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/reset',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/reset',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/billing',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId/billing',
      type := 'account',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId',
      type := 'subscription',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId',
      type := 'subscription',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:subscriptionId',
      type := 'subscription',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/initializeQueues',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/destroyQueues',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/encrypt',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/encrypt',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/encrypt',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/decrypt',
      type := 'account',
      allowedRoles := '["justUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/state',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/state',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/state',
      type := 'account',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptions/:id/issues',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set subscriptionIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'PUT',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrations/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set subscriptionIntegrationPermissions routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionIntegrationPermissions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set subscriptionPermissions routePermissions

    perform set_route_permission(
      routePattern := '/subscriptionPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions/scmPerm',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/subscriptionPermissions/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set superUsers routePermissions

    perform set_route_permission(
      routePattern := '/superUsers',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/superUsers',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/superUsers/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemCodes routePermissions

    perform set_route_permission(
      routePattern := '/systemCodes',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemCodes',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemCodes',
      type := 'account',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := true,
      isSuperUser := false
    );

    -- set systemConfigs routePermissions

    perform set_route_permission(
      routePattern := '/systemConfigs',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemImages routePermissions

    perform set_route_permission(
      routePattern := '/systemImages',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemImages',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemImages/:id',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemIntegrations routePermissions

    perform set_route_permission(
      routePattern := '/systemIntegrations',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemIntegrations/:id/dependencies',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemMachineImages routePermissions

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemMachineImages',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemNodes routePermissions

    perform set_route_permission(
      routePattern := '/systemNodes',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/initScript',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/validate',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/status',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/triggerDelete',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      type := 'foo',
      allowedRoles := '["owner","collaborator","justUser","opsUser","superUser","serviceUser","public"]',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := true,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id',
      type := 'foo',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemNodeConsoles routePermissions

    perform set_route_permission(
      routePattern := '/systemNodeConsoles',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodeConsoles',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/systemNodeConsoles',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemNodeStats routePermissions

    perform set_route_permission(
      routePattern := '/systemNodeStats',
      type := 'account',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodeStats',
      type := 'account',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/systemNodes/:id/systemNodeStats',
      type := 'account',
      allowedRoles := '["superUser","serviceUser"]',
      httpVerb := 'DELETE',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set systemProperties routePermissions

    perform set_route_permission(
      routePattern := '/systemProperties',
      type := 'foo',
      allowedRoles := '["superUser"]',
      httpVerb := 'GET',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set transactions routePermissions

    perform set_route_permission(
      routePattern := '/transactions/:id',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions/:id',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions/:id/receipt',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions/:id/receipt',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions',
      type := 'transaction',
      allowedRoles := '["justUser","owner"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/transactions',
      type := 'transaction',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/transactions/:id',
      type := 'transaction',
      allowedRoles := '["superUser"]',
      httpVerb := 'PUT',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    -- set versions routePermissions

    perform set_route_permission(
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'POST',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator","freeUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6010,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/versions/:id',
      type := 'foo',
      allowedRoles := '["justUser","owner","collaborator"]',
      httpVerb := 'DELETE',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    -- set vortex routePermissions

    perform set_route_permission(
      routePattern := '/vortex',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'POST',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/vortex',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'POST',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/vortexSU',
      type := 'account',
      allowedRoles := '["superUser"]',
      httpVerb := 'POST',
      roleCode := null,
      isPublic := false,
      isSuperUser := true
    );

    perform set_route_permission(
      routePattern := '/vortex',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'GET',
      roleCode := 6000,
      isPublic := false,
      isSuperUser := false
    );

    perform set_route_permission(
      routePattern := '/vortex',
      type := 'account',
      allowedRoles := '["owner","justUser"]',
      httpVerb := 'GET',
      roleCode := 6020,
      isPublic := false,
      isSuperUser := false
    );

  end
$$;
