# Enbycat
read your files in a really queer way
## functionality
./enbycat [FILES] -t [THICKNESS] -c [COLORFILE]

by default it uses regular rgb color pallet and line thickness of 1

if you provide no files stdin will be read instead

## color files
just files with color hex codes separated by ; or a newline

example files are: enby.txt, pan.txt, bi.txt

you might as well make your own ones if you want it

## building
```sh
odin build .
```
or
```sh
odin build . -o:aggressive
```
to enable aggressive optimizations which might or might not break it

## notes

might break on some files with tab stops i think

do not actually use seriously it just colorfully displays files

lorem.txt is an example file for reading

## qa
q: it sucks?

a: yes

q: why is it in odin

a: i wanted to try it out

q; why is it named enby cat

a: thats who i am

q: why not rust

a: you are not being funny