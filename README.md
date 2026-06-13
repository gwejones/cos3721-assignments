# COS3721 - Operating Systems and Architecture

## Purpose

To acquaint students with general operating system functionality such as CPU scheduling, process coordination and concurrency, deadlocks, memory management, protection and security. It also covers the case of distributed systems.

## Build Assignment 2

Generate all PlantUML diagrams from the `.puml` sources in `assets/` with:

```sh
plantuml -tsvg assets/*.puml
```

Compile the Typst source to PDF with:

```sh
typst compile assignment2.typ assignment2.pdf
```

Run the PlantUML command again whenever a `.puml` file changes or a new diagram source is added. The generated `.svg` files can then be included from Typst.
