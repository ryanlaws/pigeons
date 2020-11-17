# TODO
- [ ] Implement MIDI output handlers
- [ ] Flatten message structure (nesting is yucky)
- [ ] Implement UI
    - [ ] Menus
    - [ ] Visual (keyboard-free) expression editor
    - [ ] Message "learn" (like MIDI learn)
- [ ] Add debug mode
- [ ] Refactor for library usage
    - [ ] Do not reference other modules via globals
    - [ ] Messages and lisp MAY be useful separately (?)
- [ ] Implement message throttling
- [ ] Refactor everything to use Lisp as much as possible
- [ ] Real Lisp
    - [ ] Persist expressions as strings
    - [ ] Parse strings into expressions 

# DONE
- [x] Implement MIDI inputs -> messages
- [x] Norns screen log (text-only for now)
    - [x] Log incoming messages
    - [x] Log handlers - NAH, not now, I don't think this will work
    - [x] BONUS - cute "index" animation
    - [x] Show log messages with actual info
- [x] Create environment/context for each event
- [x] Split into modules
    - [x] lib (core)
        - [x] Messages
        - [x] Lisp
        - [x] Utils
        - [x] Core

