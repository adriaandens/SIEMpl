
# Faster parsing

Since we are not storing any index or cache of the raw logs, we need to make sure that the performance doesn't suffer of the SIEM.

Ideas:
* Can we make sure to use the OS file cache? And make sure that if no other process needs the memory, those files stay mapped?
* If we're talking about just a few GBs of logs, do we even need to think about optimizing?
* Can we give parsers the information or filters from the query in order for them to make use of this? The most simple example is time related. If we're querying the last 24 hours of data, then the parser does not need to parse any further than the timestamp to know if it's applicable. File based parsers with a classic structure can check the first line and last line for a timestamp to know the timerange of the entire file. If the query's timerange is outside of this, then we don't need to parse anything from that file.
* Related to the above: Can we enable or disable Graph based objects if it's not relevant to the query? And vice versa for the table data (if someone wants a graph query, no need for Events)
