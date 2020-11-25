# Pigeons
Pigeons hopes at some point to become a message (i.e. event) handling library
and accompanying programming tool (keyboard optional). Lisp is the glue.

## What does it do?
Right now it logs incoming messages (key/encoder, MIDI) to the screen.
There are some hard-coded configuration to: 
- "Lens" an Octatrack's input (more on that later)
- Display a menu

As it stabilizes and matures, it might be able to:
- Route/translate/process MIDI messages, with programmatic logic
- Send and receive CV with crow
- Sequence stuff
- Build message routing layers for norns apps 

## OK, what can I use it for right now?
It's a MIDI monitor! And with lensing, the monitoring is actually useful
instead of a big stream of meaningless numbers.

If you want to get your hands dirty and mess with the code, you can actually
use it to do some basic MIDI tasks right now with the Lisp as it is. However,
none of this is documented so you'll have to fumble your way through with the
meager examples and this source code. Hopefully that is coming soon. In the
mean time, good luck, and don't be shy about reporting issues!

## What is lensing?
Well, in the larger community, it's a functional programming concept. I
probably misunderstood what it's actually supposed to be, but I liked the
idea as I interpreted it. Anyway, my interpretation is that you have a sort
of two-way converter or translator. 

On one side of the conversion, you have raw MIDI messages that by themselves
mean almost nothing: your notes, your CCs, your program changes, etc. On the
other side, you have a specification for these messages that a device speaks
and understands, and specifically what they mean to that device. You know,
the stuff that used to appear in the back of the manual from some point in
the 1980s to some point in the 2010s, and still does sometimes.

So what does this do for you? Well, in the case of the Octatrack, instead of
saying "CC #48", we can just say "crossfader". In theory, this makes
scripting (and logging) more intuitive because you can call parameters in a
more meaningful way instead of needing a cheat sheet to look up the numbers.

At the moment, this is implemented for the MIDI input (which should be the
harder half, I think) but not for the MIDI output.

## Why Lisp?
Lisp's syntax is minimal. In theory, this means expressions can be written
and modified without text input.

In practice, who knows? MIDI learn will probably help.
