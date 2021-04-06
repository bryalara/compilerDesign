Compile code:
    lex lex.l
    gcc lex.yy.c

To run code: ./a.out <inputfile.txt>
    ./a.out zinc.txt
    ./a.out test.txt
    
zinc.txt is the original example file given and out put matches expected.
test.txt has some error handling case and outputs are handled properly aswell. The error list is printed at the end for ease of feedback to user.


In the lex.l file, I created a Symbol Table structure that stores all symbols created in a linked list format. 

The add_symbol function takes arguments: Desired symbol table pointer, char pointer to symbol string, and a check used to make sure the identifier beening added is not a mistaknely generated identifier by user misputting type integer, this case is handle and out putted to error list.

The search_symbol takes in argument of char pointer of symbol string desired. This is used to validate identifier tokens have been declared properly. Also outputted through error list if not declared peroperly. The function looks through Symbol_table and returns Symbol_table pointer of specified symbol once found. Else return null pointer and adds error to error list.

Finally there is the print_ST that neatly prints the symbol table to the ouput called after lex finished matching all patterns.

I also created an Error_list structure that is base of a linked list to easily keep track of errors and is outputted at the end. 

Error_list has 2 functions: add_error that takes in a string and adds it to the linked list of error strings. and print_EL to easily print all errors called end of output.

Variable  used to handle special cases. The special case currently implemented are for errors, adding new line with at the end of semicolons or end of newlines matched, ignoring comments, and making sure symbols are declared properly.


