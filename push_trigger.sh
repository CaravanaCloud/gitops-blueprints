#!/bin/bash

echo . >> trigger.txt
git commit -am "Trigger $(date '+%d/%m/%Y %H:%M:%S')"
git push
