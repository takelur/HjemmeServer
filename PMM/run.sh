#!/bin/bash

# Spør bruker om versjonsvalg for kjøring av container
echo "Velg versjonen du vil kjøre:"
echo "s: Stable (latest)"
echo "n: Nightly"
echo "d: Develop"
echo "u: Update"
read -p "Skriv inn valg (s/n/d/u): " user_choice

# Kjøre den korresponderende kommandoen til brukerinput
case $user_choice in
    s)
        # Stable versjon
        docker run --rm -it -v "./config:/config:rw" meisnate12/plex-meta-manager --run
        ;;
    n)
        # Nightly versjon
        docker run --rm -it -v "./config:/config:rw" meisnate12/plex-meta-manager:nightly --run
        ;;
    d)
        # Develop versjon
        docker run --rm -it -v "./config:/config:rw" meisnate12/plex-meta-manager:develop --run
        ;;
    u)
        # Spørring for oppdatering av container
        echo "s: Stable (latest)"
        echo "n: Nightly"
        echo "d: Develop"
        echo "a: Alle"

        read -p "Skriv inn valg (s/n/d/a): " user_choice

        case $user_choice in
            s)
                docker pull meisnate12/plex-meta-manager
                ;;
            n)
                docker pull meisnate12/plex-meta-manager:nightly
                ;;
            d)
                docker pull meisnate12/plex-meta-manager:develop
                ;;
            a)
                docker pull meisnate12/plex-meta-manager
                docker pull meisnate12/plex-meta-manager:nightly
                docker pull meisnate12/plex-meta-manager:develop
                ;;
            *)
                echo "Valget er ikke akseptert. Vennligst kjør skriptet igjen og følg instruksene"
                ;;
        esac

        ;;

    *)
        echo "Valget er ikke akseptert. Vennligst kjør skriptet igjen og følg instruksene"
        ;;
esac
