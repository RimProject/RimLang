import std.stdio;

union IntToBytes
{
  int i;
  byte[4] b;
}

union IntToBytes2
{
  int i;
  byte[2] b;
}

enum Types
{
	int32 = 1,
	string = 2
}

enum OpCodeId
{
	UNKNOWN = -1,
	NOP = 0,
	PUSH = 1,
	CALL = 2,
	PUSHVAR = 3,
	POPVAR = 4,
	STACK = 5
}

class OpCode 
{
	OpCodeId id = OpCodeId.UNKNOWN;
}

class NOP : OpCode
{
	this() { id = OpCodeId.NOP; }
}

class CALL : OpCode
{
	int callid;
	this(int i) { id = OpCodeId.CALL; callid = i; }
}

class PUSH : OpCode
{
	int val;
	string val2;
	Types type;
	this(int a) { type = Types.int32; id = OpCodeId.PUSH; val = a; }
	this(string a) { type = Types.string; id = OpCodeId.PUSH; val2 = a; }
}

class Compiler
{
	string bytecode = "";
	void addOpcode(OpCode opc)
	{
		switch(opc.id)
		{
			case OpCodeId.NOP:
				bytecode ~= cast(char)0;
				writeln("[*] Added NOP");
				break;
			case OpCodeId.PUSH:
				switch((cast(PUSH)opc).type)
				{
					case Types.int32:
						bytecode ~= (cast(char)1 ~ "" ~ cast(char)1) ~ cast(char[])IntToBytes((cast(PUSH)opc).val).b ~ cast(char)0;
						break;
					case Types.string:
						bytecode ~= cast(char)1 ~ "" ~ cast(char)2 ~ (cast(PUSH)opc).val2 ~ cast(char)0;
						break;
					default:
						throw new Exception("Unknown type");
				}
				writeln("[*] Added PUSH");
				break;
			case OpCodeId.CALL:
				bytecode ~= cast(char)2 ~ IntToBytes2((cast(CALL)opc).callid).b;
				writeln("[*] Added CALL");
				break;
			case OpCodeId.UNKNOWN:
				throw new Exception("Empty opcode is not allowed");
			default:
				throw new Exception("Unknown opcode");
		}
	}
	
	string compile()
	{
		return "RIM" ~ cast(char)0 ~ cast(char)0 ~ bytecode;
	}
}