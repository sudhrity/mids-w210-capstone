#!/bin/bash
k6 run  --summary-trend-stats="min,med,avg,max,p(90),p(95),p(99)" load.js
