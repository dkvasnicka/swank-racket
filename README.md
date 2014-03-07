swank-racket
============

This is a Swank server for the Racket programming language (formerly PLT Scheme).

Swank server is what gives you an interactive Lisp/Scheme environment when working with SLIME (Emacs) or SLIMV (Vim).

### Status & limitations

- Only tested with Vim & SLIMV - Emacs & SLIME testers needed!
- Basically the only thing working right now is evaluation

### Howto

Developed using Racket 5.9.x / 6.0. I'm not aware of any 6.0-specific things in the code though, so it should run just fine with 5.3.x. 

Run `racket server.rkt` to get the thing up and running.