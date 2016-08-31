do $$
  begin
    if not exists (select 1 from "systemConfigs") then
      insert into "systemConfigs" ("id", "defaultMinionCount", "defaultPipelineCount", "braintreeEnabled", "buildTimeoutMS", "defaultPrivateJobQuota", "serviceUserToken", "vaultUrl", "vaultToken", "vaultRefreshTimeInSec", "createdBy", "updatedBy", "createdAt", "updatedAt")
      values(1, 1, 1, false, 3600000, 150,  '3f957c4c-d33d-4ca1-946c-5391765c381b', 'http://172.17.42.1:8200', '1d9a3f82-aea8-4434-6379-aeb58b02d500', 900, '540e7735399939140041d885', '540e7735399939140041d885', '2016-06-01', '2016-06-01');
    end if;
  end
$$;
