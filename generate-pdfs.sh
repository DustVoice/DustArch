#!/bin/sh
asciidoctor-pdf -a pdf-page-size=a4 -o Documentation_A4.pdf Documentation.adoc
asciidoctor-pdf -a pdf-page-size=a5 -o Documentation_A5.pdf Documentation.adoc
