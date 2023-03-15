#!/bin/bash

POSITIONAL_ARGS=()

function help(){
    cat << help_eof 
    "Usage: sample.sh -e, -s, -d"
help_eof
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--extension)
      EXTENSION="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--searchpath)
      SEARCHPATH="$2"
      shift # past argument
      shift # past value
      ;;
    -d|--default)
      DEFAULT=YES
      shift # past argument
      ;;
    -h|--help)
      help
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

echo "FILE EXTENSION  = ${EXTENSION}"
echo "SEARCH PATH     = ${SEARCHPATH}"
echo "DEFAULT         = ${DEFAULT}"
