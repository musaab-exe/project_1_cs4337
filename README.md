# CS4337 Project 1 - Prefix Calculator

## Files

- `calculator.rkt` - the main program
- `devlog.md` - development log

## How to Run

Interactive mode:
```
racket calculator.rkt
```

Batch mode:
```
racket calculator.rkt -b
racket calculator.rkt --batch
```

Batch mode with input file:
```
racket calculator.rkt -b < inputfile.txt
```

## Supported Expressions

| Syntax | Description |
|--------|-------------|
| `42` | any non-negative integer |
| `+a b` | add two expressions |
| `*a b` | multiply two expressions |
| `/a b` | integer divide (divide by zero is an error) |
| `-a` | negate an expression (unary, not subtraction) |
| `$n` | recall history result number n |

Expressions are prefix notation. Whitespace between tokens is optional.

## Example Session
```
> 5
1: 5.0
> 3
2: 3.0
> +$1 $2
3: 8.0
> quit
```

## Notes

- Type `quit` to exit
- Invalid expressions print `Error: Invalid Expression`
- History ids start at 1 and never reset