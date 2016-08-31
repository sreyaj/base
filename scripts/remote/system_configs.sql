create table if not exists "systemConfigs" (
  id INT  PRIMARY KEY NOT NULL,
  defaultMinionCount INT DEFAULT 1 NOT NULL,
  defaultPipelineCount INT DEFAULT 1 NOT NULL,
  braintreeEnabled BOOLEAN NOT NULL,
  cachingEnabled BOOLEAN DEFAULT TRUE NOT NULL,
  hubspotEnabled BOOLEAN DEFAULT TRUE NOT NULL,
  buildTimeoutMS INT DEFAULT 3600000 NOT NULL,
  defaultPrivateJobQuota INT DEFAULT 150 NOT NULL,
  serviceUserToken VARCHAR(36) NOT NULL,
  vaultUrl VARCHAR(255) NOT NULL,
  vaultToken VARCHAR(45) NOT NULL,
  vaultRefreshTimeInSec INT NOT NULL,
  createdBy VARCHAR(24) NOT NULL,
  updatedBy VARCHAR(24) NOT NULL
);
alter table "systemConfigs" owner to "apiuser";
