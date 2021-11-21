import std.stdio;
import std.file;
import bytecode;
import std.array;
import std.file;
import std.algorithm.searching;
import std.conv : to;
import jsvar;
import core.stdc.stdlib;
import std.ascii;

void main()
{
	writeln("RimLang compiler");
	write("Enter path: ");
	string path = readln();
	
	path.popBack();

    if (!path.exists)
    {
        writeln("File not exists!");
        exit(1);
    }
	
	Token[] lexed = new Lexer().lex(readText(path));
	
	foreach (e; lexed)
	{
		write(e.type);
		if (e.con) write(", " ~ to!string(e.content));
		writeln();
	}
	/*
	Compiler cmp = new Compiler();
	cmp.addOpcode(new NOP());
	cmp.addOpcode(new PUSH("Hello World!!!"));
	cmp.addOpcode(new CALL(0));
	std.file.write("res.rbc", cmp.compile());
	*/
}

class Lexer
{
	int index = -1;
	string content = "";
	char ch;
	
	char advance(int step)
	{
		index += step;
		if (index < content.length) 
		{
			ch = content[index];
			return ch;
		}
		ch = cast(char)0;
		return cast(char)0;
	}
	
	char advance()
	{
		return advance(1);
	}
	
	Token[] lex(string con)
	{
		Token[] tokens;
		content = con;
		advance();
		while (ch != 0)
		{
			writeln(cast(int)ch);
			if(canFind(std.ascii.digits, to!string(ch)))
			{
				string val = "";
				while (canFind(std.ascii.digits, to!string(ch)))
				{
					val ~= ch;
					advance();
				}
				advance(-1);
				var val2 = to!int(val);
				tokens ~= new Token(TType.INT, val2);
			}
			else if(ch == ' ') {}
			else if(ch == cast(char)13) 
			{
				advance();
				tokens ~= new Token(TType.EOL);
			}
			else if(ch == cast(char)10)
			{
				tokens ~= new Token(TType.EOL);
			}
			else if(ch == cast(char)0)
			{
				break;
			}
			else if(canFind(std.ascii.letters ~ "_", ch))
			{
				var val = "";
				while (canFind(std.ascii.letters ~ "_" ~ std.ascii.digits, to!string(ch)))
				{
					val ~= ch;
					advance();
				}
				advance(-1);
				tokens ~= new Token(TType.ID, val);
			}
			else if(ch == '[') tokens ~= new Token(TType.LBRK);
			else if(ch == ']') tokens ~= new Token(TType.RBRK);
							
			else if(ch == '(') tokens ~= new Token(TType.LPAR);
			else if(ch == ')') tokens ~= new Token(TType.RPAR);
							
			else if(ch == '<') tokens ~= new Token(TType.LANG);
			else if(ch == '>') tokens ~= new Token(TType.RANG);
							
			else if(ch == ',') tokens ~= new Token(TType.COMMA);
							
			else if(ch == '<') tokens ~= new Token(TType.GT);
			else if(ch == '>') tokens ~= new Token(TType.LT);
			else if(ch == '=') tokens ~= new Token(TType.EQ);
			
			else cmpanic("Unknown symbol " ~ ch, 1);
			advance();
		}
		
		return tokens;
	}
}

void cmpanic(string text, int code)
{
	writeln("Compiler error " ~ to!string(code) ~ ": " ~ text);
	exit(code);
}

class Token
{
	TType type;
	var content;
	bool con = false;
	this(TType t)
	{
		type = t;
	}
	this(TType t, var c)
	{
		type = t;
		content = c;
		con = true;
	}
}

enum TType
{
	LPAR,		// (
	RPAR,		// )
	
	STR,		// "Hello!"
	CHAR, 		// 'A', 'a', '1'
	
	INT,		// 123, 456, 34923
	FLOAT,		// 12.3, 456.789
	
	ID,			// yaHohol, hello_world
	
	LBRK,		// [
	RBRK,		// ]
	
	LANG, 		// <
	RANG,		// >
	
	COMMA, 		// ,
	
	GT,			// >
	LT,			// <
	EQ,			// =
	
	GTEQ,		// >=
	LTEQ,		// <=
	
	EOL			// end of line
}