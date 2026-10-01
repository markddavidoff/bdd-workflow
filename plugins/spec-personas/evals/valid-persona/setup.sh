#!/usr/bin/env bash
# Pre-create a non-hidden personas dir so the (interactive) skill neither asks where to save nor
# writes under a dot-dir the grader glob would skip.
mkdir -p personas
