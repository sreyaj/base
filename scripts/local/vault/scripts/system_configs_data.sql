do $$
  begin
    if not exists (select 1 from "systemConfigs") then
      insert into "systemConfigs" ("id", "defaultMinionCount", "defaultPipelineCount", "serverEnabled", "execImage", "buildTimeoutMS", "defaultPrivateJobQuota", "runMode", "amqpUrl", "amqpDefaultExchange", "amqpUrlAdmin", "amqpUrlRoot", "apiUrl", "wwwUrl", "apiPort", "serviceUserToken", "vaultUrl", "vaultToken", "vaultRefreshTimeInSec", "rootQueueList", "dynamicNodesSystemIntegrationId", "allowSystemNodes", "allowDynamicNodes", "allowCustomNodes", "createdAt", "updatedAt")
      values(1, 1, 1, true, 'shipimg/mexec:master.8917', 3600000, 150, 'dev', 'amqp://SHIPPABLETESTUSER:SHIPPABLETESTPASS@172.17.42.1:5672/shippable', 'shippableEx', 'http://SHIPPABLETESTUSER:SHIPPABLETESTPASS@172.17.42.1:15672', 'amqp://SHIPPABLETESTUSER:SHIPPABLETESTPASS@172.17.42.1:5672/shippableRoot', 'http://172.17.42.1:50000', 'http://172.17.42.1:50001', 50000, 'cc540ee6-1d2c-43a4-8413-39facb15fab9', 'http://172.17.42.1:8200','1d9a3f82-aea8-4434-6379-aeb58b02d500', 900,  'core.iscan|iscan.isync|iscan.esync|isync.autod|core.barge|barge.acs|barge.ddc|barge.dcl|barge.ebs|barge.ecs|barge.gke|barge.triton|core.charon|versions.trigger|core.nf|nf.email|nf.hipchat|nf.irc|nf.slack|nf.webhook|core.braintree|core.certgen|core.hubspotSync|core.marshaller|marshaller.ec2|core.sync|job.request|job.trigger|micro.ini|cluster.init|www.sockets|steps.deploy|steps.manifest|steps.rSync|core.jSync|steps.release|steps.runCI', '5745a34a25cf521200e83fe9', false, true, false, '2016-06-01', '2016-06-01');
    end if;
  end
$$;
