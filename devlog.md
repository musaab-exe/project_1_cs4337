# Dev Log - CS4337 Project 1

---

## 2025-02-27 7:30 PM

First session. Read through the project spec. So basically I need to make a prefix notation calculator in Racket. I've used Racket a little bit in class but not a ton so this might take a while.

The main things I need to do:
- parse prefix expressions like +*2$1+$2 1
- keep a history so you can reference old results with $n
- interactive and batch mode
- handle errors without crashing

My plan is to parse the expression character by character since whitespace is optional between tokens. I'll write a function that takes a list of chars and returns the evaluated value plus whatever chars are left over.

Going to start coding tonight.

---

## 2025-02-28 2:30 PM

Coded up the basic structure. Got +, *, /, and numbers working. I messed up the - operator and made it binary subtraction instead of unary negation. Also completely forgot about the $n history thing. Also I realized I'm not checking if there's leftover text after the expression, so like +1 2 2 would incorrectly succeed. Will fix next session.

Committing what I have.

---

## 2025-02-28 7:30 PM

New session. Goals for tonight:
- Fix - to be unary negation
- Add $n history lookup
- Add leftover text check

Thoughts since last time: the history is stored newest-first because I'm using cons. So when I do $n lookup I need to reverse the list first before indexing. That tripped me up.

---

## 2025-02-28 11:00 PM

Fixed the unary minus and added the leftover text check. Added $n too but I have a bug - I'm indexing into the history without reversing it first, so $1 gives the most recent result instead of the first result. Also still forgot to add the divide by zero check. Ugh.

Committing this version anyway to show progress.

---
