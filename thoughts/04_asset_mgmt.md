# Asset Management

Why is asset management (and User management/identities) so hard in Enterprises? Why is it so hard to have up-to-date, single source of the truth of what's on the network and who is doing what?


Actually I believe this is something beyond the scope of the SIEM itself but a crucial point for the Security department. I have tried multiple times to implement Asset management and a single source of truth in SIEM software itself (instead of outside) and it's always such a mess to get it "perfect" or just about "useable". From having to implement it several times for the same company in different enterprise SIEM softwares, I have come to believe that it's better to develop an in-house mini API or application that abstracts away the companies many sources of information and provide a simple way to get this up to date information towards the SIEM itself. It sure would have saved many hours of work.

Stuff you want from your asset list:
* All the names of the servers
* What OS are they running? Kernel information
* Patch information
* Vulnerability information

An asset list has also become more complex with the arrival of containerized environments where you no longer have static servers that stay for 4 years in a datacenter but short-lived containters that move from node to node, scale up and down, ...

Stuff you want from your user list:
* The users as known by the HR system: their name, department, contract start date, contract end date
* The users as known by the Active Directory: their Windows username, the groups they belong to, ...
* The other accounts of the same User: their privileged (admin) accounts which are linked to them, ...
* The other accounts in other systems like a Linux/Unix LDAP: if Linux users are outside of AD, you need to be able to know the state of these users as well
* Local accounts: If local application accounts are created (or local users) then we need to keep track of these. A local "nginx" user on system A is not the same "nginx" user as on system B. Compromise of one isn't a compromise of the other.
* Application accounts: The "users" that run applications and services on servers.
* Privileged accounts: Any other privileged accounts.
