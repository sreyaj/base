## State file

- The installer stores all the installation-specific data in a file `usr/state.json`. The following values are saved in the file
  - machine configuration
  - installed status of components like `postgres`, `rabbitmq` etc
  - initialization status of components
  - list of enabled master integrations
  - list and configuration of system integrations
  - configuration and state of microservices 
  - list and configuration of running microservices
  - system configuration variables

- This file should **Only** be edited under following conditions  
  - the installer explicitly prompts for some configuration update and exits. e.g. this happens when the aws secret and access keys are
    not provided in the system settings. The installer needs the keys to pull Shippable microservice images. Hence it cannot proceed
    unless the keys are present
  - The installer is behaving in unexpected manner and a Shippable team member is helping out with troubleshooting

- The file `usr/state.json.example` acts as a template for filling in the state file.
  - The template has all the `masterIntegrations` and `systemIntegrations` for reference.
  - The `systemIntegrations` array in example state file has dummy values that can be replaced with
required values when the `systemIntegrations` are enabled in state file.

- During the first run (using `--install` option), the installer creates the state file by copying `usr/state.json.example` to `usr/state.json`.
  - after creating the state file, installer removes all the configurations and settings from it. These are filled in later in the workflow 
    based on user input and by parsing machine configuration 
  - for any subsequent installer runs (using `--release` option), the installation and configuration of core components (db, message queue etc)
    is skipped. The decision to skip/run is made based on flags in the state file corresponding to each component.
