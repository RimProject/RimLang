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
	
	std.file.write("res.rbc", new Generator().gen(lexed));
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
				tokens ~= new Token(TType.NUM, val2);
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

class Generator
{
	int index = -1;
	Token[] content;
	Token ch;
	
	Token advance(int step)
	{
		index += step;
		ch = new Token(TType.EOF);
		if (index < content.length) 
			ch = content[index];
		
		return ch;
	}
	
	Token advance()
	{
		return advance(1);
	}
	
	string gen(Token[] con)
	{
		content = con;
		Compiler c = new Compiler();
		advance();
		while (ch.type != TType.EOF)
		{
			write(ch.type);
			if (ch.con) writeln(",", ch.content);
			
			if(ch.type == TType.LPAR)		// function call
			{
				advance();
				if(ch.type != TType.ID) cmpanic("Identifier expected, got " ~ to!string(ch.type), 2);
				var id = ch.content;
				advance();
				if(ch.type != TType.RPAR) cmpanic("')' expected, got " ~ to!string(ch.type), 2);
				Func fn = new Func("NoFunc", -1, 0);
				foreach (i; funtable)
				{
					if (i.ctname == id)
					{
						fn = i;
						break;
					}
				}
				if (fn.id == -1) cmpanic("Unknown built-in function", 3);
				advance();
				Token argps;
				if (fn.args > 0)
				{
					if (ch.type != TType.LANG) cmpanic("'<' expected, got " ~ to!string(ch.type), 2);
					advance();
					if (ch.type != TType.NUM) cmpanic("Invalid argument", 4);
					argps = ch;
					advance();
					if (ch.type != TType.RANG) cmpanic("'>' expected, got " ~ to!string(ch.type), 2);
				}
				advance();
				if (ch.type == TType.LANG) 
				{
					advance();
					if (ch.type != TType.RANG) cmpanic("'>' expected, got " ~ to!string(ch.type), 2);
					advance();
				}
				
				if (ch.type != TType.EOL) cmpanic("End Of Line expected, got " ~ to!string(ch.type), 2);
				advance();
				if(argps.type == TType.NUM)
				{
					c.push(to!int(argps.content));
				}
				else cmpanic("Unknown type " ~ to!string(argps.type), -1);
				c.call(fn.id);
			}
			else if (ch.type == TType.EOF) break;
			else cmpanic("Invalid syntax " ~ to!string(ch.type), 1);
			advance();
		}
		
		return c.compile();
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
	
	NUM,		// 123, 456, 34923, 12.3
	
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
	
	EOL,		// end of line
	EOF
}