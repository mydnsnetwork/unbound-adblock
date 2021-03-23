# mydns.network: unbound-adblock

adblock.mydns.network is a ad-blocking, privacy preserving DNS resolver. No logging, no adverts, globally accessible and available. For free. For all.

## How it works
unbound-adblock is a caching forwarding resolver designed to forward queries to an upstream recursive resolver and performing permissive blocking actions. When a query for a hostname listed is received, unblock-unbound will respond with false A/AAAA records, causing connections to immediately fail.

These records are **0.0.0.0** (A) and **0100::** (AAAA). These addresses and their usage can be seen in [RFC5735](https://tools.ietf.org/html/rfc5735) and [RFC6666](https://tools.ietf.org/html/rfc6666)