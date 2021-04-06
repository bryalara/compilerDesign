%{
#include <stdio.h>
#include <string.h>    

int num_lines= 1;
int num_output_lines=1;
int semi_newline=0;
int error=0;
int symbols=0;
int comment=0;
char buffer[1024];
int symbol_valid = 0;
int symbol_type = 0;
char* curr_sym;
char* curr_type;
struct Symbol_table{
    struct Symbol_table* next_Symbol;
    char* symbol_value;
    char sym_type[8];
} ST;
struct Symbol_table *sym_table = &ST;
void add_symbol(struct Symbol_table *st, char* ch, int check);
struct Symbol_table* search_symbol(struct Symbol_table *st, char* ch);
void print_ST();

struct Error_list{
    struct Error_list* next_error;
    char* error_text;
} EL;
struct Error_list *err_list = &EL;
void add_error(struct Error_list *el, char* ch);
void print_EL();
%}

NUM     [0-9]
ID      [a-zA-Z][a-zA-z0-9]*

%%

\n+         {if(semi_newline==1){semi_newline=0;} else if(error == 0 && comment==0) {printf("\n");num_output_lines++;} if(error==1)error=0;else comment=0; num_lines+=yyleng;}
[ \t]+       ;
%+.*        {comment=1;}//{printf( "<COMMENT,_> " );}
program     {printf( "<PROGRAM,_> " );}
;           {if(error==0)printf( "<SC,_> " ); if(symbol_valid==1) symbol_valid=0; symbol_type=0; if(error == 0 && comment==0){printf("\n");semi_newline=1;num_output_lines++;}  } 
:=          {if(error==0)printf( "<ASGN,_> " );}
"("         {if(error==0)printf( "<LP,_> " );}
")"         {if(error==0)printf( "<RP,_> " );}
:           {if(error==0)printf( "<AS,_> " ); symbol_type=1;}
integer     {if(error==0)printf( "<INT,_> " );}
var         {if(error==0)printf( "<VAR,_> " );  symbol_valid=1;}
begin       {if(error==0)printf( "<BEGIN,_> " );}
end         {if(error==0)printf( "<END,_> \n" ); }
readInt     {if(error==0)printf( "<READINT,_> " );}
writeInt    {if(error==0)printf( "<WRITEINT,_> " );}
while       {if(error==0)printf( "<WHILE,_> " );}
endwhile    {if(error==0)printf( "<ENDWHILE,_> " );}
if          {if(error==0)printf( "<IF,_> " );}
then        {if(error==0)printf( "<THEN,_> " );}
else        {if(error==0)printf( "<ELSE,_> " );}
endif       {if(error==0)printf( "<ENDIF,_> " );}
or          {if(error==0)printf( "<OR,_> " );}
not         {if(error==0)printf( "<NOT,_> " );}
and         {if(error==0)printf( "<AND,_> " );}
"<="        {if(error==0)printf( "<COMPARE,\"<=\"> " );}
"="         {if(error==0)printf( "<COMPARE,\"=\"> " );}
"<>"        {if(error==0)printf( "<COMPARE,\"<>\"> " );}
"<"         {if(error==0)printf( "<COMPARE,\"<\"> " );}
">"         {if(error==0)printf( "<COMPARE,\">\"> " );}
">="        {if(error==0)printf( "<COMPARE,\">=\"> " );}
do          {if(error==0)printf( "<DO,_> " );}
"**"        {if(error==0)printf( "<POWER,\"**\"> " );}
"*"         {if(error==0)printf( "<MULTIPLICATIVE,\"*\"> " );}
"+"         {if(error==0)printf( "<ADDITIVE,\"+\"> " );}
"-"         {if(error==0)printf( "<ADDITIVE,\"-\"> " );}
"div"       {if(error==0)printf( "<MULTIPLICATIVE,\"DIV\"> " );}
"mod"       {if(error==0)printf( "<MULTIPLICATIVE,\"MOD\"> " );}
{NUM}+{ID}                      {snprintf(buffer, sizeof(buffer),"ERROR: In line %d: %s not a valid identifier", num_lines, yytext); add_error(err_list,buffer ) ; error=1; printf("\r                                                                                             \r");}
{NUM}+"."{NUM}                  {snprintf(buffer, sizeof(buffer),"ERROR: In line %d: %s number type should only be int", num_lines, yytext); add_error(err_list,buffer ) ; error=1; printf("\r                                                                                     \r");}
({NUM}|{ID})+"."({NUM}|{ID})*   {snprintf(buffer, sizeof(buffer),"ERROR: In line %d: %s, invalid type. Not an integer nor a valid identifier ", num_lines, yytext); add_error(err_list,buffer ) ; error=1; printf("\r                                                              \r");}
{ID}+                       {if(symbol_type==0 && error==0){printf( "<ID,\"%s\"> ", yytext ); if(symbol_valid==0 )search_symbol(sym_table,yytext);} else if(symbol_type==1){printf( "<INT,_> " );} if(symbol_valid==1){ add_symbol(sym_table, yytext, symbol_type); symbols++; } }
{NUM}+                      {if(error==0)printf( "<NUM, %s> ", yytext );}

%%

int yywrap(){}
int main(int argc, char *argv[]){
yyin = fopen(argv[1], "r");
yylex();
fclose(yyin);
print_ST();
printf("\nNumber of symbols found: %d\n", symbols);
printf("Number of lines in original code " 
       "from the given input file - %d \n", num_lines);
printf("Number of tokenized lines outputted " 
       "after lexical analysis - %d \n", num_output_lines);
print_EL();
return 0;
}
void add_symbol(struct Symbol_table *st, char* ch, int check){
    if(check==1){
        snprintf(buffer, sizeof(buffer),"ERROR: In line %d:\"%s\" not a valid symbol type, must be integer. Symbol type for preceding identifier set to integer", num_lines, yytext); 
        add_error(err_list,buffer );
        return;
    }
    struct Symbol_table *curr= st;
    int char_size = strlen(ch);
    char *sym_ptr = malloc( char_size + 2 );
    strcpy(sym_ptr, ch);

    while(curr->next_Symbol != NULL){
        curr = curr->next_Symbol;
    }
    if(curr->symbol_value != NULL){
        struct Symbol_table *additional_symbol;
        additional_symbol = malloc(sizeof(struct Symbol_table));
        additional_symbol-> symbol_value = sym_ptr;
        strcpy(additional_symbol-> sym_type, "INTEGER");
        curr->next_Symbol = additional_symbol;
    }
    else{
        curr->symbol_value = sym_ptr;
        strcpy(curr-> sym_type, "INTEGER");
    }
    return;
}
void print_ST(){
    printf("\nSymbol Table\n___________\n");
    struct Symbol_table * curr= sym_table;
    int max_id=0;
    while(curr != NULL && curr->symbol_value != NULL){
        if(strlen(curr->symbol_value) > max_id){
            max_id = strlen(curr->symbol_value);
        }
        curr = curr-> next_Symbol;
    }

    int i;
    curr= sym_table;
    while(curr != NULL && curr->symbol_value != NULL){
        char curr_type[10];
        if( strcmp(curr->sym_type, "INTEGER") == 0){
            strcpy(curr_type,"int");
        }
        printf("%s", curr->symbol_value);
        
        for (i = 0; i < max_id-strlen(curr->symbol_value); ++i)
        {
            printf(" ");
        }

        printf("    %s\n", curr_type);
        curr = curr-> next_Symbol;
    }
}

void add_error(struct Error_list *el, char* ch){
    struct Error_list *curr= el;
    int char_size = strlen(ch);
    char *err_ptr = malloc( char_size + 2 );
    strcpy(err_ptr, ch);

    while(curr->next_error != NULL){
        curr = curr->next_error;
    }
    if(curr->error_text != NULL){
        struct Error_list *additional_error;
        additional_error = malloc(sizeof(struct Error_list));
        additional_error-> error_text = err_ptr;
        curr->next_error = additional_error;
    }
    else{
        curr->error_text = err_ptr;
    }
    return;
}

void print_EL(){
    printf("\nError List\n___________\n");
    struct Error_list * curr= err_list;
    if(curr->error_text == NULL){
        printf("No errors to list\n");
    }
    while(curr != NULL && curr->error_text != NULL){
        printf("%s\n", curr->error_text);
        curr= curr->next_error;
    }
}

struct Symbol_table* search_symbol(struct Symbol_table *st, char* ch){
    struct Symbol_table * curr= sym_table;
    while(curr != NULL && curr->symbol_value != NULL){
        if(strcmp(curr->symbol_value, ch)==0){
            // printf("%s symbol was found in symbol table", ch);
            return curr;
        }
        curr= curr->next_Symbol;
    }
    snprintf(buffer, sizeof(buffer),"ERROR: \"%s\" identifier in line:%d was not found in symbol table, needs proper type decleration before begin token", ch, num_lines); 
    add_error(err_list,buffer );
    error=1; 
    printf("\r                                                                                             \r");

    return curr;


}