# Lexical Analyzer using Flex

## Objective
This project implements a lexical analyzer using `lex/flex` to recognize different lexical components defined for the course. The analyzer will read an input file and identify tokens according to predefined lexical rules.

## Features
The lexical analyzer recognizes the following classes of lexical components:

| Class | Description |
|-------|-------------|
| 0 | Reserved words (see table) |
| 1 | Special symbols (see table) |
| 2 | Identifiers (must start with `@`, followed by letters, numbers, and `_`. It supports accented vowels and `ñ`, `Ñ`.) |
| 3 | Arithmetic operators (see table) |
| 4 | Relational operators (see table) |
| 5 | Assignment operators (see table) |
| 6 | String constants (enclosed in `--` and can contain any character) |
| 7 | Integer constants (cannot start with `0` if they have more than one digit, can have a `+` or `-` sign, and may include `p` or `g` as suffixes) |
| 8 | Real constants (fractional part is separated by `'` apostrophe, e.g., `12'2`, `242'87`. Alternatively, suffixes `r` or `R` can be used) |

## How It Works
- The lexical analyzer reads an input file containing source code.
- It identifies tokens based on regular expressions defined in the `lex/flex` file.
- Tokens are classified into different categories and stored in symbol and literal tables.
- Errors are detected and logged for debugging.
- Comments enclosed in `[ ]` are ignored by the analyzer.

## Token Representation
Each recognized token is represented by a structure containing:
- `class`: The lexical class number.
- `value`: The position within its corresponding table (for reserved words, symbols, operators) or the actual numerical value (for integer constants).

## Implementation Details
- The lexical analyzer creates a **symbol table** to store identifiers.
- **Literal tables** are used for string and floating-point constants.
- The analyzer continues processing even if errors are found, ensuring full lexical recognition.

## How to Run the Program
### Prerequisites
Make sure you have `flex` and `gcc` installed on your system. For macOS and Linux, you can install them with:
```sh
sudo apt install flex gcc    # For Debian-based systems
brew install flex           # For macOS (with Homebrew)
```

### Compilation and Execution
To compile and run the lexical analyzer, follow these steps:
```sh
make      # Generates the executable
./scanner.out input.txt  # Runs the scanner with an input file
```
Alternatively, if you want to manually compile:
```sh
flex -o scanner.c scanner.l
gcc -o scanner.out scanner.c -lfl
./scanner.out input.txt
```

### Expected Output
The program will display the recognized tokens along with their class and value.

### Example
#### Input File (`input.txt`)
```c
int x = 5;
float y = 3.14;
if (x > 0) {
   printf("Positive");
}
```
#### Output
```
PALABRA RESERVADA: int
IDENTIFICADOR: x
OPERADOR: =
NÚMERO ENTERO: 5
SÍMBOLO ESPECIAL: ;
PALABRA RESERVADA: float
IDENTIFICADOR: y
OPERADOR: =
NÚMERO REAL: 3.14
SÍMBOLO ESPECIAL: ;
PALABRA RESERVADA: if
SÍMBOLO ESPECIAL: (
IDENTIFICADOR: x
OPERADOR RELACIONAL: >
NÚMERO ENTERO: 0
SÍMBOLO ESPECIAL: )
...
```

## Error Handling
- If an unrecognized symbol is found, the program will display an error message and continue processing.
- If a string is not properly enclosed within `--`, it will be flagged as an error.
- If a number does not conform to the integer or real constant rules, it will also generate an error.

## Contributors
- List team members here

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.