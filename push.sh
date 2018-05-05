#!/bin/bash

main() {
  git add -A
  git status
  git commit -v -m "$@"
  git push -u origin master
} && [[ -z "$@" ]] && main "$@" || main "Version bump"