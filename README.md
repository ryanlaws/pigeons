# Pigeons
Pigeons hopes at some point to become a message (i.e. event) handling library
and accompanying programming tool. Lisp is the glue.

## What does it do?
Right now? It just logs incoming messages (key/encoder, MIDI) to the screen.

As it stabilizes and matures, it might be able to:
- Route/translate/process MIDI messages, with programmatic logic
- Send and receive CV with crow
- Sequence stuff
- Build message routing layers for norns apps 

## Why Lisp?
Lisp's syntax is minimal. In theory, this means expressions can be written
and modified without text input.

In practice, who knows? MIDI learn will probably help.

## OK, what can I use it for right now?
It's a MIDI monitor!