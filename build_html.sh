#!/bin/bash
INPUT=CV.pdf
OUTPUT_DIR=build/html
BASENAME=cv

mkdir -p "$OUTPUT_DIR"
pdftohtml -c -noframes "$INPUT" "$OUTPUT_DIR/$BASENAME"