#!/bin/bash

echo publisher:$PASS | chpasswd

supervisord -n