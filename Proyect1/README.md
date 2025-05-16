# Lexical Analyzer

This project implements a lexical analyzer (scanner) created using Flex (Fast Lexical Analyzer Generator). The analyzer reads an input text file and generates three tables as output:

- Tokens (`tokens.txt`)
- Symbols (Identifiers) (`simbolos.txt`)
- Literals (strings and numeric constants): `literales.txt`

## 📂 Output Files
The analyzer produces three output files in Markdown format for easy viewing:

- **tokens.txt**: Contains a list of tokens found during lexical analysis, along with their token class and their position in the respective predefined tables.
- **simbolos.txt**: Lists identifiers (symbols) detected, their positions, and assigned types (default type is -1).
- **literales.txt**: Contains literals found (strings and numeric literals), along with their positions.

## 📋 Usage

1. **Compile** the lexical analyzer:

```bash
flex scanner.l
cc lex.yy.c -o scanner
```

2. Run the generated executable:

```bash
./a.out < input.txt
```

3. After running, you will find three Markdown files generated:

- `tokens.txt`
- `simbolos.txt`
- `literales.txt`

## ✅ Supported Tokens

The analyzer recognizes the following token classes:

| Class | Description                  |
|-------|----------------------------|
| 0     | Reserved keywords          |
| 1     | Special symbols            |
| 2     | Identifiers                |
| 3     | Arithmetic operators       |
| 4     | Relational operators  |
| 5     | Assignment operators  |
| 6     | String literals       |
| 7     | Integer literals      |
| 8     | Real literals         |
| 9     | Lexical errors        |

## ⚙️ How to Compile

Make sure you have **Flex** installed:

```bash
flex scanner.l
gcc lex.yy.c -o scanner
```

## 📁 Repository Structure

- `scanner.l`: Main Flex file containing the lexical rules and token definitions.
- `input.txt`: Example input file.
- Output Markdown files (`tokens.txt`, `simbolos.txt`, `literales.txt`) after execution.

## 🔗 Requirements

- Flex (Fast Lexical Analyzer Generator)
- C Compiler (gcc, clang, etc.)

## 📌 License

This project is open-source and freely available under the MIT license.