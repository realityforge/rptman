## TODO

### Declared Configurations

Currently the tool guesses the configurations and attempts to map them to
environments. However if we want a "staging" configuration there is no easy
way to have the BI project files created with this configuration. So the tool
should be updated so that the user can configure the mapping between
configurations and keys used in the config file and the options for configuration
(i.e. Just build or build and deploy).

### Make it possible to overide the set of root paths that are updated

Useful if you want to only update certain subtrees with different rake tasks.
i.e. IRIS/Firetimes is one tree managed independently, IRIS/Coordination is
another etc. Each can be uploaded independently but should never overlap.
