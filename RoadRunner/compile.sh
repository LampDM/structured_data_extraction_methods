#!/bin/bash

fnd="find . -type f -name '*.swift'"
files=$(eval "$fnd")
swiftc $files -o main