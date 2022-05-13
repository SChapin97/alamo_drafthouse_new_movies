#!/bin/sh

THEATRE_ID="2501" #Woodbury
URL="https://feeds.drafthouse.com/adcService/showtimes.svc/calendar/$THEATRE_ID/"
JSON_OUTPUT="woodbury.json"
CURRENT_LIST="current_movie_list.txt"
OLD_LIST="previous_movie_list.txt"

:> "$JSON_OUTPUT"
curl "$URL" 2> /dev/null 1> "$JSON_OUTPUT"

if [ -s "$JSON_OUTPUT" ]; then
    sed 's/"FilmName":/~/g' "$JSON_OUTPUT" | tr '~' '\n' | grep -v '{"Calendar":' | awk -F '"' '{print $2}' | sort | uniq > "$CURRENT_LIST"

    if [ -s "$OLD_LIST" ]; then
        #Compare current to old movie list, find list of new movies.
        new_movies=$(comm -23 "$CURRENT_LIST" "$OLD_LIST")

        if [ -n "$new_movies" ]; then
            echo "New movies at the alamo drafthouse:"
            echo "$new_movies"
        else
            echo "There are no new movies at the alamo drafthouse compared to last run."
        fi
        mv "$CURRENT_LIST" "$OLD_LIST"
    else
        echo "New movies at the alamo drafthouse:"
        cat "$CURRENT_LIST"
        mv "$CURRENT_LIST" "$OLD_LIST"
    fi

fi
