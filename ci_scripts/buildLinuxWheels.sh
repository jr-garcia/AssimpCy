#!/usr/bin/env bash

if [$BUILDWHEELS=="True"]
then
  pip install cibuildwheel==0.7.0
  cibuildwheel --output-dir wheelhouse
else
  exit 0;
fi