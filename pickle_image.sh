#!/bin/bash

set -e

URL="$1"
PICKLE_JAR="pickle_jar.jpg"

curl -s "$URL" \
    | convert - -resize 75x75 \
	      \( +clone +matte -fill green -colorize 100% \
	      +clone +swap -compose overlay -composite \) \
	      -compose SrcIn -composite - \
    | composite -gravity center - $PICKLE_JAR png:-
