
# NAME

SIEM.pl - A simple SIEM (Security Information and Event Monitoring)

# SYNOPSIS

    use SIEMpl;

# DESCRIPTION

SIEM.pl is a simple and straightforward implementation of a SIEM system.

The problem I'm facing with running cheap virtual private servers in the Cloud is that I have no way to monitor the system, with relatively little resources, for security problems or even for application monitoring. Most solutions for event monitoring nowadays except several GBs of memory to run stable or they require you to buy their SaaS solutions and send all your events to this 3rd party. Something I'm also not in favour of.

So why not build a small, simple SIEM solution that runs locally and just does the important bits?

## Technical implementation strategy

SIEM implementations are generally always the same. You have an ingestion layer which receives the data ("PUSH"ed data) or collects it (DB connections, file reading, == "PULL"ed data). The ingestion layer will then do some parsing and send it of to the storage layer where it's stored in a "efficient" way (indexes, column-based storage, ...). Then there is a querying layer that uses a query received from a User and looks it up against the storage layer. This layer is then extended to also allow scheduled queries so you can perform lookups 24/7 against your data. And finally, they have a nice UI (actually most SIEMs have a very bad UI for doing actual work, they mostly look nice...).

SIEM.pl does the following:
* Ingestion layer: We don't ingest any data, the data that we query is stored on the filesystem and managed by other tools in terms of log rotation etc. In the case of Apache logs, you configure the Apache Web server to write its access and error logs to a file (/var/log/apache/ for example) and configure logrotate to do the rotation and size management of these files. SIEM.pl can be configured to read those files at query time but SIEM.pl does not "ingest" these files and store them in another way.
* Storage layer: We do not have a storage layer. Albeit future versions might do caching, indexing, ... storing of the log files is externally managed (by the OS, logrotate, ...) 
* Querying layer: SIEM.pl provides a SQL-like query language so that you don't have to learn new things to get started. SIEM.pl uses cron for scheduling queries. Before querying the
* UI layer: SIEM.pl has a CLI interface and an efficient Web interface. 

# LICENSE

Copyright (C) Adriaan.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Me, myself and I.
