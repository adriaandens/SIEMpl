# TDD

My experience with building custom parsers for enterprise logs has been one of many frustrations. One of the frustrations is the development loop of creating (complex) parsers for logs. They're just a very slow development cycle in all the SIEMs I have worked with.

When using ArcSight, you're restricted by using very limited functions and a very strict Java properties file format. ArcSight is (or was in v6) also very obscure when you wanted to create custom parsers and the information online isn't really good either.

When I made Splunk parsers, the format was a tad better but it quickly become annoying to know where a parser was failing, which transform rules were causing the problem, etc. Furthermore I was frustrated that I couldn't really have a TDD (Test Driven Development) approach to locally iterate quickly and run 100s of tests to make sure nothing broke when I'm changing a part of the parser.

I actually went as far as implementing a TDD framework for Splunk parsers in Rust somewhere during the covid pandemic (my excuse for learning rust back then) but I switched jobs before I finished the framework and Splunk became irrelevant to me.

But the thought remained: Why don't SIEMs offer a quick development cycle for creating parsers? Where I can make changes to parsers and confidently say "this will not break half of the log parsing in production" by running test suites?


