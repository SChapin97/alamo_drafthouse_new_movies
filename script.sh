#!/bin/sh

THEATRE_ID="2501" #Woodbury
URL="https://feeds.drafthouse.com/adcService/showtimes.svc/calendar/$THEATRE_ID/"
JSON_OUTPUT="woodbury.json"
CURRENT_LIST="current_movie_list.txt"
OLD_LIST="previous_movie_list.txt"

:> "$JSON_OUTPUT"
curl -31kL "$URL" 2> /dev/null 1> "$JSON_OUTPUT"

if [ -s "$JSON_OUTPUT" ] && [ $(file "$JSON_OUTPUT" | grep -c 'HTML document') -eq 0 ]; then

    sed 's/"FilmName":/~/g' "$JSON_OUTPUT" | tr '~' '\n' | grep -v '{"Calendar":' | awk -F '"' '{print $2}' | sort | uniq > "$CURRENT_LIST"

    # If no movies (RIP Woodbury Alamo Drafthouse -- July 2018 - May 2023)
    if [ ! -s "$CURRENT_LIST" ]; then
        :> "$JSON_OUTPUT"
        rm "$CURRENT_LIST"
        exit 1
    fi

    if [ -s "$OLD_LIST" ]; then
        #Compare current to old movie list, find list of new movies.
        new_movies=$(comm -23 "$CURRENT_LIST" "$OLD_LIST")

        if [ -n "$new_movies" ]; then
            echo "New movies at the alamo drafthouse:"
            echo "$new_movies"
        fi
        mv "$CURRENT_LIST" "$OLD_LIST"
    else
        echo "New movies at the alamo drafthouse:"
        cat "$CURRENT_LIST"
        mv "$CURRENT_LIST" "$OLD_LIST"
    fi
else
    echo "ERROR IN GRABBING THE JSON OUTPUT FROM THE ALAMO CALENDAR API"
fi

:> "$JSON_OUTPUT"
