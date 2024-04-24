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
        docker run --rm -it -v "./config:/config:rw" kometateam/kometa --run
        ;;
    n)
        # Nightly versjon
        docker run --rm -it -v "./config:/config:rw" kometateam/kometa:nightly --run
        ;;
    d)
        # Develop versjon
        docker run --rm -it -v "./config:/config:rw" kometateam/kometa:develop --run
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
                docker pull kometateam/kometa
                ;;
            n)
                docker pull kometateam/kometa:nightly
                ;;
            d)
                docker pull kometateam/kometa:develop
                ;;
            a)
                docker pull kometateam/kometa
                docker pull kometateam/kometa:nightly
                docker pull kometateam/kometa:develop
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
