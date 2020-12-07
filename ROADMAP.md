# Roadmap 
- [x] Working Lisp (without real S-expression parsing)
- [x] Event handling (norns controls, MIDI)
- [x] Event monitoring (simple)
- [x] MIDI output
- [x] Poor man's sexpr load
- [ ] Poor man's sexpr save (not useful w/o editing)
(POINT OF MVP USEFULNESS)
- [ ] Persistent display of control values, not just logging
- [ ] Real sexpr persistence
- [x] Real sexpr parsing
- [x] Mode-level environments (via forking)
- [ ] Event recording (technically already possible... sorta)
- [x] Event filtering (can be done with plisp)
- [ ] Scheduling (sequencing, delay, throttle, etc.)
- [ ] Event handling (crow, app-level events)
- [ ] Expression editing

## Event recording
This will be useful for "MIDI learn" functionality as well as sequencing.

## Event filtering
Not a priority at the moment. Will make learning and monitoring more useful.

## Scheduling (sequencing, delay, throttle, etc.)
This is essential for sequencing. Obviously, some kind of clock will be
involved.

## Real S-expression parsing and persistence
This seems essential, but simple tables might suffice for MVP. The norns core
libraries already provide ways of persisting these.

## Event handling (crow, app-level events)
Not a priority at the moment.

## Mode-level Environments
Currently there are 2 types of environments: global and event-level. An
intermediate level, which is persistent like global, but which can be
switched as needed, would help with:
- Menus
- Listener assignments
- Connected gear state (e.g. CCs, port assignments)

Note that this would work pretty much exactly like closures. In fact, it
might be more flexible, because you can swap them out per-expression.

At surface level, this doesn't seem difficult to implement. Existing
metatable-based environment inheritance should already go most of the way.
The only other big problem I can think of is managing these environments. It
might be enough to just name them and store the names somewhere. This could
be like a SQL "system table" which contains data about the other tables.

## Expression editing
(Let's not for MVP... too much work, not enough payoff)
There isn't a way to edit expressions yet. This could turn into a real rabbit
hole. Hooking up a keyboard and just parsing and validating expression
strings seems like the most reasonable and time-tested method here.

But that goes against the main design goal of progressive enhancement.
Hardware dependencies only come into play by connecting hardware to the
system. So they become capabilities as much as dependencies.

### Norns limitations
#### Controls
We are limited, at least as a starting point, to the onboard norns controls.
Three encoders and three buttons/keys, one of which must be held briefly in
order to trigger it, making it mostly useful as a "control" or "meta" key,
i.e. in combination with other keys.

But there are a decent number of combinations between those keys. For
example, you may press K2 and do something, or hold K2 and then press K3 to
do another thing. And then holding K3 and pressing K2 might do yet another
thing. And of course K3 by itself does another thing. That's 4 combinations
just within 2 keys. And there's still a 3rd key.

The most obvious way to alter expressions would be to scroll through a list
of options. For that approach, the list had better be small. Context could
help limit the size of this list - types are an obvious way to help with
this. For example, only display operators that return booleans in positions
that require booleans. However, the expressions will likely be awkward to
create with this constraint. It is likely necessary to allow expressions to
be in an invalid state while writing them. After all, code is in an invalid
state most of the time while it's being written.

#### Display
The norns has a small display. It can't display big strings. But you can do
some things to fix this:
- Use shorter strings for operators
- Break long lines into shorter lines
- Other stuff?
