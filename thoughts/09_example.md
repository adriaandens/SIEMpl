# A worked out example

Since SIEMpl is something that's mostly in my head at this point in time, I think there's benefit for myself to writing down a simple example end-to-end both in London style as in Chigago style.

## Starting from the outside (London)

As someone who owns multiple VPSs and also runs some Linux machines around the house (including my desktop) I want to be able to monitor my systems for weird behaviour. For this example let's say I want to monitor my external services for logins that succeeded from outside of Belgium where I live since I don't expect other people logging on to my VPS, nor to several of my external facing websites.

A possible query that would match this behaviour is:

```
SELECT username as TargetAccount, server as TargetDevice, source_ip as ActorDevice, location_country as Country FROM SuccessfulAuthentications WHERE location_country != 'BE';
```

Things to note at query time:
* Nginx logs only contain IPs but no locations. So we need to use a database like MaxMind to find the country to which the IP belongs. But just as our assets can change IP so can IP blocks in the world also change from owner to owner. As such, we need to take care that if we lookup data from months ago, that we match it to a MaxMind DB from that same era.

We can run this query in SIEMpl and see if there are any matching entries. But we cannot run this manually every day, we need a scheduled query functionality that allows us to say: "Run this query every hour on the data of the last hour".

Things to note for scheduling:
* We expect no gaps in querying: if a query executes every hour and the next query 1 hour and 2 seconds later (because scheduling reasons;..) then we might miss 2 seconds if we do "-3600 seconds from now()".
* In a distributed system, you can have late arrivals. If you're running a query on the last hour but the data source is running half an hour behind (due to load issues, ...) then you have queried data that was not complete. Apache Beam has the concept of marker events that "mark" whether a time period is complete or not. Queries should be ble to run on complete time slices (maybe configurable by the user to match expectations, you don't expect this for queries in the UI or you might not care about this).

Once the query has run, the results need to be mapped to a Risk Based scheme. These are standard names to indicate the Actor (also called "source" or "attacker"), meaning the person of device performing the action and the Target (device, account, resource, ...). Above I mapped it already to the correct names but if that's not done then there should be the possibility of mapping to the Risk based fields later on. Additionally there needs to be an indication of the Actor Action taken, for example "AccessAccount" and its result (ActorActionResult) being successful or failure.

Dropping into the query scheduler, the query needs to be translated into actions taken on the system to look up the data. The naive approach is to start reading all the data sources that are defined, parse all the logs, and then find entries matching the query of the end user.

Optimizations:
* At the start of SIEMpl, we ask each parser to get metadata about the current data on disk. This can be very simple metadata like the first timestamp and last timestamp of a file and a checksum (to see if the file has changed when the query is ran) which can already filter down on what files contain events in the timerange of the query.
* Write an inverted index, ...

If the query had results, we can show the results (paginated) on the screen in a table. If the query was run as a scheduled query, we write the incident to disk in a dedicated file containing all information about the query run, the time it ran, the time range, the results including all entities involved.

Things to note: When we write the incident file it's best to write all the information to disk. Since the events might be rotated away (with logrotate) within a short timeframe. Also the entities like devices and actors involved are best to be written to disk because assets and users are also not static (devices can change name or ip, users can join or leave)

When the User visits the SIEMpl interface, they can look at all the incidents and find the relevant information back. 

Extra:
* Something I would like is to make sure that all queries ran, so information about all the query runs would be nice metadata (so we can verify there are no gaps in the data) This would be configurable in SIEMpl so you can write this metadata to disk and then have a datasource to read in this information as any other log.

## Starting from the inside (Chigago)

We start from the log files on disk. Let's take the nginx access log as an easy example.

The idea is that you can configure SIEMpl with a config file in the /etc/ directory on which files to read, what parser to use and other options (each parser can have their own config parameters).

Something like:
```
[nginx_access_logs]
file_path=/var/log/nginx/access*
parser=SIEMpl::Parser::NginxAccess

```

By defining the Parser you can easily write your own parser for any custom log. Each Parser is a subclass of the SIEMpl::Parser. It's the Parsers responsibility to parse a file, database, receive data on a network connection, query APIs, ... and convert the received data into "Events".  

Besides Events, it can also emit Objects and Markers.

Objects are used in Graph queries, and they relate to the devices, users, resources, ... and can be created by a Parser if they don't exist yet in the Graph.

Besides Events and Objects, it can emit Markers. Markers let the system know timeranges are complete. The Parser has the best knowledge whether late arrivals are still possible or not and can define when all events for a certain range are read/received.

In a simple example, a log like nginx that runs locally will normally also write logs chronologically and thus when you see a new hour as a timestamp you can emit a marker that all events for the previous hour have been read. This gives guarantees for higher level components like queries, dashboards, ... and can add warnings that data is not complete (same for scheduled queries). Note that besides "ending" markers (end of a minute, quarter, hour), we also need begin markers so that if you begin in a certain (because that's the first line in an hour) then that hour is not complete by reading that file.

Once the parser has read the data source and has some completed Events, Markers and Objects, it can push them to the central in-memory database and graph.

The "database" is a Singleton that will store all the events. When a query is run, it queries this database or iterates it.


To not have a giant permanent in-memory database on each server and machine that you own, SIEMpl at start time will only get metadata (or Markers?) about each of the files in scope. For the nginx files it would record (for each file) the earliest timestamp and latest timestamp, it also records a hash or checksum or filesize of the file to know if the file changed and the "earliest"/"latest" timestamps have become invalid. You basically end up with a hash looking like:

```
{
	"/var/log/nginx/access.1.log": {
		"earliest": <epoch>,
		"latest": <epoch>,
		"filesize": 1234,
		"hash_first_bytes": <abcdefhash>
	},
	"/var/log/nginx/access.2.log": { ... }
}

```

If the file just grows or gets appended to the filesize will become different and the latest date will change but the hash might stay the same. Consider now what happens if logrotate starts moving files: deleting the oldest one and then renaming all the files to make place for a new file. This would mean that "access.1.log" becomes "access.2.log" suddenly... Important is thus that when a query is run, we first have to get this metadata (and thus launch many Parsers) and the parsers that match the timerange/query can effectively start parsing and sending events to the database for the query results.


Note: How can we make the parsers concurrent?

Of course if we want to have the query engine tell the parsers what events are of interest that means the Parser needs to be given this information by the query engine at query time. Then the parser can determine "i have events for you or not". And each parser will do this until all parsers have run and all events have been collected.

Once all the events are collected in the in-memory database, the query engine can perform any necessary filters, group by's, selects, orders, limits, ...


<talk about scheduled queries, daemons, web interfaces, ...>


