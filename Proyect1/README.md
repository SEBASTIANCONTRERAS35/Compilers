Here’s a complete and concise GitHub-ready README for your Lexer Project:

⸻

Lexer Analyzer (Flex) 🚀

This is a lexical analyzer (lexer) built using Flex, designed to identify and classify tokens from a given input source. It generates structured output across three separate files:
	•	✅ Tokens Table (tokens.txt)
	•	✅ Symbols (Identifiers) Table (simbolos.txt)
	•	✅ Literals Table (literales.txt)

📖 Project Overview

This project categorizes tokens according to predefined lexical classes. Identifiers and literals are dynamically stored, while reserved words, symbols, and operators have predefined positions in dedicated tables.

⸻

📌 Token Classes

Class	Token Type
0	Reserved Words
1	Special Symbols
2	Identifiers
3	Arithmetic Operators
4	Relational Operators
5	Assignment Operators
6	String Literals
7	Integer Literals
8	Real Literals
9	Lexical Errors



⸻

📝 Example Input

Bool @myVar_ sum 45p --Hello World-- Flota

🔍 Lexer Output Example
	•	tokens.txt

===== TABLA DE TOKENS =====
| Clase | Posición   |
|------------------|
| 0     | 0          |
| 2     | 0          |
| 3     | 0          |
| 7     | 0          |
| 6     | 0          |
| 0     | 6          |
==========================

	•	simbolos.txt

===== TABLA DE SÍMBOLOS (IDENT) =====
| Pos   | Nombre          | Tipo  |
|--------------------------------|
| 0     | @myVar_         | -1    |
================================

	•	literales.txt

===== TABLA DE LITERALES =====
| Pos   | Valor           |
|-----------------------|
| 0     | 45p             |
| 1     | --Hello World-- |
=======================



⸻

🚩 Getting Started

🔧 Installation

Ensure you have Flex installed. For Linux/macOS:

sudo apt-get install flex  # Ubuntu/Debian
brew install flex          # macOS (Homebrew)

🚀 Compilation & Execution
	1.	Clone this repository:

git clone <your-github-repo-url>
cd lexer-project

	2.	Compile the lexer:

flex scanner.l
gcc lex.yy.c -o lexer

	3.	Run the lexer:

./lexer < input.txt

The outputs will be stored in:
	•	✅ tokens.txt
	•	✅ simbolos.txt
	•	✅ literales.txt

⸻

🧰 Project Structure

lexer-project/
├── scanner.l
├── input.txt
├── tokens.txt
├── simbolos.txt
└── literales.txt



⸻

📦 Technologies
	•	C
	•	Flex (Fast Lexical Analyzer)

⸻

📝 Contributing

Contributions, improvements, and suggestions are welcome!
	1.	Fork this repository 🍴
	2.	Create your feature branch (git checkout -b feature/new-feature)
	3.	Commit your changes (git commit -am 'Add some feature')
	4.	Push to the branch (git push origin feature/new-feature)
	5.	Open a Pull Request 🎉

⸻

📄 License

This project is licensed under the MIT License.

⸻

Made with ❤️ by Your Sebastian Contreras