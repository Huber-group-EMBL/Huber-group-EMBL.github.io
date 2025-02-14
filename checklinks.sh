#!/bin/bash
wget --spider -r -nd -nv -l 5 -o wget.log https://www.huber.embl.de/group/index.html

# also follow external links:
wget --spider -r -nd -nv -l 1 -H -o wget.log https://www.huber.embl.de/group/index.html
