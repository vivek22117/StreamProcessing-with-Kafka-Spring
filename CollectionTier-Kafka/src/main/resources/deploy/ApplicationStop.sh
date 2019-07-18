#!/usr/bin/env bash

echo 'application stop script starting....'

if pgrep java;
    then sudo pkill java;
fi
