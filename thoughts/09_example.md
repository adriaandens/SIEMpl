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
* In a distributed system, you can have late arrivals. If you're running a query on the last hour but the data source is running half an hour behind (due to load issues, ...) then you have queried data that was not complete. Apache Beam has the concept of marker events that "mark" whether a time period is complete or not. Queries should run on complete time slices.

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
