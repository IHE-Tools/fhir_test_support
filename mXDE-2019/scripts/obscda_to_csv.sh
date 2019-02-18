#!/bin/sh

java -jar ../lib/saxon9he.jar -o:$1.csv $1.xml ../xsl/cda_to_observations.xsl
