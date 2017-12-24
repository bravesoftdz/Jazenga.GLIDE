{
A collection of often needed functions missing in FPC

Copyright (C) 2008 - 2016  Benito van der Zander (BeniBela)
                           benito@benibela.de
                           www.benibela.de

This file is distributed under under the same license as Lazarus and the LCL itself:

This file is distributed under the Library GNU General Public License
with the following modification:

As a special exception, the copyright holders of this library give you
permission to link this library with independent modules to produce an
executable, regardless of the license terms of these independent modules,
and to copy and distribute the resulting executable under terms of your choice,
provided that you also meet, for each linked independent module, the terms
and conditions of the license of that module. An independent module is a
module which is not derived from or based on this library. If you modify this
library, you may extend this exception to your version of the library, but
you are not obligated to do so. If you do not wish to do so, delete this
exception statement from your version.

}

(***
  @abstract(This unit contains some basic functions missing in fpc)@br

  It uses the following naming convention:@br
  @br
  All functions starting with @code(str) are related to strings and work on ansistring or pchar,
  so you can use them for latin1 and utf-8.@br
  The prefix @code(strl) means the string length is given, @code(str?i) means the function is case insensitive@br
  @br@br
  The prefix @code(array) means the function works with dynamical arrays.@br
  If the suffix @code(Fast) is given, the length of the array is different of the count of contained elements i.e.
  the standard length is actually a capacity so you can resize it without reallocating the array.@br
  Some array functions have two optional slice parameters: if you give none of them the function will affect the whole
  array; if you give one of them, the function will affect elements in the inclusive interval [0, slice] and if you give both,
  it will affect elements in the inclusive interval [slice1, slice2].

  @author Benito van der Zander, (http://www.benibela.de)

*)

unit bbutils;

{$define allowyearzero} //there is no year zero in the BC/AD calendar. But there is in ISO 8601:2004. Although this unit uses the Julian calendar, so it is wrong before years 1582 (Gregorian calendar) anyways

{$DEFINE HASISNAN}

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
{$COPERATORS OFF}
{$DEFINE HASINLINE}
{$DEFINE HASDefaultFormatSettings}
{$DEFINE HASDeprecated}


{$ELSE} //DELPHI

{$IFDEF VER120}{$UNDEF HASISNAN}{$ENDIF}
{$IFDEF VER110}{$UNDEF HASISNAN}{$ENDIF}
{$IFDEF VER100}{$UNDEF HASISNAN}{$ENDIF}


{$ENDIF}

interface

uses
  Classes, SysUtils,math//,LCLProc
  {$IFDEF windows}
  , windows
  {$ENDIF};


//-------------------------Array functions-----------------------------


type
{$IFDEF FPC}
     {$ifndef FPC_HAS_CPSTRING} RawByteString = AnsiString;{$endif}
{$ifdef FPC_HAS_TYPE_Extended}float = extended;
{$else} {$ifdef FPC_HAS_TYPE_Double}float = double;
{$else} {$ifdef FPC_HAS_TYPE_Single}float = single;
{$endif}{$endif}{$endif}
{$else}
     float = extended;
     TTime = TDateTime;
     SizeInt = integer;
     TValueSign = -1..1;
{$IFDEF  CPU386}
     PtrUInt = DWORD;
     PtrInt = longint;
{$ELSE}{$IFDEF  CPUX64}
     PtrUInt = QWORD;
     PtrInt = int64;
{$ENDIF}{$ENDIF}
{$IFNDEF UNICODE}
     RawByteString = ansistring;
     UnicodeString = WideString;
     PUnicodeChar = ^WideChar;
{$ENDIF}
const
   NaN = 0.0/0.0;
   Infinity = 1.0/0.0;
   NegInfinity = -1.0/0.0;
   LineEnding = #13#10;

{$endif}

{$ifndef FPC_HAS_CPSTRING}
type TSystemCodePage     = Word;
const
  CP_UTF16   = 1200;
  CP_UTF16BE = 1201;
  CP_UTF8    = 65001;
  CP_NONE    = $FFFF;
  CP_ASCII   = 20127;
{$endif}
const CP_UTF32 = 12000;
      CP_UTF32BE = 12001;
      CP_WINDOWS1252 = 1252;
      CP_LATIN1 = 28591;


type
  TStringArray=array of string;
  TLongintArray =array of longint;
  TLongwordArray =array of longword;
  TInt64Array =array of int64;
  TFloatArray = array of float;

  TCharSet = set of ansichar;


//-----------------------Flow/Thread control functions------------------------
type TProcedureOfObject=procedure () of object;
function procedureToMethod(proc: TProcedure): TMethod;
//**Calls proc in an new thread
procedure threadedCall(proc: TProcedureOfObject; isfinished: TNotifyEvent); overload;
//**Calls proc in an new thread
procedure threadedCall(proc: TProcedureOfObject; isfinished: TProcedureOfObject);overload;
//**Calls proc in an new thread
procedure threadedCall(proc: TProcedure; isfinished: TProcedureOfObject);overload;

//------------------------------Charfunctions--------------------------
//Converts 0..9A..Za..z to a corresponding integer digit
function charDecodeDigit(c: char): integer; {$IFDEF HASINLINE} inline; {$ENDIF}
//Converts 0..9A..Fa..f to a corresponding integer digit
function charDecodeHexDigit(c: char): integer; {$IFDEF HASINLINE} inline; {$ENDIF}

//------------------------------Stringfunctions--------------------------
//All of them start with 'str' or 'widestr' so can find them easily
//Naming scheme str <l> <i> <name>
//L: use length (ignoring #0 characters, so the string must be at least length characters long)
//I: case insensitive

//copy
//**Copies min(sourceLen, destLen) characters from source to dest and returns dest
function strlmove(dest,source:pansichar;destLen,sourceLen: longint):pansichar;
//**Copies min(sourceLen, destLen) characters from source to dest and returns dest
function widestrlmove(dest,source:pwidechar;destLen,sourceLen: longint):pwidechar;
//**Returns the substring of s containing all characters after start (including s[start]
function strCopyFrom(const s:RawByteString; start:longint):RawByteString; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Returns a string with all characters between first and last (including first, last)
function strSlice(const first,last:pansichar):RawByteString; overload;
//**Returns a string with all characters between start and last (including start, last)
function strSlice(const s:RawByteString; start,last:longint):RawByteString; overload;

//**Like move: moves count strings from source memory to dest memory. Keeps the reference count intact. Size is count of strings * sizeof(string)!
procedure strMoveRef(var source: string; var dest: string; const size: longint); {$IFDEF HASINLINE} inline; {$ENDIF}

//comparison

//all pansichar<->pansichar comparisons are null-terminated (except strls.. functions with length-strict)
//all pansichar<->string comparisons are null-terminated iff the string doesn't contain #0 characters

//length limited
function strlEqual(const p1,p2:pansichar;const l: longint):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-sensitive equal (same length and same characters) (null-terminated, stops comparison when meeting #0 )
function strlEqual(const p1,p2:pansichar;const l1,l2: longint):boolean; overload;  {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-sensitive equal (same length and same characters) (null-terminated, stops comparison when meeting #0 )
function strliEqual(const p1,p2:pansichar;const l: longint):boolean; overload;  {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-insensitive equal (same length and same characters) (null-terminated, stops comparison when meeting #0 )
function strliEqual(const p1,p2:pansichar;const l1,l2: longint):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-insensitive equal (same length and same characters) (null-terminated, stops comparison when meeting #0 )
function strlsEqual(const p1,p2:pansichar;const l: longint):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-sensitive equal (same length and same characters) (strict-length, can continue comparison after #0)
function strlsEqual(const p1,p2:pansichar;const l1,l2: longint):boolean; overload;  {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-sensitive equal (same length and same characters) (strict-length, can continue comparison after #0)
function strlsiEqual(const p1,p2:pansichar;const l: longint):boolean; overload; //**< Tests if the strings are case-insensitive equal (same length and same characters) (strict-length, can continue comparison after #0)
function strlsiEqual(const p1,p2:pansichar;const l1,l2: longint):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the strings are case-insensitive equal (same length and same characters) (strict-length, can continue comparison after #0)
function strlsequal(p: pansichar; const s: RawByteString; l: longint): boolean; overload;

function strlEqual(p:pansichar;const s:RawByteString; l: longint):boolean; overload; //**< Tests if the strings are case-sensitive equal (same length and same characters)
function strliEqual(p:pansichar;const s:RawByteString;l: longint):boolean; overload; //**< Tests if the strings are case-insensitive equal (same length and same characters)
function strlBeginsWith(const p:pansichar; l:longint; const expectedStart:RawByteString):boolean; //**< Test if p begins with expectedStart (__STRICT_HELP__, case-sensitive)
function strliBeginsWith(const p:pansichar;l: longint;const expectedStart:RawByteString):boolean; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Test if p begins with expectedStart (__STRICT_HELP__, case-insensitive)


//not length limited
function strEqual(const s1,s2:RawByteString):boolean; //**< Tests if the strings are case-insensitive equal (same length and same characters)
function striEqual(const s1,s2:RawByteString):boolean; {$IFDEF HASINLINE} inline; {$ENDIF}//**< Tests if the strings are case-insensitive equal (same length and same characters)
function strBeginsWith(const strToBeExaminated,expectedStart:RawByteString):boolean; overload; //**< Tests if the @code(strToBeExaminated) starts with @code(expectedStart)
function striBeginsWith(const strToBeExaminated,expectedStart:RawByteString):boolean; overload; //**< Tests if the @code(strToBeExaminated) starts with @code(expectedStart)
function strBeginsWith(const p:pansichar; const expectedStart:RawByteString):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the @code(p) starts with @code(expectedStart) (p is null-terminated)
function striBeginsWith(const p:pansichar; const expectedStart:RawByteString):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF} //**< Tests if the @code(p) starts with @code(expectedStart) (p is null-terminated)
function strEndsWith(const strToBeExaminated,expectedEnd:RawByteString):boolean; //**< Tests if the @code(strToBeExaminated) ends with @code(expectedEnd)
function striEndsWith(const strToBeExaminated,expectedEnd:RawByteString):boolean; //**< Tests if the @code(strToBeExaminated) ends with @code(expectedEnd)


//**Case sensitive, clever comparison, that basically splits the string into
//**lexicographical and numerical parts and compares them accordingly
function strCompareClever(const s1, s2: RawByteString): integer;
//**Case insensitive, clever comparison, that basically splits the string into
//**lexicographical and numerical parts and compares them accordingly
function striCompareClever(const s1, s2: RawByteString): integer; {$IFDEF HASINLINE} inline; {$ENDIF}

//search
//**Searchs the last index of c in s
function strRpos(c:ansichar;s:RawByteString):longint;
//**Counts all occurrences of searched in searchIn (case sensitive)
function strCount(const str: RawByteString; const searched: ansichar; from: longint = 1): longint; overload;
//**Counts all occurrences of searched in searchIn (case sensitive)
function strCount(const str: RawByteString; const searched: TCharSet; from: longint = 1): longint; overload;

//**Searchs @code(searched) in @code(str) case-sensitive (Attention: opposite parameter to pos) (strict length, this function can find #0-bytes)
function strlsIndexOf(str,searched:pansichar; l1, l2: longint): longint; overload;
//**Searchs @code(searched) in @code(str) case-sensitive (Attention: opposite parameter to pos) (strict length, this function can find #0-bytes)
function strlsIndexOf(str:pansichar; const searched: TCharSet; length: longint): longint; overload;
//**Searchs @code(searched) in @code(str) case-insensitive (Attention: opposite parameter to pos)  (strict length, this function can find #0-bytes)
function strlsiIndexOf(str,searched:pansichar; l1, l2: longint): longint;

//**Searchs @code(searched) in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strIndexOf(const str,searched:RawByteString):longint; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs @code(searched) in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strIndexOf(const str: RawByteString; const searched: TCharSet):longint; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs @code(searched) in @code(str) case-insensitive (Attention: opposite parameter to pos)
function striIndexOf(const str,searched:RawByteString):longint; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs @code(searched) in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strIndexOf(const str,searched:RawByteString; from: longint):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs @code(searched) in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strIndexOf(const str: RawByteString; const searched: TCharSet; from: longint):longint; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs @code(searched) in @code(str) case-insensitive (Attention: opposite parameter to pos)
function striIndexOf(const str,searched:RawByteString; from: longint):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}

//**Searchs @code(searched) in @code(str), case-sensitive, returns -1 on no occurrence  (Attention: opposite parameter to pos) (strict length, this function can find #0-bytes)
function strlsLastIndexOf(str,searched:pansichar; l1, l2: longint): longint; overload;
//**Searchs @code(searched) in @code(str), case-sensitive, returns -1 on no occurrence (Attention: opposite parameter to pos) (strict length, this function can find #0-bytes)
function strlsLastIndexOf(str:pansichar; const searched: TCharSet; length: longint): longint; overload;
//**Searchs @code(searched) in @code(str), case-insensitive, returns -1 on no occurrence (Attention: opposite parameter to pos)  (strict length, this function can find #0-bytes)
function strlsiLastIndexOf(str,searched:pansichar; l1, l2: longint): longint;

//**Searchs the last occurrence of @code(searched) in @code(str), case-sensitive, returns 0 on no occurrence (Attention: opposite parameter to pos)
function strLastIndexOf(const str: RawByteString; const searched: RawByteString):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs the last occurrence of @code(searched) in @code(str), case-sensitive, returns 0 on no occurrence (Attention: opposite parameter to pos)
function strLastIndexOf(const str: RawByteString; const searched: RawByteString; from: longint):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs the last occurrence of @code(searched) in @code(str), case-sensitive, returns 0 on no occurrence (Attention: opposite parameter to pos)
function strLastIndexOf(const str: RawByteString; const searched: TCharSet):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs the last occurrence of @code(searched) in @code(str), case-sensitive, returns 0 on no occurrence (Attention: opposite parameter to pos)
function strLastIndexOf(const str: RawByteString; const searched: TCharSet; from: longint):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs the last occurrence of @code(searched) in @code(str), case-insensitive, returns 0 on no occurrence (Attention: opposite parameter to pos)
function striLastIndexOf(const str: RawByteString; const searched: RawByteString):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Searchs the last occurrence of @code(searched) in @code(str), case-insensitive, returns 0 on no occurrence (Attention: opposite parameter to pos)
function striLastIndexOf(const str: RawByteString; const searched: RawByteString; from: longint):longint; overload; {$IFDEF HASINLINE} inline; {$ENDIF}


//**Tests if @code(searched) exists in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strContains(const str,searched:RawByteString):boolean;overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Tests if @code(searched) exists in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strContains(const str:RawByteString; const searched: TCharSet):boolean;overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Tests if @code(searched) exists in @code(str) case-insensitive (Attention: opposite parameter to pos)
function striContains(const str,searched:RawByteString):boolean; overload; {$IFDEF HASINLINE} inline; {$ENDIF}
//**Tests if @code(searched) exists in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strContains(const str,searched:RawByteString; from: longint):boolean; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Tests if @code(searched) exists in @code(str) case-sensitive (Attention: opposite parameter to pos)
function strContains(const str:RawByteString; const searched: TCharSet; from: longint):boolean; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}
//**Tests if @code(searched) exists in @code(str) case-insensitive (Attention: opposite parameter to pos)
function striContains(const str,searched:RawByteString; from: longint):boolean; overload;  {$IFDEF HASINLINE} inline; {$ENDIF}

//more specialized
//**Removes all occurrences of trimCharacter from the left/right side of the string@br
//**It will move the pointer and change length, not modifying the memory pointed to
procedure strlTrimLeft(var p: pansichar; var l: integer; const trimCharacters: TCharSet = [#0..' ']);
//**Removes all occurrences of trimCharacter from the left/right side of the string@br
//**It will move the pointer and change length, not modifying the memory pointed to
procedure strlTrimRight(var p: pansichar; var l: integer; const trimCharacters: TCharSet = [#0..' ']);
//**Removes all occurrences of trimCharacter from the left/right side of the string@br
//**It will move the pointer and change length, not modifying the memory pointed to
procedure strlTrim(var p: pansichar; var l: integer; const trimCharacters: TCharSet = [#0..' ']);

//**Removes all occurrences of trimCharacter from the left/right side of the string
function strTrimLeft(const s:RawByteString; const trimCharacters: TCharSet = [#0..' ']):RawByteString; {$IFDEF HASINLINE} inline; {$ENDIF}
function strTrimRight(const s:RawByteString; const trimCharacters: TCharSet = [#0..' ']):RawByteString; {$IFDEF HASINLINE} inline; {$ENDIF}
function strTrim(const s: RawByteString; const trimCharacters: TCharSet = [#0..' ']):RawByteString; {$IFDEF HASINLINE} inline; {$ENDIF}
function strTrimAndNormalize(const s: RawByteString; const trimCharacters: TCharSet = [#0..' ']):RawByteString;

//**<Replaces all #13#10 or #13 by #10
function strNormalizeLineEndings(const s: RawByteString): RawByteString;
//**<Replaces all #$D#$A, #$D #$85, #$85, #$2028, or #13 by #10. Experimental, behaviour might change in future
function strNormalizeLineEndingsUTF8(const s: RawByteString): RawByteString;

//**< Prepends expectedStart, if s does not starts with expectedStart
function strPrependIfMissing(const s: RawByteString; const expectedStart: RawByteString): RawByteString;
//**< Appends expectedEnd, if s does not end with expectedEnd
function strAppendIfMissing(const s: RawByteString; const expectedEnd: RawByteString): RawByteString;

//**Splits the string remainingPart into two parts at the first position of separator, the
//**first part is returned as function result, the second one is again assign to remainingPart
//**(If remainingPart does not contain separator, it returns remainingPart and sets remainingPart := '')
function strSplitGet(const separator: RawByteString; var remainingPart: string):string;overload;
//**Splits the string remainingPart into two parts at the first position of separator, the
//**first is assign to firstPart, the second one is again assign to remainingPart
procedure strSplit(out firstPart: string; const separator: RawByteString; var remainingPart: string);overload;
//**Splits the string s into the array splitted at every occurrence of sep
procedure strSplit(out splitted: TStringArray;s: RawByteString; sep:RawByteString=',';includeEmpty:boolean=true);overload;
//**Splits the string s into the array splitted at every occurrence of sep
function strSplit(s:RawByteString;sep:RawByteString=',';includeEmpty:boolean=true):TStringArray;overload;

function strWrapSplit(const Line: RawByteString; MaxCol: Integer = 80; const BreakChars: TCharSet = [' ', #9]): TStringArray;
function strWrap(Line: RawByteString; MaxCol: Integer = 80; const BreakChars: TCharSet = [' ', #9]): RawByteString;

function strReverse(s: string): string; //**< reverses a string. Assumes the encoding is utf-8

//Given a string like openBracket  .. openBracket  ... closingBracket closingBracket closingBracket closingBracket , this will return everything between
//the string start and the second last closingBracket (it assumes one bracket is already opened, so 3 open vs. 4 closing => second last).
//If updateText, it will replace text with everything after that closingBracket. (always excluding the bracket itself)
function strSplitGetUntilBracketClosing(var text: RawByteString; const openBracket, closingBracket: RawByteString; updateText: boolean): RawByteString;
function strSplitGetBetweenBrackets(var text: RawByteString; const openBracket, closingBracket: RawByteString; updateText: boolean): RawByteString;

//** If the string s has the form 'STARTsep...' it returns 'START'. E.g. for /foo/bar it returns /foo with AllowDirectorySeparators do
function strBeforeLast(const s: RawByteString; const sep: TCharSet): RawByteString; overload;
//** If the string s has the form '...sepEND' it returns 'END'. E.g. for /foo/bar it returns bar with AllowDirectorySeparators
function strAfterLast(const s: RawByteString; const sep: TCharSet): RawByteString; overload;


//**Joins all string list items to a single string separated by @code(sep).@br
//**If @code(limit) is set, the string is limited to @code(abs(limit)) items.
//**if limit is positive, limitStr is appended; if limitStr is negative, limitStr is inserted in the middle
function strJoin(const sl: TStrings; const sep: RawByteString = ', '; limit: Integer=0; const limitStr: RawByteString='...'): RawByteString;overload;
//**Joins all string list items to a single string separated by @code(sep).@br
//**If @code(limit) is set, the string is limited to @code(abs(limit)) items.
//**if limit is positive, limitStr is appended; if limitStr is negative, limitStr is inserted in the middle
function strJoin(const sl: TStringArray; const sep: RawByteString = ', '; limit: Integer=0; const limitStr: RawByteString='...'): RawByteString;overload;

//**Converts a str to a bool (for fpc versions previous 2.2)
function StrToBoolDef(const S: RawByteString;const Def:Boolean): Boolean;

//**Removes a file:// prefix from filename if it is there
function strRemoveFileURLPrefix(const filename: RawByteString): RawByteString;

//**loads a file as string. The filename is directly passed to the fpc rtl and uses the system
//**encoding @seealso(strLoadFromFileUTF8)
function strLoadFromFile(filename:RawByteString):RawByteString;
//**saves a string as file. The filename is directly passed to the fpc rtl and uses the system
//**encoding @seealso(strSaveToFileUTF8)
procedure strSaveToFile(filename: RawByteString;str:RawByteString);
//**loads a file as string. The filename should be encoded in utf-8
//**@seealso(strLoadFromFile)
function strLoadFromFileUTF8(filename:RawByteString):RawByteString;
//**saves a string as file. The filename should be encoded in utf-8
//**@seealso(strSaveToFile)
procedure strSaveToFileUTF8(filename: RawByteString;str:RawByteString);
//**converts a size (measured in bytes) to a string (e.g. 1025 -> 1 KiB)
function strFromSIze(size: int64):string;


//encoding things
//**length of an utf8 string @br
//**A similar function exists in lclproc, but this unit should be independent of the lcl to make it easier to compile with fpc on the command line@br
//**Currently this function also calculates the length of invalid utf8-sequences, in violation of rfc3629
function strLengthUtf8(str: RawByteString): longint;
function strConvertToUtf8(str: RawByteString; from: TSystemCodePage): RawByteString; //**< Returns a utf-8 RawByteString from the string in encoding @code(from)
function strConvertFromUtf8(str: RawByteString; toe: TSystemCodePage): RawByteString; //**< Converts a utf-8 string to the encoding @code(from)
function strChangeEncoding(const str: RawByteString; from,toe: TSystemCodePage):RawByteString; //**< Changes the string encoding from @code(from) to @code(toe)
function strDecodeUTF16Character(var source: PUnicodeChar): integer;
{$IFDEF fpc}
procedure strUnicode2AnsiMoveProc(source:punicodechar;var dest:RawByteString;cp : TSystemCodePage;len:SizeInt); //**<converts utf16 to other unicode pages and latin1. The signature matches the function of fpc's widestringmanager, so this function replaces cwstring
procedure strAnsi2UnicodeMoveProc(source:pchar;cp : TSystemCodePage;var dest:unicodestring;len:SizeInt);        //**<converts unicode pages and latin1 to utf16. The signature matches the function of fpc's widestringmanager, so this function replaces cwstring
function strEncodingFromName(str:RawByteString):TSystemCodePage; //**< Gets the encoding from an encoding name (e.g. from http-equiv)
 {$ENDIF}
function strGetUnicodeCharacter(const character: integer; encoding: TSystemCodePage = CP_UTF8): RawByteString; //**< Get unicode character @code(character) in a certain encoding
function strGetUnicodeCharacterUTFLength(const character: integer): integer;
procedure strGetUnicodeCharacterUTF(const character: integer; buffer: pansichar);
function strDecodeUTF8Character(const str: RawByteString; var curpos: integer): integer; overload; //**< Returns the unicode code point of the utf-8 character starting at @code(str[curpos]) and increments @code(curpos) to the next utf-8 character. Returns a negative value if the character is invalid.
function strDecodeUTF8Character(var source: PChar; var remainingLength: SizeInt): integer; overload; //**< Returns the unicode code point of the utf-8 character starting at @code(str[curpos]) and decrements @code(remainingLength) to the next utf-8 character. Returns a negative value if the character is invalid.
function strEncodingFromBOMRemove(var str:string):TSystemCodePage; //**< Gets the encoding from an unicode bom and removes it

//** This function converts codePoint to the corresponding uppercase codepoint according to the unconditional cases of SpecialCasing.txt of Unicode 8. @br
//** It cannot be used to convert a character to uppercase, as SpecialCasing.txt is not a map from normal characters to their uppercase variants.
//** It is a collection of special characters that do not have an ordinary uppercase variant and are converted to something else. (e.g. ß -> SS) @br
//** The function signature is preliminary and likely to change.
function strUpperCaseSpecialUTF8(codePoint: integer): string;
//** This function converts codePoint to the corresponding lowercase codepoint according to the unconditional cases of SpecialCasing.txt of Unicode 8. @br
//** It cannot be used to convert a character to lowercase, as SpecialCasing.txt is not a map from normal characters to their lowercase variants.
//** It is a collection of special characters that do not have an ordinary lowercase variant and are converted to something else. @br
//** The function signature is preliminary and likely to change.
function strLowerCaseSpecialUTF8(codePoint: integer): string;

//**This decodes all html entities to the given encoding. If strict is not set
//**it will ignore wrong entities (so e.g. X&Y will remain X&Y and you can call the function
//**even if it contains rogue &).
function strDecodeHTMLEntities(p:pansichar;l:longint;encoding:TSystemCodePage; strict: boolean = false):string; overload;
//**This decodes all html entities to the given encoding. If strict is not set
//**it will ignore wrong entities (so e.g. X&Y will remain X&Y and you can call the function
//**even if it contains rogue &).
function strDecodeHTMLEntities(s:RawByteString;encoding:TSystemCodePage; strict: boolean = false):string; overload;
//**Replace all occurences of x \in toEscape with escapeChar + x
function strEscape(s:RawByteString; const toEscape: TCharSet; escapeChar: ansichar = '\'): RawByteString;
//**Replace all occurences of x \in toEscape with escape + hex(ord(x))
function strEscapeToHex(s:RawByteString; const toEscape: TCharSet; escape: RawByteString = '\x'): RawByteString;
//**Replace all occurences of escape + XX with chr(XX)
function strUnescapeHex(s:RawByteString; escape: RawByteString = '\x'): RawByteString;
//**Returns a regex matching s
function strEscapeRegex(const s:RawByteString): RawByteString;
//**Decodes a binary hex string like 202020 where every pair of hex digits corresponds to one char (deprecated, use strUnescapeHex)
function strDecodeHex(s:RawByteString):RawByteString; {$ifdef HASDeprecated}deprecated;{$endif}
//**Encodes to a binary hex string like 202020 where every pair of hex digits corresponds to one char (deprecated, use strEscapeToHex)
function strEncodeHex(s:RawByteString; const code: RawByteString = '0123456789ABCDEF'):RawByteString;{$ifdef HASDeprecated}deprecated;{$endif}
//**Returns the first l bytes of p (copies them so O(n))
function strFromPchar(p:pansichar;l:longint):RawByteString;

//**Creates a string to display the value of a pointer (e.g. 0xDEADBEEF)
function strFromPtr(p: pointer): RawByteString;
//**Creates a string to display an integer. The result will have at least displayLength digits (digits, not characters, so -1 with length 2, will become -02).
function strFromInt(i: int64; displayLength: longint): RawByteString;

//**Creates count copies of rep
function strDup(rep: RawByteString; const count: integer): RawByteString;

//**Checks if s is an absolute uri (i.e. has a [a-zA-Z][a-zA-Z0-9+-.]:// prefix)
function strIsAbsoluteURI(const s: RawByteString): boolean;
//**Returns a absolute uri for a uri relative to the uri base.@br
//**E.g. strResolveURI('foo/bar', 'http://example.org/abc/def') returns 'http://example.org/abc/foo/bar'@br
//**Or.  strResolveURI('foo/bar', 'http://example.org/abc/def/') returns 'http://example.org/abc/def/foo/bar'@br
//**base may be relative itself (e.g. strResolveURI('foo/bar', 'test/') becomes 'test/foo/bar')
function strResolveURI(rel, base: RawByteString): RawByteString;
//**Expands a path to an absolute path, if it not already is one
function fileNameExpand(const rel: string): string;
//**Expands a path to an absolute path starting with file://
function fileNameExpandToURI(const rel: string): string;
//**Moves oldname to newname, replacing newname if it exists
function fileMoveReplace(const oldname,newname: string): boolean;
type TFileSaveSafe = procedure (stream: TStream; data: pointer);
procedure fileSaveSafe(filename: string; callback: TFileSaveSafe; data: pointer);

//**Levenshtein distance between s and t
//**(i.e. the minimal count of characters to change/add/remove to convert s to t). O(n**2) time, O(n) space
function strSimilarity(const s, t: RawByteString): integer;

{$ifdef fpc}
//** Str iterator. Preliminary. Interface might change at any time
type TStrIterator = record
  FCurrent: integer;

  s: RawByteString;
  pos: integer;
  property Current: integer read FCurrent;
  function MoveNext: Boolean;
  function GetEnumerator: TStrIterator;
end;
 //** Str iterator. Preliminary. Interface might change at any time
function strIterator(const s: RawByteString): TStrIterator;

//** Str builder. Preliminary. Interface might change at any time
type TStrBuilder = record
  buffer: pstring;
  next, bufferend: pchar; //next empty pchar and first pos after the string
  procedure init(abuffer:pstring; basecapacity: integer = 64);
  procedure final;
  function count: integer; inline;
  procedure reserveadd(delta: integer);
  procedure add(c: char); inline;
  procedure add(const s: string); inline;
  procedure add(const codepoint: integer); inline;
  procedure add(const p: pchar; const l: integer); inline;
  procedure addhexentity(codepoint: integer);
  procedure addhexnumber(codepoint: integer);
end;
{$endif}


//----------------Mathematical functions-------------------------------

{$IFNDEF FPC}
function SwapEndian(const w: Word): Word; overload;
function SwapEndian(const w: DWord): DWord; overload;
{$ENDIF}

const powersOf10: array[0..9] of longint = (1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000);
//**log 10 rounded down (= number of digits in base 10 - 1)
function intLog10(i:longint):longint; overload;
//**log_b n  rounded down (= number of digits of n in base b - 1)
function intLog(n,b: longint): longint; overload;
//**Given a number n, this procedure calculates the maximal integer e, so that n = p^e * r
procedure intFactor(const n,p: longint; out e, r:longint);

function gcd(a,b: integer): integer; overload; //**< Calculates the greatest common denominator
function gcd(a,b: cardinal): cardinal; overload; //**< Calculates the greatest common denominator
function gcd(a,b: int64): int64; overload;  //**< Calculates the greatest common denominator
function lcm(a,b: int64): int64; //**< Calculates the least common multiple (just a*b div gcd(a,b), so it can easily overflow)
function coprime(a,b:cardinal): boolean; //**< Checks if two numbers are coprime
function factorial(i:longint):float; //**< Calculates i!
function binomial(n,k: longint): float;//**< Calculates n|k = n!/k!(n-k)!
//probability
//**expectated value of a binomial distribution
function binomialExpectation(n:longint;p:float):float;
//**variance of a binomial distribution
function binomialVariance(n:longint;p:float):float;
//**deviation(=sqrt(variance)) of a binomial distribution
function binomialDeviation(n:longint;p:float):float;
//**probability: P(X = k) where X is binomial distributed with n possible values (exact value calculated
//**with binomial coefficients, @seealso(binomialProbabilityApprox))
function binomialProbability(n:longint;p:float;k:longint):float; //P(X = k)
//**probability: P(X >= k) where X is binomial distributed with n possible values
function binomialProbabilityGE(n:longint;p:float;k:longint):float; //P(X >= k)
//**probability: P(X <= k) where X is binomial distributed with n possible values
function binomialProbabilityLE(n:longint;p:float;k:longint):float; //P(X <= k)
//**probability: P(X >= mu + d or X <= mu - d) where X is binomial distributed with n possible values
function binomialProbabilityDeviationOf(n:longint;p:float;dif:float):float; //P(X >= � + d or X <= � - d)
//**expectated value of a binomial distribution (approximates the value with either Poisson or
//**Moivre and Laplace, depending on the variance of the distribution) @seealso(binomialProbability))
function binomialProbabilityApprox(n:longint;p:float;k:longint):float;
//**Z-Score of the value k in a distribution with n outcomes
function binomialZScore(n:longint;p:float;k:longint):float;

//**This calculates the euler phi function totient[i] := phi(i) = |{1 <= j <= i | gcd(i,j) = 0}| for all i <= n.@br
//**It uses a sieve approach and is quite fast (10^7 in 3s)@br
//**You can also use it to calculate all primes (i  is prime iff phi(i) = i - 1)
procedure intSieveEulerPhi(const n: cardinal; var totient: TLongwordArray);
//**This calculates the number of divisors: divcount[i] := |{1 <= j <= i | i mod j = 0}| for all i <= n.@br
//**Speed: 10^7 in 5s@br
procedure intSieveDivisorCount(n: integer; var divcount: TLongintArray);


//--------------------Time functions-----------------------------------
{$IFDEF windows}
function dateTimeToFileTime(const date: TDateTime): TFileTime;
function fileTimeToDateTime(const fileTime: TFileTime;convertTolocalTimeZone: boolean=true): TDateTime;
{$ENDIF}


//**cumulative sum of month days (so. days in month i = dmdcs[i] - dmdcs[i-1])
const DateMonthDaysCumSum: array[false..true,0..12] of Cardinal =
     ((00, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365),
     (00, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366));

//**Week of year
function dateWeekOfYear(const date:TDateTime):word;       overload;
function dateWeekOfYear(year, month, day: integer):word;  overload;
//**@returns if year is a leap year (supports negative years, i think)
function dateIsLeapYear(const year: integer): boolean; {$IFDEF HASINLINE} inline; {$ENDIF}
type EDateTimeParsingException = class(Exception);
type TDateTimeParsingFlag = (dtpfStrict);
     TDateTimeParsingFlags = set of TDateTimeParsingFlag;
     TDateTimeParsingResult = (dtprSuccess, dtprFailureValueTooHigh, dtprFailureValueTooHigh2, dtprFailure);
//**Reads a date time string given a certain mask (mask is case-sensitive)@br
//**The uses the same mask types as FormatDate:@br
//**s or ss for a second  @br
//**n or nn for a minute  @br
//**h or hh for a hour  @br
//**d or dd for a numerical day  @br
//**m or mm for a numerical month, mmm for a short month name, mmmm for a long month name@br
//**am/pm or a/p match am/pm or a/p
//**yy, yyyy or [yy]yy for the year. (if the year is < 90, it will become 20yy, else if it is < 100, it will become 19yy, unless you use uppercase Y instead of y)  @br
//**YY, YYYY or [YY]YY for the year  @br
//**z, zz, zzz, zzzz for microseconds (e.g. use [.zzzzzz] for optional ms with exactly 6 digit precision, use [.z[z[z[z[z[z]]]]]] for optional µs with up to 6 digit precision)
//**Z for the ISO time zone (written as regular expressions, it matches 'Z | [+-]hh(:?mm)?'. Z is the only format ansichar (except mmm) matching several characters)
//**The letter formats d/y/h/n/s matches one or two digits, the dd/mm/yy formats require exactly two.@br
//**yyyy requires exactly 4 digits, and [yy]yy works with 2 or 4 (there is also [y]yyy for 3 to 4). The year always matches an optional - (e.g. yyyy also matches -0012, but not -012)@br
//**Generally [x] marks the part x as optional (it tries all possible combinations, so you shouldn't have more than 10 optional parts)@br
//**x+ will match any additional amount of x. (e.g. yy -> 2 digit year, yy+ -> at least 2 digit year, yyyy -> 4 digit year, [yy]yy -> 2 or 4 digit year) (mmm+ for short or long dates)@br
//**"something" can be used to match the input verbatim@br
//**whitespace is matched against whitespace (i.e. [ #9#10#13]+ matches [ #9#10#13]+)
//**The function works if the string is latin-1 or utf-8, and it also supports German month names@br
//**If a part is not found, it returns high(integer) there@br@br
//**There are old and new functions, because the signature has changed from double to int. Do not use the OLD functions unless you are porting existing code.@br@br
//**@return(If input could be matched with mask. It does not check, if the returned values are valid (e.g. month = 13 is allowed, in case you have to match durations))
function dateTimeParsePartsTry(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PInteger = nil; outtimezone: PInteger = nil; options: TDateTimeParsingFlags = []): TDateTimeParsingResult;
//**Reads date/time parts from a input matching a given mask (@see dateTimeParsePartsTry)
procedure dateTimeParsePartsNew(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PInteger = nil; outtimezone: PInteger = nil);
procedure dateTimeParsePartsOld(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PDouble = nil; outtimezone: PDateTime = nil);
//**Reads date/time from a input matching a given mask (@see dateTimeParsePartsTry)
function dateTimeParseNew(const input,mask:RawByteString; outtimezone: PInteger = nil): TDateTime;
function dateTimeParseOld(const input,mask:RawByteString; outtimezone: PDateTime = nil): TDateTime;
//**Converts a dateTime to a string corresponding to the given mask (same mask as dateTimeParsePartsTry)
function dateTimeFormatNEW(const mask: RawByteString; y, m,d, h, n, s: Integer; nanoseconds: integer; timezone: integer = high(integer)): RawByteString; overload;
//**Converts a dateTime to a string corresponding to the given mask (same mask as dateTimeParsePartsTry)
function dateTimeFormat(const mask: RawByteString; const dateTime: TDateTime): RawByteString; overload;


//**Encodes a date time
function dateTimeEncodeOLD(const y,m,d,h,n,s:integer; const secondFraction: double = 0): TDateTime;

//**Converts a dateTime to a string corresponding to the given mask (same mask as dateTimeParsePartsTry)
function dateTimeFormatOLD(const mask: RawByteString; y, m,d, h, n, s: Integer; const secondFraction: double = 0; const timezone: TDateTime = Nan): RawByteString; overload; {$ifdef HASDeprecated}deprecated;{$endif}


//**Reads a time string given a certain mask (@see dateTimeParsePartsTry)@br
procedure timeParsePartsNew(const input,mask:RawByteString; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PInteger = nil; outtimezone: PInteger = nil);
procedure timeParsePartsOld(const input,mask:RawByteString; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PDouble = nil; outtimezone: PDateTime = nil);
//**Reads a time string given a certain mask (@see dateTimeParsePartsTry).@br This function checks, if the time is valid.
function timeParse(const input,mask:RawByteString): TTime;
//**Converts a dateTime to a string corresponding to the given mask (same mask as dateTimeParsePartsTry)
function timeFormatOld(const mask: RawByteString; const h, n, s: integer; const secondFraction: double = 0; const timezone: TDateTime = Nan): RawByteString; {$ifdef HASDeprecated}deprecated;{$endif}


//**Reads a date string given a certain mask (@see dateTimeParsePartsTry)@br
procedure dateParsePartsNew(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outtimezone: PInteger = nil);
procedure dateParsePartsOLD(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outtimezone: PDateTime = nil); {$ifdef HASDeprecated}deprecated;{$endif}
//**Reads a date string given a certain mask (@see dateTimeParsePartsTry)@br This function checks, if the date is valid.
function dateParse(const input,mask:RawByteString): longint;
//**Converts a dateTime to a string corresponding to the given mask (same mask as dateTimeParsePartsTry)
function dateFormat(const mask: RawByteString; const y, m, d: integer; const timezone: TDateTime = nan): RawByteString;
//**Encodes a date as datetime (supports negative years)
function dateEncodeTry(year, month, day: integer; out dt: TDateTime): boolean;
//**Encodes a date as datetime (supports negative years)
function dateEncode(year, month, day: integer): TDateTime;
//**Encodes a date as datetime (supports negative years)
procedure dateDecode(date: TDateTime; year, month, day: PInteger);

const WHITE_SPACE=[#9,#10,#13,' '];

(*
//----------------------------Templates-------------------------------


type

{ TMap }

generic TMap<T_Key,T_Value> = class
protected
  data: array of record
    key: T_Key;
    value: T_Value;
  end;
  function getKeyID(key: T_Key):longint;
public
  procedure insert(key: T_Key; value: T_Value);
  procedure remove(key: T_Key);
  function get(key: T_Key): T_Value;
  function existsKey(key: T_Key): boolean;

end;

{ TSet }

generic TSet<T_Value> = class(TObject)
protected
  reallength: longint;
  data: array of T_Value;
public
  procedure clear();
  procedure insert(v: T_Value);
  //procedure insertAll(other: TObject);
  procedure remove(v: T_Value);
  //procedure removeAll(other:TObject);
  function contains(v: T_Value):boolean;
  function count:longint;
end;

TIntSet = specialize TSet <integer>;

procedure setInsertAll(oldSet:TIntSet; insertedSet: TIntSet);
procedure setRemoveAll(oldSet:TIntSet; removedSet: TIntSet);            *)
//----------------------------Others-----------------------------------
//**Compare function to compare the two values to which a and b, ideally returning -1 for a^<b^, 0 for a^=b^, +1 for a^>b^
//**The data is an TObject to prevent confusing it with a and b. It is the first parameter,
//**so the function use the same call convention like a method
type TPointerCompareFunction = function (data: TObject; a, b: pointer): longint;
//**General stable sort function @br
//**a is the first element in the array to sort, and b is the last. size is the size of every element@br
//**compareFunction is a function which compares two pointer to elements of the array, if it is nil, it will compare the raw bytes (which will correspond to an ascending sorting of positive integers). @br
//**Only the > 0 and <= 0 return values are discerned. (i.e. you can safely use a comparison function that e.g. only returns +7 and 0)  @br
//**Currently it uses a combination of merge and insert sort. Merge requires the allocation of additional memory.
procedure stableSort(a,b: pointer; size: longint; compareFunction: TPointerCompareFunction = nil; compareFunctionData: TObject=nil); overload;
//**general stable sort functions for arrays (modifying the array inline and returning it)
function stableSort(intArray: TLongintArray; compareFunction: TPointerCompareFunction; compareFunctionData: TObject=nil): TLongintArray; overload;
function stableSort(strArray: TStringArray; compareFunction: TPointerCompareFunction = nil; compareFunctionData: TObject=nil): TStringArray; overload;


type TBinarySearchChoosen = (bsAny, bsFirst, bsLast);
     TBinarySearchAcceptedCondition = (bsLower, bsEqual, bsGreater);
type TBinarySearchAcceptedConditions = set of TBinarySearchAcceptedCondition;
//**Should return 0 if the searched element is equal to a,
//**             -1 if the searched element is smaller than a, and
//**             +1 if the searched element is larger than a.
//**(that is the opposite of what you might expect, but it is logical: the data parameter has to come first to match a method signature. The data parameter is compared to a parameter (to match a standalone comparison function signature))
type TBinarySearchFunction = function (data: TObject; a: pointer): longint;
//** General binary search function
//** @br @code(a) is the first element in the (ascending, sorted) array, @code(b) the last, @code(size) the size of each element
//** @br @code(compareFunction) is a TBinarySearchFunction comparing the searched element to another element
//** @br @code(compareFunctionData) is the data passed to the comparison function as first argument (you can think of it as searched element)
//** @br @code(choosen) is the element that should be returned, if there are multiple matches (bsFirst, bsLast  or bsAny) .
//** @br @code(condition) the comparison relation between the returned and searched element (E.g. for [bsGreater, bsEqual] the returned element satisfies @code(compareFunction(reference, returned) <= 0).)
//** @br returns a pointer to the found match or nil if there is none.
//** @br (note that you can combine, e.g. bsGreater and bsLast, which will always return the last element, unless all are lower)
function binarySearch(a,b: pointer; size: longint; compareFunction: TBinarySearchFunction = nil; compareFunctionData: TObject=nil; choosen: TBinarySearchChoosen = bsAny; condition: TBinarySearchAcceptedConditions = [bsEqual]): pointer;

function eUTF8: TSystemCodePage; {$IFDEF HASINLINE} inline; {$ENDIF} {$ifdef HASDeprecated}deprecated;{$endif}
function eWindows1252: TSystemCodePage; {$IFDEF HASINLINE} inline; {$ENDIF} {$ifdef HASDeprecated}deprecated;{$endif}

{$I bbutilsh.inc}

implementation

const MinsPerDay = 24 * 60;

{$IFNDEF HASSIGN}
function Sign(a: integer): TValueSign;
begin
  if a < 0 then result := -1
  else if a > 0 then result := 1
  else result := 0;
end;

{$ENDIF}

{$IFNDEF HASISNAN}
function IsNan(const d: double): boolean;
var data: array[0..1] of longword absolute d;
const LO = 0; HI = 1;
begin
  //sign := (PQWord(@d)^ shr 63) <> 0;
  result := ((data[HI] and $7FF00000) = $7FF00000) and
            ((data[LO] <> 0) or (data[HI] and not $FFF00000 <> 0));
end;
{$ENDIF}

//========================array functions========================

procedure arraySliceIndices(const higha: integer; var slice1, slice2: integer); overload;
begin
  if (slice2 = -1) and (slice1 = -1) then begin
    slice2 := higha;
    slice1 := 0;
  end else if slice2 = -1 then begin
    slice2 := slice1;
    slice1 := 0;
  end;
end;

//=========================Flow control functions======================

type

{ TThreadedCall }

TThreadedCall = class(TThread)
  proc: TProcedureOfObject;
  procedure Execute; override;
  constructor create(aproc: TProcedureOfObject;isfinished: TNotifyEvent);
end;

procedure TThreadedCall.Execute;
begin
  proc();
end;

constructor TThreadedCall.create(aproc: TProcedureOfObject;isfinished: TNotifyEvent);
begin
  self.proc:=aproc;
  FreeOnTerminate:=true;
  OnTerminate:=isfinished;
  inherited create(false);
end;

function procedureToMethod(proc: TProcedure): TMethod;
begin
  assert(sizeof(result.code) = sizeof(proc));
  move(proc, result.code, sizeof(proc));
  //result.code:=proc;
  result.Data:=nil;
end;

procedure threadedCallBase(proc: TProcedureOfObject; isfinished: TNotifyEvent);
begin
  TThreadedCall.Create(proc,isfinished);
end;

procedure threadedCall(proc: TProcedureOfObject; isfinished: TNotifyEvent);
begin
  threadedCallBase(proc,isfinished);
end;

procedure threadedCall(proc: TProcedureOfObject; isfinished: TProcedureOfObject);
begin
  threadedCallBase(proc, TNotifyEvent(isfinished));
end;

procedure threadedCall(proc: TProcedure; isfinished: TProcedureOfObject);
begin
  threadedCallBase(TProcedureOfObject(procedureToMethod(proc)),TNotifyEvent(isfinished));
end;

function charDecodeDigit(c: char): integer;
begin
  case c of
    '0'..'9': result := ord(c) - ord('0');
    'a'..'z': result := ord(c) - ord('a') + 10;
    'A'..'Z': result := ord(c) - ord('A') + 10;
    else raise Exception.Create('Character '+c+' is not a valid digit');
  end;
end;

function charDecodeHexDigit(c: char): integer;
begin
  case c of
    '0'..'9': result := ord(c) - ord('0');
    'a'..'f': result := ord(c) - ord('a') + 10;
    'A'..'F': result := ord(c) - ord('A') + 10;
    else raise Exception.Create('Character '+c+' is not a valid hex digit');
  end;
end;


//=========================String functions======================

function strlmove(dest, source: pansichar; destLen, sourceLen: longint): pansichar;
begin
  move(source^,dest^,min(sourceLen,destLen));
  result:=dest;
end;

function widestrlmove(dest, source: pwidechar; destLen, sourceLen: longint): pwidechar;
begin
  move(source^,dest^,min(sourceLen,destLen)*sizeof(widechar));
  result:=dest;
end;

//---------------------Comparison----------------------------

function strActualEncoding(e: TSystemCodePage): TSystemCodePage; {$ifdef HASINLINE} inline; {$endif}
begin
  case e of
    CP_ACP: result := {$IFDEF FPC_HAS_CPSTRING}DefaultSystemCodePage
                      {$else}{$ifdef windows}GetACP
                      {$else}CP_UTF8
                      {$endif}{$endif};
    else result := e;
  end;
end;

//--Length-limited
function strlEqual(const p1, p2: pansichar; const l: longint): boolean;
begin
  result:=(strlcomp(p1, p2, l) = 0);
end;

//Length limited && null terminated
//equal comparison, case sensitive, stopping at #0-bytes
function strlequal(const p1,p2:pansichar;const l1,l2: longint):boolean;
begin
  result:=(l1=l2) and (strlcomp(p1, p2,l1) = 0);
end;

//equal comparison, case insensitive, stopping at #0-bytes
function strliEqual(const p1, p2: pansichar; const l: longint): boolean;
begin
  result:=(strlicomp(p1,p2,l)=0);
end;

//equal comparison, case insensitive, stopping at #0-bytes
function strliequal(const p1,p2:pansichar;const l1,l2: longint):boolean;
begin
  result:=(l1=l2) and (strlicomp(p1,p2,l1)=0);
end;

{$IFNDEF FPC}
function compareByte(const a, b; size: integer):longint;
var ap, bp: pansichar;
    i: Integer;
begin
  ap := @a;
  bp := @b;
  for i:=1 to size do begin
    if ap^ < bp^ then begin result := -1; exit; end;
    if ap^ > bp^ then begin result := 1; exit; end;
    inc(ap);
    inc(bp);
  end;
  begin result := 0; exit; end;
end;
{$ENDIF}

//equal comparison, case sensitive, ignoring #0-bytes
function strlsequal(const p1,p2:pansichar;const l: longint):boolean; {$IFDEF HASINLINE} inline; {$ENDIF}
begin
  result:= (CompareByte(p1^, p2^, l) = 0);
end;

//equal comparison, case sensitive, ignoring #0-bytes
function strlsequal(const p1,p2:pansichar;const l1,l2: longint):boolean; {$IFDEF HASINLINE} inline; {$ENDIF}
begin
  result:= (l1=l2) and (CompareByte(p1^, p2^, l1) = 0);
end;

function strlsiEqual(const p1, p2: pansichar; const l: longint): boolean;
var i, c1, c2:integer;
begin
  result := true;
  for i := 0 to l-1 do
      if p1[i] <> p2[i] then begin
        c1 := ord(p1[i]);
        c2 := ord(p2[i]);
        if c1 in [97..122] then dec(c1, 32);
        if c2 in [97..122] then dec(c2, 32);
        if c1 <> c2 then begin result := false; exit; end;
      end;
end;

//equal comparison, case insensitive, ignoring #0-bytes
function strlsiequal(const p1, p2: pansichar; const l1, l2: longint): boolean;
begin
  result:=(l1=l2) and strlsiequal(p1, p2, l1);
end;


//equal comparison, case sensitive, stopping at #0-bytes in p1, ignoring #0-bytes in l2
function strlnsequal(p1,p2:pansichar;l2: longint):boolean;
var i:integer;
begin
  for i:=0 to l2-1 do begin
    if p1[i]<>p2[i] then
      begin result := false; exit; end;
    if p1[i]=#0 then
      begin result := i = l2-1; exit; end
  end;
  result:=true;
end;

//equal comparison, case insensitive, stopping at #0-bytes in p1, ignoring #0-bytes in l2
function strlnsiequal(p1,p2:pansichar;l2: longint):boolean;
var i:integer;
begin
  for i:=0 to l2-1 do begin
    if upcase(p1[i])<>upcase(p2[i]) then
      begin result := false; exit; end;
    if p1[i]=#0 then
      begin result := i = l2-1; exit; end
  end;
  result:=true;
end;


function strlsequal(p: pansichar; const s: RawByteString; l: longint): boolean;
begin
  result:=(l = length(s)) and ((l = 0) or (strlsequal(p, pansichar(pointer(s)),l,l)));
end;

function strlequal(p: pansichar; const s: RawByteString; l: longint): boolean;
begin
  result := (l = length(s)) and ( (l = 0) or strlsequal(p, pansichar(pointer(s)), l, l));
end;

function strliequal(p: pansichar; const s:RawByteString;l: longint): boolean;
begin
  result := (l = length(s)) and ( (l = 0) or strlsiequal(p, pansichar(pointer(s)), l, l));
end;



function strEqual(const s1, s2: RawByteString): boolean;
begin
  if pointer(s1) = pointer(s2) then begin
    result := true;
    exit;
  end;
  {$IFDEF FPC_HAS_CPSTRING}
  if StringCodePage(s1) <> StringCodePage(s2) then
    if strActualEncoding(StringCodePage(s1)) <> strActualEncoding(StringCodePage(s2)) then begin
      result := s1 = s2; //this is slow due to encoding conversion
      exit;
    end;
  {$ENDIF}
  if length(s1) <> length(s2) then begin
    result := false;
    exit;
  end;
  result:=CompareByte(pchar(pointer(s1))^, pchar(pointer(s2))^, length(s1)) = 0;
end;

function striequal(const s1, s2: RawByteString): boolean;
begin
  result:=CompareText(s1,s2)=0;
end;

function strlbeginswith(const p: pansichar; l: longint; const expectedStart: RawByteString): boolean;
begin
  result:=(expectedStart='') or ((l>=length(expectedStart)) and (strlsequal(p,pansichar(pointer(expectedStart)),length(expectedStart),length(expectedStart))));
end;

function strlibeginswith(const p: pansichar; l: longint; const expectedStart: RawByteString): boolean;
begin
  result:=(expectedStart='') or ((l>=length(expectedStart)) and (strlsiequal(p,pansichar(pointer(expectedStart)),length(expectedStart),length(expectedStart))));
end;


function strbeginswith(const p: pansichar; const expectedStart: RawByteString): boolean;
begin
  result:=(expectedStart='') or (strlnsequal(p, pansichar(pointer(expectedStart)), length(expectedStart)));
end;

function stribeginswith(const p: pansichar; const expectedStart: RawByteString): boolean;
begin
  result:=(expectedStart='') or (strlnsiequal(p, pansichar(pointer(expectedStart)), length(expectedStart)));
end;

function strbeginswith(const strToBeExaminated,expectedStart: RawByteString): boolean;
begin
  result:=(expectedStart='') or ((strToBeExaminated <> '') and strlsequal(pansichar(pointer(strToBeExaminated)), pansichar(pointer(expectedStart)), length(expectedStart), length(expectedStart)));
end;

function stribeginswith(const strToBeExaminated,expectedStart: RawByteString): boolean;
begin
  result:=(expectedStart='') or ((strToBeExaminated <> '') and strlsiequal(pansichar(pointer(strToBeExaminated)), pansichar(pointer(expectedStart)), length(expectedStart), length(expectedStart)));
end;

function strendswith(const strToBeExaminated, expectedEnd: RawByteString): boolean;
begin
  result := (length(strToBeExaminated)>=Length(expectedEnd)) and
            ( (expectedEnd='') or
              (strlsequal(@strToBeExaminated[length(strToBeExaminated)-length(expectedEnd)+1],pansichar(pointer(expectedEnd)),length(expectedEnd),length(expectedEnd))) );
end;

function striendswith(const strToBeExaminated, expectedEnd: RawByteString): boolean;
begin
  result := (length(strToBeExaminated)>=Length(expectedEnd)) and
            ( (expectedEnd='') or
              (strlsiequal(@strToBeExaminated[length(strToBeExaminated)-length(expectedEnd)+1],pansichar(pointer(expectedEnd)),length(expectedEnd),length(expectedEnd))) );
end;

function strlsIndexOf(str, searched: pansichar; l1, l2: longint): longint;
var last: pansichar;
begin
  if l2<=0 then begin result := 0; exit; end;
  if l1<l2 then begin result := -1; exit; end;
  last:=str+(l1-l2);
  result:=0;
  while str <= last do begin
    if str^ = searched^ then
      if strlsequal(str, searched, l2) then
        exit;
    inc(str);
    inc(result);
  end;
  result:=-1;
end;

function strlsIndexOf(str:pansichar; const searched: TCharSet; length: longint): longint;
var last: pansichar;
begin
  if length<1 then begin result := -1; exit; end;
  last:=str+(length-1);
  result:=0;
  while str <= last do begin
    if str^ in searched then
      exit;
    inc(str);
    inc(result);
  end;
  result:=-1;
end;

function strlsiIndexOf(str, searched: pansichar; l1, l2: longint): longint;
var last: pansichar;
begin
  if l2<=0 then begin result := 0; exit; end;
  if l1<l2 then begin result := -1; exit; end;
  last:=str+(l1-l2);
  result:=0;
  while str <= last do begin
    if upcase(str^) = upcase(searched^) then
      if strlsiequal(str+1, searched+1, l2-1, l2-1) then
        exit;
    inc(str);
    inc(result);
  end;
  result:=-1;
end;

function strIndexOf(const str, searched: RawByteString): longint;
begin
  result := strIndexOf(str, searched, 1);      //no default paramert, so you can take the address of both functions
end;

function strIndexOf(const str: RawByteString; const searched: TCharSet): longint;
begin
  result := strIndexOf(str, searched, 1);
end;

function striIndexOf(const str, searched: RawByteString): longint;
begin
  result := striIndexOf(str, searched, 1);
end;

function strindexof(const str, searched: RawByteString; from: longint): longint;
begin
  if from > length(str) then begin result := 0; exit; end;
  result := strlsIndexOf(pansichar(pointer(str))+from-1, pansichar(pointer(searched)), length(str) - from + 1, length(searched));
  if result < 0 then begin result := 0; exit; end;
  inc(result,  from);
end;

function strIndexOf(const str: RawByteString; const searched: TCharSet; from: longint): longint;
var
  i: LongInt;
begin
  for i := from to length(str) do
    if str[i] in searched then begin
      result := i;
      exit;
    end;
  result := 0;
end;

function striindexof(const str, searched: RawByteString; from: longint): longint;
begin
  if from > length(str) then begin result := 0; exit; end;
  result := strlsiIndexOf(pansichar(pointer(str))+from-1, pansichar(pointer(searched)), length(str) - from + 1, length(searched));
  if result < 0 then begin result := 0; exit; end;
  inc(result,  from);
end;

function strlsLastIndexOf(str, searched: pansichar; l1, l2: longint): longint;
var last: pansichar;
begin
  if l2<=0 then begin result := 0; exit; end;
  if l1<l2 then begin result := -1; exit; end;
  last:=str+(l1-l2);
  result:=l1-l2;
  while str <= last do begin
    if last^ = searched^ then
      if strlsequal(last, searched, l2) then
        exit;
    dec(last);
    dec(result);
  end;
  result:=-1;
end;

function strlsLastIndexOf(str: pansichar; const searched: TCharSet; length: longint): longint;
var last: pansichar;
begin
  if length<1 then begin result := -1; exit; end;
  last:=str+(length-1);
  result:=length-1;
  while str <= last do begin
    if last^ in searched then
      exit;
    dec(last);
    dec(result);
  end;
  result:=-1;
end;

function strlsiLastIndexOf(str, searched: pansichar; l1, l2: longint): longint;
var last: pansichar;
begin
  if l2<=0 then begin result := 0; exit; end;
  if l1<l2 then begin result := -1; exit; end;
  last:=str+(l1-l2);
  result:=l1-l2;
  while str <= last do begin
    if upcase(last^) = upcase(searched^) then
      if strlsiequal(last+1, searched+1, l2-1, l2-1) then
        exit;
    dec(last);
    dec(result);
  end;
  result:=-1;
end;


function strLastIndexOf(const str: RawByteString; const searched: RawByteString; from: longint): longint;
begin
  if from > length(str) then begin result := 0; exit; end;
  result := strlsLastIndexOf(pansichar(pointer(str))+from-1, pansichar(pointer(searched)), length(str) - from + 1, length(searched));
  if result < 0 then begin result := 0; exit; end;
  inc(result,  from);
end;

function strLastIndexOf(const str: RawByteString; const searched: TCharSet; from: longint): longint;
var
  i: LongInt;
begin
  for i := length(str) downto from do
    if str[i] in searched then begin
      result := i;
      exit;
    end;
  result := 0;
end;

function striLastIndexOf(const str: RawByteString; const searched: RawByteString; from: longint): longint;
begin
  if from > length(str) then begin result := 0; exit; end;
  result := strlsiLastIndexOf(pansichar(pointer(str))+from-1, pansichar(pointer(searched)), length(str) - from + 1, length(searched));
  if result < 0 then begin result := 0; exit; end;
  inc(result,  from);
end;

function strLastIndexOf(const str: RawByteString; const searched: TCharSet): longint;
begin
  result := strLastIndexOf(str, searched, 1);
end;


function strContains(const str, searched: RawByteString): boolean;
begin
  result := strContains(str, searched, 1);
end;

function strContains(const str: RawByteString; const searched: TCharSet): boolean;
begin
  result := strContains(str, searched, 1);
end;

function striContains(const str, searched: RawByteString): boolean;
begin
  result := striContains(str, searched, 1);
end;

function strcontains(const str, searched: RawByteString; from: longint): boolean;
begin
  result:=strindexof(str, searched, from) > 0;
end;

function strContains(const str: RawByteString; const searched: TCharSet; from: longint): boolean;
begin
  result:=strindexof(str, searched, from) > 0;
end;

function stricontains(const str, searched: RawByteString; from: longint): boolean;
begin
  result:=striindexof(str, searched, from) > 0;
end;

function strcopyfrom(const s: RawByteString; start: longint): RawByteString; {$IFDEF HASINLINE} inline; {$ENDIF}
begin
  result:=copy(s,start,length(s)-start+1);
end;

function strslice(const s: RawByteString; start, last: longint): RawByteString;
begin
  result:=copy(s,start,last-start+1);
end;


procedure strMoveRef(var source: string; var dest: string; const size: longint); {$IFDEF HASINLINE} inline; {$ENDIF}
var clearFrom: PAnsiChar;
    clearTo: PAnsiChar;
    countHighSize: integer;
begin
  if size <= 0 then exit;

  countHighSize := size - sizeof(string);

  //clear reference count of target ( [dest:0..size-1] - [source:0..size-1] )

  clearFrom := PAnsiChar(@dest);
  clearTo := clearFrom + countHighSize;
  if (clearFrom >= PAnsiChar(@source)) and (clearFrom <= PAnsiChar(@source) + countHighSize) then
    clearFrom := PAnsiChar(@source) + countHighSize + sizeof(string);
  if (clearTo >= PAnsiChar(@source)) and (clearTo <= PAnsiChar(@source) + countHighSize) then
    clearTo := PAnsiChar(@source) - sizeof(string);

  while clearFrom <= clearTo do begin
    PString(clearFrom)^ := '';
    inc(clearFrom, sizeof(string));
  end;

  //move
  move(source, dest, size);

  //remove source ( [source:0..size-1] - [dest:0..size-1] )
  clearFrom := PAnsiChar(@source);
  clearTo := clearFrom + countHighSize;
  if (clearFrom >= PAnsiChar(@dest)) and (clearFrom <= PAnsiChar(@dest) + countHighSize) then
    clearFrom := PAnsiChar(@dest) + countHighSize + sizeof(string);
  if (clearTo >= PAnsiChar(@dest)) and (clearTo <= PAnsiChar(@dest) + countHighSize) then
    clearTo := PAnsiChar(@dest) - sizeof(string);

  if clearFrom <= clearTo then
    FillChar(clearFrom^, PtrUInt(clearTo - clearFrom) + sizeof(string), 0);
end;

function strrpos(c: ansichar; s: RawByteString): longint;
var i:longint;
begin
  for i:=length(s) downto 1 do
    if s[i]=c then
      begin result := i; exit; end;
  result := 0;
end;

function strlcount(const search: ansichar; const searchIn: pansichar; const len: longint): longint;
var
  i: Integer;
begin
  result:=0;
  for i:=0 to len-1 do begin
    if searchIn[i]=search then
      inc(result);
    if searchIn[i] = #0 then
      exit;
  end;
end;


function strCount(const str: RawByteString; const searched: ansichar; from: longint): longint;
var
  i: LongInt;
begin
  result := 0;
  for i := from to length(str) do
    if str[i] = searched then inc(result);
end;

function strCount(const str: RawByteString; const searched: TCharSet; from: longint): longint;
var
  i: LongInt;
begin
  result := 0;
  for i := from to length(str) do
    if str[i] in searched then inc(result);
end;


function strslice(const  first, last: pansichar): RawByteString;
begin
  result := '';
  if first>last then exit;
  SetLength(result,last-first+1);
  move(first^,result[1],length(result));
end;

procedure strlTrimLeft(var p: pansichar; var l: integer; const trimCharacters: TCharSet);
begin
  while (l > 0) and (p^ in trimCharacters) do begin
    inc(p);
    dec(l);
  end;
end;

procedure strlTrimRight(var p: pansichar; var l: integer; const trimCharacters: TCharSet);
begin
  while (l > 0) and (p[l-1] in trimCharacters) do
    dec(l);
end;

procedure strlTrim(var p: pansichar; var l: integer; const trimCharacters: TCharSet);
begin
  strlTrimLeft(p,l,trimCharacters);
  strlTrimRight(p,l,trimCharacters);
end;

type TStrTrimProcedure = procedure (var p: pansichar; var l: integer; const trimCharacters: TCharSet);

function strTrimCommon(const s: RawByteString; const trimCharacters: TCharSet; const trimProc: TStrTrimProcedure): RawByteString;
var p: pansichar;
    l: Integer;
    cutOffFront: integer;
begin
  result := s;
  l := length(Result);
  if l = 0 then exit;
  p := pansichar(pointer(result));
  trimProc(p, l, trimCharacters);
  if (p = pansichar(pointer(result))) and (l = length(result)) then exit;
  cutOffFront := p - pansichar(pointer(result));
  result := copy(result, 1 + cutOffFront, l);
end;

function strTrimLeft(const s: RawByteString; const trimCharacters: TCharSet): RawByteString;
begin
  result:=strTrimCommon(s, trimCharacters, @strlTrimLeft);
end;

function strTrimRight(const s: RawByteString; const trimCharacters: TCharSet): RawByteString;
begin
  result:=strTrimCommon(s, trimCharacters, @strlTrimRight);
end;

function strTrim(const s: RawByteString; const trimCharacters: TCharSet): RawByteString;
begin
  result:=strTrimCommon(s, trimCharacters, @strlTrim);
end;


function strTrimAndNormalize(const s: RawByteString; const trimCharacters: TCharSet
 ): RawByteString;
var i,j: integer;
begin
 result:=strTrim(s,trimCharacters);
 j:=1;
 for i:=1 to length(result) do begin
   if not (result[i] in trimCharacters)  then begin
     result[j]:=result[i];
     inc(j);
   end else if result[j-1] <> ' ' then begin
     result[j]:=' ';
     inc(j);
   end;
 end;
 if j -1 <> length(result) then
   setlength(result,j-1);
end;

function strNormalizeLineEndings(const s: RawByteString): RawByteString;
var
  i, p: Integer;
begin
  result := s;
  if s = '' then exit;
  p := 1;
  for i :=1 to length(result) - 1 do begin
    case result[i] of
      #13: begin
        result[p] := #10;
        if result[i + 1] = #10 then continue;
      end
      else result[p] := result[i];
    end;
    inc(p);
  end;
  case result[length(result)] of
    #13: result[p] := #10;
    else result[p] := result[length(result)];
  end;

  setlength(result, p{ + 1 - 1});
  {str := StringReplace(str, #13#10, #10, [rfReplaceAll]);
  sr := StringReplace(str, #13, #10, [rfReplaceAll]);}
end;

function strNormalizeLineEndingsUTF8(const s: RawByteString): RawByteString;
var
  i, p: Integer;
begin
  //utf 8 $2028 = e280a8, $85 = C285
  result := s;
  if s = '' then exit;
  p := 1;
  i := 1;
  while i <= length(result) do begin
    case result[i] of
      #13: begin
        result[p] := #10;
        if (i + 1 <= length(Result)) then
          case result[i + 1] of
            #10: inc(i);
            #$C2: if (i + 2 <= length(Result)) and (result[i + 2] = #$85)  then inc(i, 2);
          end;
      end;
      #$C2: begin
        result[p] := result[i];
        inc(i);
        if (i <= length(result)) then
          case result[i] of
            #$85: result[p] := #10;
            else begin
              inc(p);
              result[p] := result[i];
            end;
          end;
      end;
      #$E2: if (i + 2 <= length(result)) and (result[i + 1] = #$80) and (result[i + 2] = #$A8) then begin
        result[p] := #10;
        inc(i, 2);
      end else result[p] := result[i];
      else result[p] := result[i];
    end;
    inc(i);
    inc(p);
  end;

  setlength(result, p - 1)
end;

function strPrependIfMissing(const s: RawByteString; const expectedStart: RawByteString): RawByteString;
begin
  if strbeginswith(s, expectedStart) then result := s
  else result := expectedStart + s;
end;

function strAppendIfMissing(const s: RawByteString; const expectedEnd: RawByteString): RawByteString;
begin
  if strendswith(s, expectedEnd) then result := s
  else result := s + expectedEnd;
end;

function strSplitGet(const separator: RawByteString; var remainingPart: string): string;
begin
  strsplit(result,separator,remainingPart);
end;

procedure strSplit(out firstPart: string; const separator: RawByteString; var remainingPart: string);
var p:SizeInt;
begin
  p:=pos(separator,remainingPart);
  if p<=0 then begin
    firstPart:=remainingPart;
    remainingPart:='';
  end else begin
    firstPart:=copy(remainingPart,1,p-1);
    delete(remainingPart,1,p+length(separator)-1);
  end;
end;

function strWrapSplit(const Line: RawByteString; MaxCol: Integer; const BreakChars: TCharSet): TStringArray;
var i: integer;
    lastTextStart, lastBreakChance: integer;
    tempBreak: Integer;
begin
  result := nil;
  lastTextStart:=1;
  lastBreakChance:=0;
  for i := 1 to length(line) do begin
    if line[i] in [#13,#10] then begin
      if lastTextStart > i  then continue;
      arrayAdd(result, copy(Line,lastTextStart,i-lastTextStart));
      lastTextStart:=i+1;
      if (i < length(line)) and (line[i] <> line[i+1]) and (line[i+1] in [#13, #10]) then inc(lastTextStart);
    end;
    if (i < length(line)) and (line[i+1] in BreakChars) then begin
      lastBreakChance:=i+1;
      if lastTextStart = lastBreakChance then inc(lastTextStart); //merge seveal break characters into a single new line
    end;
    if i - lastTextStart + 1 >= MaxCol then begin
      if lastBreakChance >= lastTextStart then begin
        tempBreak := lastBreakChance;
        while (tempBreak > 1) and  (line[tempBreak-1] in BreakChars) do dec(tempBreak); //remove spaces before line wrap
        arrayAdd(result, copy(Line,lastTextStart,tempBreak-lastTextStart));
        lastTextStart:=lastBreakChance+1;
      end else begin
        arrayAdd(result, copy(Line, lastTextStart, MaxCol));
        lastTextStart:=i+1;
      end;
    end;
  end;
  if lastTextStart <= length(line) then arrayAdd(result, strcopyfrom(line, lastTextStart));
  if length(result) = 0 then arrayAdd(result, '');
end;

function strWrap(Line: RawByteString; MaxCol: Integer; const BreakChars: TCharSet): RawByteString;
begin
  result := strJoin(strWrapSplit(line, MaxCol, BreakChars), LineEnding);
end;

function strReverse(s: string): string;
var
  oldlen, charlen: Integer;
  len: sizeint;
  p: PChar;
  q: Pchar;
begin
  p := pointer(s);
  len := length(s);
  SetLength(result, len);
  q := pointer(result) + len;
  while len > 0 do begin
    oldlen := len;
    strDecodeUTF8Character(p, len);
    charlen := oldlen - len;
    q := q - charlen;
    move((p-charlen)^, q^, charlen);
  end;
end;

//Given a string like openBracket  .. openBracket  ... closingBracket closingBracket closingBracket closingBracket , this will return everything between
//the string start and the second last closingBracket (it assumes one bracket is already opened, so 3 open vs. 4 closing => second last).
//If updateText, it will replace text with everything after that closingBracket. (always excluding the bracket itself)
function strSplitGetUntilBracketClosing(var text: RawByteString; const openBracket, closingBracket: RawByteString; updateText: boolean): RawByteString;
var pos: integer;
  opened: Integer;
begin
  opened := 1;
  pos := 1;
  while (pos <= length(text)) and (opened >= 1) do begin
    if strlcomp(@text[pos], @openBracket[1], length(openBracket)) = 0 then begin
      inc(opened);
      inc(pos,  length(openBracket));
    end else if strlcomp(@text[pos], @closingBracket[1], length(closingBracket)) = 0 then begin
      dec(opened);
      inc(pos,  length(closingBracket));
    end else inc(pos);
  end;
  if opened < 1 then begin
    dec(pos);
    result := copy(text, 1, pos - length(closingBracket));
    if updateText then delete(text, 1, pos);
  end else begin
    result := text;
    if updateText then text := '';
  end;
end;

function strSplitGetBetweenBrackets(var text: RawByteString; const openBracket, closingBracket: RawByteString; updateText: boolean): RawByteString;
var
  start: SizeInt;
  temp: RawByteString;
begin
  start := pos(openBracket, text);
  if start = 0 then begin result := ''; exit; end;
  if updateText then begin
    delete(text, 1, start + length(openBracket) - 1);
    result := strSplitGetUntilBracketClosing(text, openBracket, closingBracket, updateText);
  end else begin
    temp := copy(text, start + length(openBracket), length(text));
    result := strSplitGetUntilBracketClosing(temp, openBracket, closingBracket, updateText);
  end;
end;

procedure strSplit(out splitted: TStringArray; s, sep: RawByteString; includeEmpty: boolean);
var p:longint;
    m: longint;
    reslen: longint;
begin
  SetLength(splitted,0);
  reslen := 0;
  if s='' then begin
    if includeEmpty then begin
      SetLength(splitted, 1);
      splitted[0] := '';
    end;
    exit;
  end;
  p:=pos(sep,s);
  m:=1;
  while p>0 do begin
    if p=m then begin
      if includeEmpty then
        arrayAddFast(splitted, reslen, '');
    end else
      arrayAddFast(splitted, reslen, copy(s,m,p-m));
    m:=p+length(sep);
    p:=strindexof(s, sep, m);
  end;
  if (m<>length(s)+1) or includeEmpty then
    arrayAddFast(splitted, reslen, strcopyfrom(s,m));
  SetLength(splitted, reslen);
end;

function strSplit(s, sep: RawByteString; includeEmpty: boolean): TStringArray;
begin
  strSplit(result, s, sep, includeEmpty);
end;

//based on wikipedia
function strLengthUtf8(str: RawByteString): longint;
var
  i: Integer;
begin
  result := 0;
  i := 1;
  while i <= length(str) do begin
    inc(result);
    case ord(str[i]) of
      $00..$7F: inc(i);
      $80..$BF: begin //in multibyte character (should never appear)
        inc(i);
        dec(result);
      end;
      $C0..$C1: inc(i, 2);  //invalid (two bytes used for single byte)
      $C2..$DF: inc(i, 2);
      $E0..$EF: inc(i, 3);
      $F0..$F4: inc(i, 4);
      $F5..$F7: inc(i, 4);  //not allowed after rfc3629
      $F8..$FB: inc(i, 5);  //"
      $FC..$FD: inc(i, 6);  //"
      $FE..$FF: inc(i); //invalid
    end;
  end;
end;

procedure strSwapEndianWord(str: PWord; countofword: SizeInt);  overload;
begin
  while countofword > 0 do begin
    PWord(str)^ := SwapEndian(PWord(str)^);
    inc(str);
    dec(countofword);
  end;
end;

procedure strSwapEndianWord(var str: RawByteString);     overload;
begin
  UniqueString(str);
  assert(length(str) and 1 = 0);
  strSwapEndianWord(pointer(str), length(str) div 2);
end;

procedure strSwapEndianDWord(str: PDWord; countofdword: SizeInt); overload;
begin
  while countofdword > 0 do begin
    PDWord(str)^ := SwapEndian(PDWord(str)^);
    inc(str);
    dec(countofdword);
  end;
end;

procedure strSwapEndianDWord(var str: RawByteString); overload;
begin
  UniqueString(str);
  assert(length(str) and 3 = 0);
  strSwapEndianDWord(pointer(str), length(str) div 4);
end;


function strConvertToUtf8FromUTF32N(str: RawByteString): RawByteString;
var i, reslen: Integer;
begin
  assert(length(str) and $3 = 0);
  i := 1;
  reslen := 0;
  while i <= length(str) - 3 do begin
    reslen := reslen + strGetUnicodeCharacterUTFLength(PDWord(@str[i])^);
    i := i + 4;
  end;

  SetLength(result, reslen);
  i := 1;
  reslen := 1;
  while i <= length(str) - 3 do begin
    strGetUnicodeCharacterUTF(PDWord(@str[i])^, @result[reslen]);
    reslen := reslen + strGetUnicodeCharacterUTFLength(PDWord(@str[i])^);
    i := i + 4;
  end;
end;


function strConvertToUtf8(str: RawByteString; from: TSystemCodePage): RawByteString;
var len: longint;
    reslen: longint;
    pos: longint;
    i: Integer;
begin
  if length(str) = 0 then begin result := ''; exit; end;
  from := strActualEncoding(from);
  //use my own conversion, because i found no existing source which doesn't relies on iconv
  //(AnsiToUtf8 doesn't work, since Ansi<>latin1)
  //edit: okay, now i found lconvencoding, but i let this here, because i don't want to change it again
  case from of
    CP_ACP, CP_NONE, CP_ASCII, CP_UTF8: result:=str;
    CP_WINDOWS1252, CP_LATIN1: begin //we actually use latin1, because unicode $00..$FF = latin-1 $00..$FF
      len:=length(str); //character and byte length of latin1-str
      //calculate length of resulting utf-8 string (gets larger)
      reslen:=len;
      for i:=1 to len do
        if str[i] >= #$80 then inc(reslen);
      //optimization
      if reslen = len then
        begin result := str; exit; end; //no special chars in str => utf-8=latin-8 => no conversion necessary
      //reserve string
      result := '';
      SetLength(result, reslen);
      pos:=1;
      for i:=1 to len do begin
        if str[i] < #$80 then
          //below $80: utf-8 = latin-1
          Result[pos]:=str[i]
        else begin
          //between $80.$FF: latin-1( abcdefgh ) = utf-8 ( 110000ab 10cdefgh )
          result[pos]:=chr($C0 or (ord(str[i]) shr 6));
          inc(pos);
          result[pos]:=chr($80 or (ord(str[i]) and $3F));
        end;
        inc(pos);
      end;
      assert(pos=reslen+1);
    end;
    {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF}: begin
      SetLength(result, (length(str) * 3) div 2);
      {$IFDEF FPC}
      i := UnicodeToUtf8(pointer(result), length(result) + 1, pointer(str), length(str) div 2);
      i := i - 1;
      {$ELSE}
      i := WideCharToMultiByte(CP_UTF8, 0, pointer(str), length(str) div 2, pointer(result), length(result), nil, nil);
      {$ENDIF}
      SetLength(result, max(i, 0));
    end;
    {$IFDEF ENDIAN_BIG}CP_UTF16{$ELSE}CP_UTF16BE{$ENDIF}: begin
      result := str;
      strSwapEndianWord(result);
      result := strConvertToUtf8(result, {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF});
    end;
    {$IFDEF ENDIAN_BIG}CP_UTF32BE{$ELSE}CP_UTF32{$ENDIF}: result := strConvertToUtf8FromUTF32N(str);
    {$IFDEF ENDIAN_BIG}CP_UTF32{$ELSE}CP_UTF32BE{$ENDIF}: begin
      result := str + '' {is this needed or not?};
      strSwapEndianDWord(result);
      result := strConvertToUtf8FromUTF32N(result);
    end
    else raise Exception.Create('Unknown encoding in strConvertToUtf8');
  end;
end;


function strConvertFromUtf8ToUTF32N(str: RawByteString): RawByteString;
var i, j: integer;
begin
  SetLength(result, strLengthUtf8(str) * 4);
  j := 1;
  i := 1;
  while i <= length(str) do begin
    PDWord(@result[j])^ := strDecodeUTF8Character(str, i);
    j := j + 4;
  end;
end;

function strConvertFromUtf8(str: RawByteString; toe: TSystemCodePage): RawByteString;
var len, reslen, i, pos: longint;
begin
  if str = '' then begin
    result := '';
    exit;
  end;
  toe := strActualEncoding(toe);
  case toe of
    CP_ACP, CP_NONE, CP_ASCII, CP_UTF8: result:=str;
    CP_WINDOWS1252, CP_LATIN1: begin //actually latin-1
      len:=length(str);//byte length
      reslen:=strLengthUtf8(str);//character len = new byte length
      //optimization
      if reslen = len then
        begin result := str; exit; end; //no special chars in str => utf-8=latin-8 => no conversion necessary
      //conversion
      result := '';
      SetLength(result,reslen);
      pos:=1;
      for i:=1 to reslen do begin
        //see strConvertToUtf8 for description
        if str[pos] <= #$7F then result[i]:=str[pos]
        else begin
          //between $80.$FF: latin-1( abcdefgh ) = utf-8 ( 110000ab 10cdefgh )
          result[i] := chr(((ord(str[pos]) and $3) shl 6) or (ord(str[pos+1]) and $3f));
          inc(pos);
        end;
        inc(pos);
      end ;
    end;
    {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF}: begin
      SetLength(result, length(str)*2);
      {$IFDEF FPC};
      i := Utf8ToUnicode(pointer(result), length(result), pointer(str), length(str));
      i := i - 1;
      {$ELSE}
      i := MultiByteToWideChar(CP_UTF8, 0, pointer(str), length(str), pointer(result), length(result) * 2);
      {$ENDIF}
      SetLength(result, max(i, 0) * 2);
    end;
    {$IFDEF ENDIAN_BIG}CP_UTF16{$ELSE}CP_UTF16BE{$ENDIF}: begin
      result := strConvertFromUtf8(str, {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF});
      strSwapEndianWord(result)
    end;
    {$IFDEF ENDIAN_BIG}CP_UTF32BE{$ELSE}CP_UTF32{$ENDIF}: result := strConvertFromUtf8ToUTF32N(str);
    {$IFDEF ENDIAN_BIG}CP_UTF32{$ELSE}CP_UTF32BE{$ENDIF}: begin
      result := strConvertFromUtf8ToUTF32N(str);
      strSwapEndianDWord(result);
    end
    else raise Exception.Create('Unknown encoding in strConvertFromUtf8');
  end;
end;

function strChangeEncoding(const str: RawByteString; from, toe: TSystemCodePage): RawByteString;
var utf8temp: RawByteString;
begin
  if (from=toe) or (from=CP_NONE) or (toe=CP_NONE) then begin result := str; exit; end;
  from := strActualEncoding(from);
  toe := strActualEncoding(toe);
  if (from=toe) then begin result := str; exit; end;

  //two pass encoding: from -> utf8 -> to
  utf8temp:=strConvertToUtf8(str, from);
  result:=strConvertFromUtf8(utf8temp, toe);

  {why did i use utf-8 as intermediate step (instead utf-16/ucs-2 like many others)?
   - in many cases I have string just containing the English alphabet where latin1=utf8,
     so this function will actually do nothing (except checking string lengths).
     But utf-16 would require additional memory in any case
   - I only convert between utf8-latin1 in the moment anyways, so just a single step is used
   - utf-8 can store all unicode pages (unlike the often used ucs-2)
  }
end;

function strDecodeUTF16Character(var source: PUnicodeChar): integer;
begin
  result := Ord(source^);
  inc(source);
  if result and $f800 = $d800 then begin
    //this might return nonsense, if the string ends with an incomplete surrogate
    //However, as the string should be 0-terminated, this should be safe
    result := ((result and $03ff) shl 10) or (ord(source^) and $03ff);
    inc(source);
    inc(result, $10000);
  end;
end;

function strDecodeUTF8Character(var source: PChar; var remainingLength: SizeInt): integer;
begin
  if remainingLength <= 0 then begin result := -2; exit; end;
  case ord(source^) of
    $00..$7F: begin
      result:=ord(source^);
      inc(source);
      dec(remainingLength);
    end;
    $80..$BF: begin //in multibyte character (should never appear)
      result:=-1;
      inc(source);
      dec(remainingLength);
    end;
    $C0..$C1: begin //invalid (two bytes used for single byte)
      result:=-1;
      inc(source, 2);
      dec(remainingLength, 2);
    end;
    $C2..$DF: begin
      if  remainingLength >= 2 then
        result := ((ord(source^) and not $C0) shl 6) or (ord(source[1]) and not $80)
      else
        result := -2;
      inc(source, 2);
      dec(remainingLength, 2);
    end;
    $E0..$EF: begin
      if  remainingLength >= 3 then
        result := ((ord(source^) and not $E0) shl 12) or ((ord(source[1]) and not $80) shl 6) or (ord(source[2]) and not $80)
      else
        result := -2;
       inc(source, 3);
      dec(remainingLength, 3);
    end;
    $F0..$F4: begin
      if  remainingLength >= 4 then
        result := ((ord(source^) and not $F0) shl 18) or ((ord(source[1]) and not $80) shl 12) or ((ord(source[2]) and not $80) shl 6) or (ord(source[3]) and not $80)
       else
        result := -2;
      inc(source, 4);
      dec(remainingLength, 4);
    end;
    else begin
      result:=-1;
      inc(source);
      dec(remainingLength);
    end;
    (* $F5..$F7: i := i + 4;  //not allowed after rfc3629
    $F8..$FB: i := i + 5;  //"
    $FC..$FD: i := i + 6;  //"
    $FE..$FF: inc(i); //invalid*)
  end;
end;

{$IFDEF fpc}
procedure strUnicode2AnsiMoveProc(source:punicodechar;var dest:RawByteString;cp : TSystemCodePage;len:SizeInt);
var
  destptr: PInteger;
  byteptr: PAnsiChar;
  temp, charlen: Integer;
  last: Pointer;
begin
  if len = 0 then begin
    dest := '';
    exit;
  end;
  case cp of
    CP_UTF16, CP_UTF16BE: begin
      SetLength(dest, 2*len);
      move(source^, dest[1], 2 * len);
      if cp <> {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF} then strSwapEndianWord(dest);
    end;
    CP_UTF32, CP_UTF32BE: begin
      SetLength(dest, 4*len);
      last := source + len;
      destptr := PInteger(@dest[1]);
      len := 0;
      while source < last do begin
        destptr^ := strDecodeUTF16Character(source);
        inc(destptr);
        inc(len);
      end;
      if 4 * len <> length(dest) then SetLength(dest, 4*len);
      if cp <> {$IFDEF ENDIAN_BIG}CP_UTF32BE{$ELSE}CP_UTF32{$ENDIF} then strSwapEndianDWord(dest);
    end;
    CP_WINDOWS1252, CP_LATIN1: begin
      SetLength(dest, len);
      last := source + len;
      byteptr := @dest[1];
      len := 0;
      while source < last do begin
        temp := strDecodeUTF16Character(source);
        if temp > 255 then byteptr^ := '?'
        else byteptr^ := chr(temp);
        inc(byteptr);
        inc(len);
      end;
      if len <> length(dest) then SetLength(dest, len);
     end
    else begin//default utf8
      SetLength(dest, len);
      last := source + len;
      byteptr := @dest[1];
      len := 0;
      while source < last do begin
        temp := strDecodeUTF16Character(source);
        charlen := strGetUnicodeCharacterUTFLength(temp);
        if len + charlen > length(dest) then begin
          SetLength(dest, max(charlen, 2 * length(dest)));
          byteptr := @dest[len+1];
        end;
        strGetUnicodeCharacterUTF(temp, byteptr);
        inc(byteptr, charlen);
        inc(len, charlen);
      end;
      if len <> length(dest) then SetLength(dest, len);
     end
  end;
  {$ifdef FPC_HAS_CPSTRING}SetCodePage(dest, cp, false);{$endif}
end;

procedure strAnsi2UnicodeMoveProc(source:pchar;cp : TSystemCodePage;var dest:unicodestring;len:SizeInt);
var
  outlen: SizeInt;

  procedure writeCodepoint(codepoint: integer);
  begin
    inc(outlen);
    if outlen > length(dest) then SetLength(dest, 2*length(dest));
    if codepoint <= $FFFF then dest[outlen] := WideChar(codepoint)
    else begin
       dec(codepoint, $10000);
       dest[outlen] := WideChar((codepoint shr 10) or %1101100000000000);
       inc(outlen);
       if outlen > length(dest) then SetLength(dest, 2*length(dest));
       dest[outlen] := WideChar((codepoint and %0000001111111111) or %1101110000000000);
    end;
  end;

var
  i: SizeInt;
begin
  dest := '';
  if len = 0 then exit;
  case cp of
    CP_UTF16, CP_UTF16BE: begin
      len := len - len and 1;
      if len = 0 then exit;
      SetLength(dest, len div 2);
      move(source^, dest[1], len);
      if cp <> {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF} then strSwapEndianWord(pointer(dest), length(dest));
    end;
    CP_UTF32, CP_UTF32BE: begin
      len := len - len and 3;
      if len = 0 then exit;
      SetLength(dest, len div 4);
      outlen := 0;
      if cp = {$IFDEF ENDIAN_BIG}CP_UTF32BE{$ELSE}CP_UTF32{$ENDIF} then begin
        for i := 1 to length(dest) do begin
          writeCodepoint(PInteger(source)^);
          inc(source, 4);
        end;
      end else begin
        for i := 1 to length(dest) do begin
          writeCodepoint(SwapEndian(PInteger(source)^));
          inc(source, 4);
        end;
      end;
      if outlen <> length(dest) then SetLength(dest, outlen);

    end;
    CP_UTF8: begin
      SetLength(dest, len);
      outlen := 0;
      while len > 0 do
         writeCodepoint(strDecodeUTF8Character(source, len));
      if outlen <> length(dest) then SetLength(dest, outlen);
     end
     else begin
       SetLength(dest, len);
       for i := 0 to len - 1 do
         dest[i+1] := widechar(byte(source[i]));
     end;
  end;
end;
{$endif}

function strGetUnicodeCharacterUTFLength(const character: integer): integer;
begin
  case character of
       $00 ..    $7F: result:=1;
       $80 ..   $7FF: result:=2;
      $800 ..  $FFFF: result:=3;
    $10000 ..$10FFFF: result:=4;
    else result := 0;
  end;
end;

procedure strGetUnicodeCharacterUTF(const character: integer; buffer: pansichar);
begin
  //result:=UnicodeToUTF8(character);
  case character of
       $00 ..    $7F: buffer[0]:=chr(character);
       $80 ..   $7FF: begin
         buffer[0] := chr($C0 or (character shr 6));
         buffer[1] := chr($80 or (character and $3F));
       end;
      $800 ..  $FFFF: begin
         buffer[0] := chr($E0 or (character shr 12));
         buffer[1] := chr($80 or ((character shr 6) and $3F));
         buffer[2] := chr($80 or (character and $3F));
      end;
    $10000 ..$10FFFF: begin
         buffer[0] := chr($F0 or (character shr 18));
         buffer[1] := chr($80 or ((character shr 12) and $3F));
         buffer[2] := chr($80 or ((character shr 6) and $3F));
         buffer[3] := chr($80 or (character and $3F));
    end;
  end;
end;

function strGetUnicodeCharacter(const character: integer; encoding: TSystemCodePage): RawByteString;
begin
  setlength(result, strGetUnicodeCharacterUTFLength(character));
  strGetUnicodeCharacterUTF(character, @result[1]);
  case encoding of
    CP_NONE, CP_UTF8: ;
    else result:=strConvertFromUtf8(result, encoding);
  end;
end;

function strDecodeUTF8Character(const str: RawByteString; var curpos: integer): integer;
begin
  if curpos > length(str) then begin result := -2; exit; end;
  case ord(str[curpos]) of
    $00..$7F: begin
      result:=ord(str[curpos]);
      inc(curpos);
    end;
    $80..$BF: begin //in multibyte character (should never appear)
      result:=-1;
      inc(curpos);
    end;
    $C0..$C1: begin //invalid (two bytes used for single byte)
      result:=-1;
      inc(curpos, 2);
    end;
    $C2..$DF: begin
      if curpos + 1  > length(str) then begin inc(curpos, 2); begin result := -2; exit; end; end;
      result := ((ord(str[curpos]) and not $C0) shl 6) or (ord(str[curpos+1]) and not $80);
      inc(curpos, 2);
    end;
    $E0..$EF: begin
      if curpos + 2  > length(str) then begin inc(curpos, 3); begin result := -2; exit; end; end;
      result := ((ord(str[curpos]) and not $E0) shl 12) or ((ord(str[curpos+1]) and not $80) shl 6) or (ord(str[curpos+2]) and not $80);
      inc(curpos, 3);
    end;
    $F0..$F4: begin
      if curpos + 3  > length(str) then begin inc(curpos, 4); begin result := -2; exit; end; end;
      result := ((ord(str[curpos]) and not $F0) shl 18) or ((ord(str[curpos+1]) and not $80) shl 12) or ((ord(str[curpos+2]) and not $80) shl 6) or (ord(str[curpos+3]) and not $80);
      inc(curpos, 4);
    end;
    else begin
      result:=-1;
      inc(curpos);
    end;
    (* $F5..$F7: i := i + 4;  //not allowed after rfc3629
    $F8..$FB: i := i + 5;  //"
    $FC..$FD: i := i + 6;  //"
    $FE..$FF: inc(i); //invalid*)
  end;
end;

{$IFDEF fpc}
function strEncodingFromName(str: RawByteString): TSystemCodePage;
begin
  case UpperCase(str) of
    'UTF-8', 'UTF8' {error preventive}, 'US-ASCII' {ascii is an utf-8 subset}: result:=CP_UTF8;
    'CP1252', 'ISO-8859-1', 'LATIN1', 'ISO-8859-15': Result:=CP_WINDOWS1252;
    'UTF-16': result := {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF};
    'UTF-16LE': result := CP_UTF16;
    'UTF-16BE': result := CP_UTF16BE;
    'UTF-32': result := {$IFDEF ENDIAN_BIG}CP_UTF32BE{$ELSE}CP_UTF32{$ENDIF};
    'UTF-32LE': result := CP_UTF32;
    'UTF-32BE': result := CP_UTF32BE;
    else result:=CP_NONE;
  end;
end;
{$ENDIF}
function strEncodingFromBOMRemove(var str: string): TSystemCodePage;
begin
  if strbeginswith(str,#$ef#$bb#$bf) then begin
    delete(str,1,3);
    result:=CP_UTF8;
  end else if strbeginswith(str,#$fe#$ff) then begin
    delete(str,1,2);
    result:=CP_UTF16BE;
  end else if strbeginswith(str,#$ff#$fe) then begin
    delete(str,1,2);
    result:=CP_UTF16;
  end else if strbeginswith(str,#00#00#$fe#$ff) then begin
    delete(str,1,4);
    result:=CP_UTF32BE;
  end else if strbeginswith(str,#$ff#$fe#00#00) then begin
    delete(str,1,4);
    result:=CP_UTF32;
  end else result := CP_NONE;
end;

function strUpperCaseSpecialUTF8(codePoint: integer): string;
const block: array[0..465] of byte = ( $53, $53, $46, $46, $46, $49, $46, $4C, $46, $46, $49, $46, $46, $4C, $53, $54, $53, $54, $D4, $B5, $D5, $92, $D5, $84, $D5, $86, $D5, $84, $D4, $B5, $D5, $84, $D4, $BB, $D5, $8E, $D5, $86, $D5, $84, $D4, $BD, $CA, $BC, $4E, $CE, $99, $CC, $88, $CC, $81, $CE, $A5, $CC, $88, $CC, $81, $4A, $CC, $8C, $48, $CC, $B1, $54, $CC, $88,
$57, $CC, $8A, $59, $CC, $8A, $41, $CA, $BE, $CE, $A5, $CC, $93, $CE, $A5, $CC, $93, $CC, $80, $CE, $A5, $CC, $93, $CC, $81, $CE, $A5, $CC, $93, $CD, $82, $CE, $91, $CD, $82, $CE, $97, $CD, $82, $CE, $99, $CC, $88, $CC, $80, $CE, $99, $CC, $88, $CC, $81, $CE, $99, $CD, $82, $CE, $99, $CC, $88, $CD, $82, $CE, $A5, $CC, $88, $CC, $80, $CE, $A5, $CC, $88, $CC, $81, $CE,
$A1, $CC, $93, $CE, $A5, $CD, $82, $CE, $A5, $CC, $88, $CD, $82, $CE, $A9, $CD, $82, $E1, $BC, $88, $CE, $99, $E1, $BC, $89, $CE, $99, $E1, $BC, $8A, $CE, $99, $E1, $BC, $8B, $CE, $99, $E1, $BC, $8C, $CE, $99, $E1, $BC, $8D, $CE, $99, $E1, $BC, $8E, $CE, $99, $E1, $BC, $8F, $CE, $99, $E1, $BC, $88, $CE, $99, $E1, $BC, $89, $CE, $99, $E1, $BC, $8A, $CE, $99, $E1, $BC,
$8B, $CE, $99, $E1, $BC, $8C, $CE, $99, $E1, $BC, $8D, $CE, $99, $E1, $BC, $8E, $CE, $99, $E1, $BC, $8F, $CE, $99, $E1, $BC, $A8, $CE, $99, $E1, $BC, $A9, $CE, $99, $E1, $BC, $AA, $CE, $99, $E1, $BC, $AB, $CE, $99, $E1, $BC, $AC, $CE, $99, $E1, $BC, $AD, $CE, $99, $E1, $BC, $AE, $CE, $99, $E1, $BC, $AF, $CE, $99, $E1, $BC, $A8, $CE, $99, $E1, $BC, $A9, $CE, $99, $E1,
$BC, $AA, $CE, $99, $E1, $BC, $AB, $CE, $99, $E1, $BC, $AC, $CE, $99, $E1, $BC, $AD, $CE, $99, $E1, $BC, $AE, $CE, $99, $E1, $BC, $AF, $CE, $99, $E1, $BD, $A8, $CE, $99, $E1, $BD, $A9, $CE, $99, $E1, $BD, $AA, $CE, $99, $E1, $BD, $AB, $CE, $99, $E1, $BD, $AC, $CE, $99, $E1, $BD, $AD, $CE, $99, $E1, $BD, $AE, $CE, $99, $E1, $BD, $AF, $CE, $99, $E1, $BD, $A8, $CE, $99,
$E1, $BD, $A9, $CE, $99, $E1, $BD, $AA, $CE, $99, $E1, $BD, $AB, $CE, $99, $E1, $BD, $AC, $CE, $99, $E1, $BD, $AD, $CE, $99, $E1, $BD, $AE, $CE, $99, $E1, $BD, $AF, $CE, $99, $CE, $91, $CE, $99, $CE, $91, $CE, $99, $CE, $97, $CE, $99, $CE, $97, $CE, $99, $CE, $A9, $CE, $99, $CE, $A9, $CE, $99, $E1, $BE, $BA, $CE, $99, $CE, $86, $CE, $99, $E1, $BF, $8A, $CE, $99, $CE,
$89, $CE, $99, $E1, $BF, $BA, $CE, $99, $CE, $8F, $CE, $99, $CE, $91, $CD, $82, $CE, $99, $CE, $97, $CD, $82, $CE, $99, $CE, $A9, $CD, $82, $CE, $99);
var special: integer;
begin
  special := 0;
  case codePoint of
    $00DF: special := $00000002; //ß 00DF; 00DF; 0053 0073; 0053 0053;
    $FB00: special := $00020002; //ﬀ FB00; FB00; 0046 0066; 0046 0046;
    $FB01: special := $00040002; //ﬁ FB01; FB01; 0046 0069; 0046 0049;
    $FB02: special := $00060002; //ﬂ FB02; FB02; 0046 006C; 0046 004C;
    $FB03: special := $00080003; //ﬃ FB03; FB03; 0046 0066 0069; 0046 0046 0049;
    $FB04: special := $000B0003; //ﬄ FB04; FB04; 0046 0066 006C; 0046 0046 004C;
    $FB05: special := $000E0002; //ﬅ FB05; FB05; 0053 0074; 0053 0054;
    $FB06: special := $00100002; //ﬆ FB06; FB06; 0053 0074; 0053 0054;
    $0587: special := $00120004; //և 0587; 0587; 0535 0582; 0535 0552;
    $FB13: special := $00160004; //ﬓ FB13; FB13; 0544 0576; 0544 0546;
    $FB14: special := $001A0004; //ﬔ FB14; FB14; 0544 0565; 0544 0535;
    $FB15: special := $001E0004; //ﬕ FB15; FB15; 0544 056B; 0544 053B;
    $FB16: special := $00220004; //ﬖ FB16; FB16; 054E 0576; 054E 0546;
    $FB17: special := $00260004; //ﬗ FB17; FB17; 0544 056D; 0544 053D;
    $0149: special := $002A0003; //ŉ 0149; 0149; 02BC 004E; 02BC 004E;
    $0390: special := $002D0006; //ΐ 0390; 0390; 0399 0308 0301; 0399 0308 0301;
    $03B0: special := $00330006; //ΰ 03B0; 03B0; 03A5 0308 0301; 03A5 0308 0301;
    $01F0: special := $00390003; //ǰ 01F0; 01F0; 004A 030C; 004A 030C;
    $1E96: special := $003C0003; //ẖ 1E96; 1E96; 0048 0331; 0048 0331;
    $1E97: special := $003F0003; //ẗ 1E97; 1E97; 0054 0308; 0054 0308;
    $1E98: special := $00420003; //ẘ 1E98; 1E98; 0057 030A; 0057 030A;
    $1E99: special := $00450003; //ẙ 1E99; 1E99; 0059 030A; 0059 030A;
    $1E9A: special := $00480003; //ẚ 1E9A; 1E9A; 0041 02BE; 0041 02BE;
    $1F50: special := $004B0004; //ὐ 1F50; 1F50; 03A5 0313; 03A5 0313;
    $1F52: special := $004F0006; //ὒ 1F52; 1F52; 03A5 0313 0300; 03A5 0313 0300;
    $1F54: special := $00550006; //ὔ 1F54; 1F54; 03A5 0313 0301; 03A5 0313 0301;
    $1F56: special := $005B0006; //ὖ 1F56; 1F56; 03A5 0313 0342; 03A5 0313 0342;
    $1FB6: special := $00610004; //ᾶ 1FB6; 1FB6; 0391 0342; 0391 0342;
    $1FC6: special := $00650004; //ῆ 1FC6; 1FC6; 0397 0342; 0397 0342;
    $1FD2: special := $00690006; //ῒ 1FD2; 1FD2; 0399 0308 0300; 0399 0308 0300;
    $1FD3: special := $006F0006; //ΐ 1FD3; 1FD3; 0399 0308 0301; 0399 0308 0301;
    $1FD6: special := $00750004; //ῖ 1FD6; 1FD6; 0399 0342; 0399 0342;
    $1FD7: special := $00790006; //ῗ 1FD7; 1FD7; 0399 0308 0342; 0399 0308 0342;
    $1FE2: special := $007F0006; //ῢ 1FE2; 1FE2; 03A5 0308 0300; 03A5 0308 0300;
    $1FE3: special := $00850006; //ΰ 1FE3; 1FE3; 03A5 0308 0301; 03A5 0308 0301;
    $1FE4: special := $008B0004; //ῤ 1FE4; 1FE4; 03A1 0313; 03A1 0313;
    $1FE6: special := $008F0004; //ῦ 1FE6; 1FE6; 03A5 0342; 03A5 0342;
    $1FE7: special := $00930006; //ῧ 1FE7; 1FE7; 03A5 0308 0342; 03A5 0308 0342;
    $1FF6: special := $00990004; //ῶ 1FF6; 1FF6; 03A9 0342; 03A9 0342;
    $1F80: special := $009D0005; //ᾀ 1F80; 1F80; 1F88; 1F08 0399;
    $1F81: special := $00A20005; //ᾁ 1F81; 1F81; 1F89; 1F09 0399;
    $1F82: special := $00A70005; //ᾂ 1F82; 1F82; 1F8A; 1F0A 0399;
    $1F83: special := $00AC0005; //ᾃ 1F83; 1F83; 1F8B; 1F0B 0399;
    $1F84: special := $00B10005; //ᾄ 1F84; 1F84; 1F8C; 1F0C 0399;
    $1F85: special := $00B60005; //ᾅ 1F85; 1F85; 1F8D; 1F0D 0399;
    $1F86: special := $00BB0005; //ᾆ 1F86; 1F86; 1F8E; 1F0E 0399;
    $1F87: special := $00C00005; //ᾇ 1F87; 1F87; 1F8F; 1F0F 0399;
    $1F88: special := $00C50005; //ᾈ 1F88; 1F80; 1F88; 1F08 0399;
    $1F89: special := $00CA0005; //ᾉ 1F89; 1F81; 1F89; 1F09 0399;
    $1F8A: special := $00CF0005; //ᾊ 1F8A; 1F82; 1F8A; 1F0A 0399;
    $1F8B: special := $00D40005; //ᾋ 1F8B; 1F83; 1F8B; 1F0B 0399;
    $1F8C: special := $00D90005; //ᾌ 1F8C; 1F84; 1F8C; 1F0C 0399;
    $1F8D: special := $00DE0005; //ᾍ 1F8D; 1F85; 1F8D; 1F0D 0399;
    $1F8E: special := $00E30005; //ᾎ 1F8E; 1F86; 1F8E; 1F0E 0399;
    $1F8F: special := $00E80005; //ᾏ 1F8F; 1F87; 1F8F; 1F0F 0399;
    $1F90: special := $00ED0005; //ᾐ 1F90; 1F90; 1F98; 1F28 0399;
    $1F91: special := $00F20005; //ᾑ 1F91; 1F91; 1F99; 1F29 0399;
    $1F92: special := $00F70005; //ᾒ 1F92; 1F92; 1F9A; 1F2A 0399;
    $1F93: special := $00FC0005; //ᾓ 1F93; 1F93; 1F9B; 1F2B 0399;
    $1F94: special := $01010005; //ᾔ 1F94; 1F94; 1F9C; 1F2C 0399;
    $1F95: special := $01060005; //ᾕ 1F95; 1F95; 1F9D; 1F2D 0399;
    $1F96: special := $010B0005; //ᾖ 1F96; 1F96; 1F9E; 1F2E 0399;
    $1F97: special := $01100005; //ᾗ 1F97; 1F97; 1F9F; 1F2F 0399;
    $1F98: special := $01150005; //ᾘ 1F98; 1F90; 1F98; 1F28 0399;
    $1F99: special := $011A0005; //ᾙ 1F99; 1F91; 1F99; 1F29 0399;
    $1F9A: special := $011F0005; //ᾚ 1F9A; 1F92; 1F9A; 1F2A 0399;
    $1F9B: special := $01240005; //ᾛ 1F9B; 1F93; 1F9B; 1F2B 0399;
    $1F9C: special := $01290005; //ᾜ 1F9C; 1F94; 1F9C; 1F2C 0399;
    $1F9D: special := $012E0005; //ᾝ 1F9D; 1F95; 1F9D; 1F2D 0399;
    $1F9E: special := $01330005; //ᾞ 1F9E; 1F96; 1F9E; 1F2E 0399;
    $1F9F: special := $01380005; //ᾟ 1F9F; 1F97; 1F9F; 1F2F 0399;
    $1FA0: special := $013D0005; //ᾠ 1FA0; 1FA0; 1FA8; 1F68 0399;
    $1FA1: special := $01420005; //ᾡ 1FA1; 1FA1; 1FA9; 1F69 0399;
    $1FA2: special := $01470005; //ᾢ 1FA2; 1FA2; 1FAA; 1F6A 0399;
    $1FA3: special := $014C0005; //ᾣ 1FA3; 1FA3; 1FAB; 1F6B 0399;
    $1FA4: special := $01510005; //ᾤ 1FA4; 1FA4; 1FAC; 1F6C 0399;
    $1FA5: special := $01560005; //ᾥ 1FA5; 1FA5; 1FAD; 1F6D 0399;
    $1FA6: special := $015B0005; //ᾦ 1FA6; 1FA6; 1FAE; 1F6E 0399;
    $1FA7: special := $01600005; //ᾧ 1FA7; 1FA7; 1FAF; 1F6F 0399;
    $1FA8: special := $01650005; //ᾨ 1FA8; 1FA0; 1FA8; 1F68 0399;
    $1FA9: special := $016A0005; //ᾩ 1FA9; 1FA1; 1FA9; 1F69 0399;
    $1FAA: special := $016F0005; //ᾪ 1FAA; 1FA2; 1FAA; 1F6A 0399;
    $1FAB: special := $01740005; //ᾫ 1FAB; 1FA3; 1FAB; 1F6B 0399;
    $1FAC: special := $01790005; //ᾬ 1FAC; 1FA4; 1FAC; 1F6C 0399;
    $1FAD: special := $017E0005; //ᾭ 1FAD; 1FA5; 1FAD; 1F6D 0399;
    $1FAE: special := $01830005; //ᾮ 1FAE; 1FA6; 1FAE; 1F6E 0399;
    $1FAF: special := $01880005; //ᾯ 1FAF; 1FA7; 1FAF; 1F6F 0399;
    $1FB3: special := $018D0004; //ᾳ 1FB3; 1FB3; 1FBC; 0391 0399;
    $1FBC: special := $01910004; //ᾼ 1FBC; 1FB3; 1FBC; 0391 0399;
    $1FC3: special := $01950004; //ῃ 1FC3; 1FC3; 1FCC; 0397 0399;
    $1FCC: special := $01990004; //ῌ 1FCC; 1FC3; 1FCC; 0397 0399;
    $1FF3: special := $019D0004; //ῳ 1FF3; 1FF3; 1FFC; 03A9 0399;
    $1FFC: special := $01A10004; //ῼ 1FFC; 1FF3; 1FFC; 03A9 0399;
    $1FB2: special := $01A50005; //ᾲ 1FB2; 1FB2; 1FBA 0345; 1FBA 0399;
    $1FB4: special := $01AA0004; //ᾴ 1FB4; 1FB4; 0386 0345; 0386 0399;
    $1FC2: special := $01AE0005; //ῂ 1FC2; 1FC2; 1FCA 0345; 1FCA 0399;
    $1FC4: special := $01B30004; //ῄ 1FC4; 1FC4; 0389 0345; 0389 0399;
    $1FF2: special := $01B70005; //ῲ 1FF2; 1FF2; 1FFA 0345; 1FFA 0399;
    $1FF4: special := $01BC0004; //ῴ 1FF4; 1FF4; 038F 0345; 038F 0399;
    $1FB7: special := $01C00006; //ᾷ 1FB7; 1FB7; 0391 0342 0345; 0391 0342 0399;
    $1FC7: special := $01C60006; //ῇ 1FC7; 1FC7; 0397 0342 0345; 0397 0342 0399;
    $1FF7: special := $01CC0006; //ῷ 1FF7; 1FF7; 03A9 0342 0345; 03A9 0342 0399;
  end;
  if special <> 0 then begin setlength(result, special and $FFFF); move(block[special shr 16], result[1], length(result)); end
  else result := strGetUnicodeCharacter(CodePoint);
end;

function strLowerCaseSpecialUTF8(codePoint: integer): string;
const block: array[0..83] of byte = ( $69, $CC, $87, $E1, $BE, $80, $E1, $BE, $81, $E1, $BE, $82, $E1, $BE, $83, $E1, $BE, $84, $E1, $BE, $85, $E1, $BE, $86, $E1, $BE, $87, $E1, $BE, $90, $E1, $BE, $91, $E1, $BE, $92, $E1, $BE, $93, $E1, $BE, $94, $E1, $BE, $95, $E1, $BE, $96, $E1, $BE, $97, $E1, $BE, $A0, $E1, $BE, $A1, $E1, $BE, $A2, $E1, $BE, $A3, $E1, $BE, $A4, $E1, $BE, $A5, $E1, $BE, $A6, $E1, $BE, $A7, $E1, $BE, $B3, $E1, $BF, $83, $E1, $BF, $B3);
var special: integer;
begin
  special := 0;
  case codePoint of
    $0130: special := $00000003; //İ 0130; 0069 0307; 0130; 0130;
    $1F88: special := $00030003; //ᾈ 1F88; 1F80; 1F88; 1F08 0399;
    $1F89: special := $00060003; //ᾉ 1F89; 1F81; 1F89; 1F09 0399;
    $1F8A: special := $00090003; //ᾊ 1F8A; 1F82; 1F8A; 1F0A 0399;
    $1F8B: special := $000C0003; //ᾋ 1F8B; 1F83; 1F8B; 1F0B 0399;
    $1F8C: special := $000F0003; //ᾌ 1F8C; 1F84; 1F8C; 1F0C 0399;
    $1F8D: special := $00120003; //ᾍ 1F8D; 1F85; 1F8D; 1F0D 0399;
    $1F8E: special := $00150003; //ᾎ 1F8E; 1F86; 1F8E; 1F0E 0399;
    $1F8F: special := $00180003; //ᾏ 1F8F; 1F87; 1F8F; 1F0F 0399;
    $1F98: special := $001B0003; //ᾘ 1F98; 1F90; 1F98; 1F28 0399;
    $1F99: special := $001E0003; //ᾙ 1F99; 1F91; 1F99; 1F29 0399;
    $1F9A: special := $00210003; //ᾚ 1F9A; 1F92; 1F9A; 1F2A 0399;
    $1F9B: special := $00240003; //ᾛ 1F9B; 1F93; 1F9B; 1F2B 0399;
    $1F9C: special := $00270003; //ᾜ 1F9C; 1F94; 1F9C; 1F2C 0399;
    $1F9D: special := $002A0003; //ᾝ 1F9D; 1F95; 1F9D; 1F2D 0399;
    $1F9E: special := $002D0003; //ᾞ 1F9E; 1F96; 1F9E; 1F2E 0399;
    $1F9F: special := $00300003; //ᾟ 1F9F; 1F97; 1F9F; 1F2F 0399;
    $1FA8: special := $00330003; //ᾨ 1FA8; 1FA0; 1FA8; 1F68 0399;
    $1FA9: special := $00360003; //ᾩ 1FA9; 1FA1; 1FA9; 1F69 0399;
    $1FAA: special := $00390003; //ᾪ 1FAA; 1FA2; 1FAA; 1F6A 0399;
    $1FAB: special := $003C0003; //ᾫ 1FAB; 1FA3; 1FAB; 1F6B 0399;
    $1FAC: special := $003F0003; //ᾬ 1FAC; 1FA4; 1FAC; 1F6C 0399;
    $1FAD: special := $00420003; //ᾭ 1FAD; 1FA5; 1FAD; 1F6D 0399;
    $1FAE: special := $00450003; //ᾮ 1FAE; 1FA6; 1FAE; 1F6E 0399;
    $1FAF: special := $00480003; //ᾯ 1FAF; 1FA7; 1FAF; 1F6F 0399;
    $1FBC: special := $004B0003; //ᾼ 1FBC; 1FB3; 1FBC; 0391 0399;
    $1FCC: special := $004E0003; //ῌ 1FCC; 1FC3; 1FCC; 0397 0399;
    $1FFC: special := $00510003; //ῼ 1FFC; 1FF3; 1FFC; 03A9 0399;
  end;
  if special <> 0 then begin setlength(result, special and $FFFF); move(block[special shr 16], result[1], length(result)); end
  else result := strGetUnicodeCharacter(CodePoint);
end;


function strEscape(s: RawByteString; const toEscape: TCharSet; escapeChar: ansichar): RawByteString;
var
 i: Integer;
begin
  result := '';
  if length(s) = 0 then exit;
  for i:=1 to length(s) do begin
    if s[i] in toEscape then result := result +  escapeChar;
    result := result +  s[i];
  end;
end;

function strEscapeToHex(s:RawByteString; const toEscape: TCharSet; escape: RawByteString): RawByteString;
var
  p: Integer;
  i: Integer;
  temp: String;
  escapeCount: integer;
  escapeP: pansichar;
begin
  result := s;
  escapeCount := strCount(s, toEscape);
  if escapeCount = 0 then exit
  else if length(s) = 0 then exit;

  if length(escape) > 0 then escapeP := @escape[1]
  else escapeP := @s[1]; //value is not used, but

  SetLength(result, length(s) + escapeCount * ( 2 + length(escape) - 1 ));
  p := 1;
  for i := 1 to length(s) do
    if not (s[i] in toEscape) then begin
      result[p] := s[i];
      inc(p);
    end else begin
      move(escapeP^, result[p], length(escape));
      inc(p, length(escape));
      temp := IntToHex(ord(s[i]), 2);
      move(temp[1], result[p], 2);
      inc(p, 2);
    end;
  //setlength(result, p-1);
end;

function strUnescapeHex(s: RawByteString; escape: RawByteString): RawByteString;
var
  f, t: Integer;
  start: Integer;
  last: Integer;
begin
  if escape = '' then begin
    result := strDecodeHex(s);
    exit;
  end;
  start := pos(escape, s);
  if start <= 0 then begin
    result := s;
    exit;
  end;
  SetLength(result, length(s));
  move(s[1], result[1], start-1);
  f := start;
  t := start;
  last := length(s) - length(escape) + 1 - 2;
  while f <= last do begin
    if strlsequal(@s[f], pchar(escape), length(escape)) then begin
      inc(f, length(escape));
      result[t] := chr(charDecodeHexDigit(s[f]) shl 4 or charDecodeHexDigit(s[f+1]));
      inc(f, 2);
      inc(t, 1);
    end else begin
      result[t] := s[f];
      inc(f, 1);
      inc(t, 1);
    end;
  end;
  if (f > last) and (f <= length(s)) then begin
    move(s[f], result[t], length(s) - f + 1);
    inc(t, length(s) - f + 1);
  end;
  SetLength(result, t-1);
end;

function strEscapeRegex(const s: RawByteString): RawByteString;
begin
  result := strEscape(s, ['(','|', '.', '*', '?', '^', '$', '-', '[', '{', '}', ']', ')', '\'], '\');
end;

function strDecodeHTMLEntities(s: RawByteString; encoding: TSystemCodePage; strict: boolean): string;
begin
  result:=strDecodeHTMLEntities(pansichar(s), length(s), encoding, strict);
end;

function strDecodeHex(s: RawByteString): RawByteString;
var
  i: Integer;
begin
  assert(length(s) and 1 = 0);
  result := '';
  setlength(result, length(s) div 2);
  for i:=1 to length(result) do
    result[i] := chr((charDecodeHexDigit(s[2*i-1]) shl 4) or charDecodeHexDigit(s[2*i]));
end;

function strEncodeHex(s: RawByteString; const code: RawByteString): RawByteString;
var
  o: Integer;
  pcode: pansichar;
  i: Integer;
begin
  assert(length(code) = 16);
  pcode := @code[1];
  result := '';
  setlength(result, length(s) * 2);
  for i:=1 to length(s) do begin
    o := ord(s[i]);
    result[2*i - 1] := pcode[o shr 4];
    result[2*i    ] := pcode[o and $F];
  end;
end;

function strFromPchar(p: pansichar; l: longint): RawByteString;
begin
  if l=0 then begin result := ''; exit; end;
  result := '';
  setlength(result,l);
  move(p^,result[1],l);
end;

function strBeforeLast(const s: RawByteString; const sep: TCharSet): RawByteString;
var i: Integer;
begin
  i := strLastIndexOf(s, sep);
  if i = 0 then result := ''
  else result := copy(s, 1, i-1);
end;

function strAfterLast(const s: RawByteString; const sep: TCharSet): RawByteString;
var
  i: Integer;
begin
  i := strLastIndexOf(s, sep);
  if i = 0 then result := ''
  else result := strcopyfrom(s, i + 1);
end;




function strJoin(const sl: TStrings; const sep: RawByteString  = ', '; limit: Integer=0; const limitStr: RawByteString='...'): RawByteString; overload;
var i:longint;
begin
  Result:='';
  if sl.Count=0 then exit;
  result:=sl[0];
  if (limit = 0) or (sl.count <= abs(limit)) then begin
    for i:=1 to sl.Count-1 do
      result := result + sep+sl[i];
  end else if limit > 0 then begin
    for i:=1 to limit-1 do
      result := result + sep+sl[i];
    result := result + limitStr;
  end else begin
    for i:=1 to (-limit-1) div 2 do
      result := result + sep+sl[i];
    result := result + sep+limitStr;
    for i:=sl.Count - (-limit) div 2 to sl.Count-1 do
      result := result + sep+sl[i];
  end;
end;


function strJoin(const sl: TStringArray; const sep: RawByteString = ', '; limit: Integer = 0;
 const limitStr: RawByteString = '...'): RawByteString; overload;
var i:longint;
begin
  Result:='';
  if length(sl)=0 then exit;
  result:=sl[0];
  if (limit = 0) or (length(sl) <= abs(limit)) then begin
    for i:=1 to high(sl) do
      result := result + sep+sl[i];
  end else if limit > 0 then begin
    for i:=1 to limit-1 do
      result := result + sep+sl[i];
    result := result + limitStr;
  end else begin
    for i:=1 to (-limit-1) div 2 do
      result := result + sep+sl[i];
    result := result + sep+limitStr;
    for i:=length(sl) - (-limit) div 2 to high(sl) do
      result := result + sep+sl[i];
  end;
end;


function StrToBoolDef(const S: RawByteString;const Def:Boolean): Boolean;

Var
  foundDot, foundExp: boolean;
  i: Integer;
begin
  if s = '' then
    result := def //good idea? probably for StrToBoolDef(@attribute, def) and if @attribute is missing (=> '') it should def
  else if striequal(S, 'TRUE') then
    result:=true
  else if striequal(S, 'FALSE') then
    result:=false
  else begin
    i := 1;
    if s[i] in ['-', '+'] then inc(i);
    foundDot := false; foundExp := false;
    result := def;
    while i <= length(s) do begin
      case s[i] of
        '.': if foundDot then exit else foundDot := true;
        'e', 'E': if foundExp then exit else begin
          foundExp := true;
          if i < length(s) then if s[i+1] in ['+', '-'] then inc(i);
        end;
        '0': ;
        '1'..'9': if not foundExp then begin result := true; exit; end;
        else exit;
      end;
      inc(i);
    end;
    result := false;
  end;
end;

function strRemoveFileURLPrefix(const filename: RawByteString): RawByteString;
begin
  result := filename;

  if not stribeginswith(result, 'file://') then
    begin result := result; exit; end;

  delete(result, 1, 7);
  if (length(result) >= 4) and (result[1] = '/') and (result[3] = ':') and (result[4] = '\') then
    delete(result, 1, 1); //Windows like file:///C:\abc\def url
end;

function strLoadFromFile(filename: RawByteString): RawByteString;
var f:TFileStream;
begin
  f:=TFileStream.Create(strRemoveFileURLPrefix(filename),fmOpenRead);
  result := '';
  SetLength(result,f.Size);
  if f.size>0 then
    f.Read(Result[1],length(result));
  f.Free;
end;

type PRawByteString = ^RawByteString;
procedure strSaveToFileCallback(stream: TStream; data: pointer);
begin
  stream.Write(PRawByteString(data)^[1], length(PRawByteString(data)^));
end;

procedure strSaveToFile(filename: RawByteString;str:RawByteString);
var f:TFileStream;
begin
  filename := strRemoveFileURLPrefix(filename);
  if length(str) = 0 then begin
    f:=TFileStream.Create(filename,fmCreate);
    f.free;
  end else
    fileSaveSafe(filename, @strSaveToFileCallback, @str);
end;

{$IFNDEF FPC}
var codePage: integer = -1;
function UTF8ToAnsi(const s: RawByteString): RawByteString;
var temp: RawByteString;
    tempws: WideString;
begin
  if s = '' then exit;
  if codePage = -1 then codePage := getACP;
  if codePage = CP_UTF8 then result := s
  else if (codePage = {CP_LATIN1} 28591) or (codePage = 1252) then result := strConvertFromUtf8(s, eWindows1252)
  else begin
    temp := strConvertFromUtf8(s, {$IFDEF ENDIAN_BIG}CP_UTF16BE{$ELSE}CP_UTF16{$ENDIF});
    setlength(tempws, (length(temp) + 1) div 2);
    move(s[1], tempws[1], length(temp));
    result := AnsiString(tempws); //todo
  end;
end;
{$ENDIF}

function utf8toSys(const filename: RawByteString): RawByteString;
begin
  result := filename;
  {$IFnDEF FPC_HAS_CPSTRING}{$ifdef windows}
   result :=  Utf8ToAnsi(result);
  {$endif}{$endif}
end;

function strLoadFromFileUTF8(filename: RawByteString): RawByteString;
begin
  result:=strLoadFromFile(utf8toSys(filename));
end;

procedure strSaveToFileUTF8(filename: RawByteString; str: RawByteString);
begin
  strSaveToFile(utf8toSys(filename),str);
end;

function strFromSize(size: int64): string;
const iec: string='KMGTPEZY';
var res: int64;
    i:longint;
begin
  i:=0;
  res := 0;
  while (i<=length(iec)) and (size>=2048) do begin
    res:=size mod 1024;
    size:=size div 1024;
    inc(i);
  end;
  if i=0 then result:=IntToStr(size)+' B'
  else result:=format('%4f ',[size+res/1024])+iec[i]+'iB';
end;

function strFromPtr(p: pointer): RawByteString;
begin
  result:=IntToHex(PtrUInt(p), 2*sizeof(Pointer));
end;

function strFromInt(i: int64; displayLength: longint): RawByteString;
begin
  if i < 0 then begin result := '-'+strFromInt(-i, displayLength); exit; end;
  result := IntToStr(i);
  if length(result) < (displayLength) then
    result := strDup('0', (displayLength) - length(Result)) + result;
end;

//case-sensitive, intelligent string compare (splits in text, number parts)
function strCompareClever(const s1, s2: RawByteString): integer;
var t1,t2:RawByteString; //lowercase text
    i,j,ib,jb,p: longint;
    iz, jz: longint;
begin
  result:=0;
  t1 := s1;
  t2 := s2;
  i:=1;
  j:=1;
  while (i<=length(t1)) and (j<=length(t2)) do begin
    if (t1[i] in ['0'..'9']) and (t2[j] in ['0'..'9']) then begin
      iz := i;
      jz := j;
      while (i<=length(t1)) and (t1[i] = '0') do inc(i);
      while (j<=length(t2)) and (t2[j] = '0') do inc(j);
      ib:=i;
      jb:=j;
      while (i<=length(t1)) and (t1[i] in ['0'..'9']) do inc(i);
      while (j<=length(t2)) and (t2[j] in ['0'..'9']) do inc(j);
      if i-ib<>j-jb then begin
        result:=sign(i-ib - (j-jb)); //find longer number
        exit;
      end;
      for p:=0 to i-ib-1 do //numerical == lexical
        if t1[ib+p]<>t2[jb+p] then begin
          result:=sign(ord(t1[ib+p]) - ord(t2[jb+p]));
          exit;
        end;
      if result = 0 then result := sign ( i - iz - (j - jz) );
    end else begin
      if t1[i]<>t2[j] then begin
        result:=sign(ord(t1[i]) - ord(t2[j]));
        exit;
      end;
      inc(i);
      inc(j);
    end;
  end;
  if result = 0 then
    result:=sign(length(t1) - length(t2));
end;

function striCompareClever(const s1, s2: RawByteString): integer;
begin
  result := strCompareClever(lowercase(s1), lowercase(s2)); //todo optimize
end;

function strDup(rep: RawByteString; const count: integer): RawByteString;
var
  i: Integer;
begin
  result := '';
  for i:=1 to count do
    result := result + rep;
end;

function strIsAbsoluteURI(const s: RawByteString): boolean;
var
  p: SizeInt;
  i: Integer;
begin
  result := false;
  if s = '' then exit;
  if not (s[1] in ['A'..'Z','a'..'z']) then exit;
  p := pos(':', s);
  if (p = 0) or (p + 2 > length(s)) then exit;
  for i:=2 to p-1 do
    if not (s[i] in ['A'..'Z','a'..'z','0'..'9','+','-','.']) then exit;
  if (s[p+1] <> '/') or (s[p+2] <> '/') then exit;
  result := true;
end;

function strResolveURIReal(rel, base: RawByteString): RawByteString;  //base must be an absolute uri
  function isWindowsFileUrl(): boolean;
  begin
    result := stribeginswith(base, 'file:///') and (length(base) >= 11) and (base[10] = ':') and (base[11] in ['/', '\']);
  end;

var
  schemeLength: SizeInt;
  p: SizeInt;
  relsplit, basesplit: TStringArray;
  i: Integer;
  relparams: RawByteString;
begin
  p := pos('#', base);
  if p > 0 then delete(base, p, length(base) - p + 1);
  p := pos('?', base);
  if p > 0 then delete(base, p, length(base) - p + 1);
  schemeLength := pos(':', base); inc(schemeLength);
  if (schemeLength <= length(base)) and (base[schemeLength] = '/') then inc(schemeLength);
  if (schemeLength <= length(base)) and (base[schemeLength] = '/') then inc(schemeLength);
  if strBeginsWith(rel, '/') then begin
    if isWindowsFileUrl() then  //Windows file:///c:/ special case
      schemeLength := schemeLength +  3;
    p := strIndexOf(base, '/', schemeLength);
    delete(base, p, length(base) - p + 1);
    begin result := base+rel; exit; end;
  end;
  p := pos('#', rel);
  if p > 0 then begin relparams:=strCopyFrom(rel, p); delete(rel, p, length(rel) - p + 1);end else relparams := '';
  p := pos('?', rel);
  if p > 0 then begin relparams:=strCopyFrom(rel, p) + relparams; delete(rel, p, length(rel) - p + 1);end;
  if rel = '' then begin result := base + relparams; exit; end;
  relsplit:=strSplit(rel, '/');
  basesplit:=strSplit(strCopyFrom(base,schemeLength),'/');
  basesplit[0] := copy(base,1,schemeLength-1) + basesplit[0];
  if isWindowsFileUrl() then begin basesplit[0] := basesplit[0] + '/' + basesplit[1]; arrayDelete(basesplit, 1); end;
  for i:=high(relsplit) downto 0 do if relsplit[i] = '.' then arrayDelete(relsplit, i);

  if (length(basesplit) > 1) then SetLength(basesplit, high(basesplit));

  if (length(relsplit) > 0) and (relsplit[high(relsplit)] <> '')  and (relsplit[high(relsplit)] <> '.') and (relsplit[high(relsplit)] <> '..') then begin
    relparams:=relsplit[high(relsplit)] + relparams;
    setlength(relsplit, high(relsplit));
  end;

  for i:=0 to high(relsplit)  do begin
    if (relsplit[i] = '') or (relsplit[i] = '.') then continue;
    if relsplit[i] = '..' then begin
      if length(basesplit) > 1 then SetLength(basesplit, length(basesplit) - 1);
      continue;
    end;
    arrayAdd(basesplit, relsplit[i]);
  end;
  result := strJoin(basesplit, '/') + '/' + relparams;
end;


function strResolveURI(rel, base: RawByteString): RawByteString;
  function strIsRelative(const r: RawByteString): boolean; //this is weird, but the XQTS3 has "non-hierarchical uris" as test case for fn:resolve-urih
  var
    i: Integer;
  begin
    result := true;
    for i := 1 to length(r) do
      case r[i] of
        'a'..'z','A'..'Z','0'..'9': ; //keep going
        ':': begin result := false; exit; end;
        else exit;
       // '?','/': exit;
      end;
  end;

var
  schemaLength: SizeInt;
  baseIsAbsolute: Boolean;
  fileSchemaPrefixLength: Integer;
  returnBackslashes: Boolean;
  i: Integer;
begin
  if not strIsRelative(rel) or (base = '') then begin result := rel; exit; end;

  fileSchemaPrefixLength := 0;
  if stribeginswith(base, 'file:///') then fileSchemaPrefixLength := 8
  else if stribeginswith(base, 'file://') then fileSchemaPrefixLength := 7;

  if (length(base) >= fileSchemaPrefixLength + 3)
      and (base[fileSchemaPrefixLength + 2] = ':')
      and (base[fileSchemaPrefixLength + 3] in ['/', '\'])
      and ((length(base) = fileSchemaPrefixLength + 3) or (base[fileSchemaPrefixLength + 4] <> '/')) then begin
      //windows file path
      //normalize: start with file:/// and use slashes instead backslashes
      if (fileSchemaPrefixLength <> 8) then begin
        delete(base, 1, fileSchemaPrefixLength);
        base := 'file:///' + base;
      end;
      rel := StringReplace(rel, '\', '/', [rfReplaceAll]);
      returnBackslashes := pos('\', base) > 0;
      if returnBackslashes then base := StringReplace(base, '\', '/', [rfReplaceAll]);

      result := strResolveURIReal(rel, base);

      //denormalize to return the same format as the original base
      if returnBackslashes then for i := 9 to length(result) do if result[i] = '/' then result[i] := '\'; //skip file:///
      case fileSchemaPrefixLength of
        0: result := strcopyfrom(result, length('file:///') + 1); // c:\...
        7: result := 'file://' + strcopyfrom(result, length('file:///') + 1); // file://c:\...
        else ; // file:///c:\...
      end;
      exit;
  end;

  schemaLength := pos(':', base);
  if (schemaLength = 0)  or (pos('/', base) < schemaLength)  {no schema}    then begin
     baseIsAbsolute := strbeginswith(base, '/');
     if baseIsAbsolute then base := 'file://' + base
     else base := 'file:///' + base;
     result := strResolveURIReal(rel, base);
     if baseIsAbsolute or strbeginswith(rel, '/')  then
       result := strcopyfrom(result, length('file:///'))
      else
       result := strcopyfrom(result, length('file:///') + 1);
     exit;
  end;

  if strbeginswith(rel, '//') and (schemaLength > 0) then
    result := copy(base, 1, schemaLength) + rel //protocol relative uri
  else
    result := strResolveURIReal(rel, base);
end;
{$IFnDEF fpc}
const AllowDirectorySeparators=['/','\'];
{$endif}

function fileNameExpand(const rel: string): string;
begin
  result := rel;
  if strContains(rel, '://') then exit;
  if rel = '' then exit;
  if rel[1] in AllowDirectorySeparators then exit;
  if (length(rel) >= 3) and (rel[2] = ':') and (rel[3] in AllowDirectorySeparators) then exit;
  result := ExpandFileName(rel)
end;

function fileNameExpandToURI(const rel: string): string;
begin
  result := fileNameExpand(rel);
  if strContains(rel, '://') then exit;
  result := 'file://' + result;
end;

function fileMoveReplace(const oldname, newname: string): boolean;
{$IFDEF WINDOWS}
var o,n: UnicodeString;
{$EndIf}
begin
  {$IFDEF WINDOWS}
  o := UnicodeString(oldname);
  n := UnicodeString(newname);
  result := MoveFileExW(PWideChar(o), PWideChar(n), MOVEFILE_REPLACE_EXISTING or MOVEFILE_COPY_ALLOWED);
  {$ELSE}
  result := RenameFile(oldname, newname);
  {$ENDIF}
end;

procedure fileSaveSafe(filename: string; callback: TFileSaveSafe; data: pointer);
var f:TFileStream;
  tmpfilename: string;
begin
  filename := strRemoveFileURLPrefix(filename);
  tmpfilename := filename;
  while FileExists(tmpfilename) do
    tmpfilename := filename + '~' + IntToStr(Random(1000000))+'.tmp';

  f:=TFileStream.Create(tmpfilename,fmCreate);
  callback(f,data);
  f.Free;
  if tmpfilename <> filename then begin
    if not fileMoveReplace(tmpfilename, filename) then
      SysUtils.DeleteFile(tmpfilename);
  end;
end;




function strSimilarity(const s, t: RawByteString): integer;
//see http://en.wikipedia.org/wiki/Levenshtein_distance
var v: array[0..1] of array of integer;
  i,j : Integer;
  cost, v0, v1: Integer;
begin
  if s = t then begin result := 0; exit; end;
  if s = '' then begin result := length(t); exit; end;
  if t = '' then begin result := length(s); exit; end;

  // create two work vectors of integer distances
  setlength(v[0], length(t) + 1);
  setlength(v[1], length(t) + 1);

  for i := 0 to high(v[0]) do
    v[0,i] := i;

  v0 := 0;
  v1 := 1;

  for i := 1 to length(s) do begin
    v[v1,0] := i + 1;

    for j := 1 to length(t) do begin
      if s[i] = t[j] then cost := 0
      else cost := 1;
      v[v1,j] := min(v[v1,j-1] + 1, min(v[v0,j] + 1, v[v0,j-1] + cost));
    end;

    v0 := 1 - v0;
    v1 := 1 - v1;
  end;

  result := v[v1, length(t)];
end;



{$ifdef fpc}
function TStrIterator.MoveNext: Boolean;
begin
  result := pos <= length(s);
  fcurrent := strDecodeUTF8Character(s, pos);
end;

function TStrIterator.GetEnumerator: TStrIterator;
begin
  result := self;
end;

function strIterator(const s: RawByteString): TStrIterator;
begin
  result.s := s;
  result.pos := 1;
end;

procedure TStrBuilder.init(abuffer:pstring; basecapacity: integer);
begin
  buffer := abuffer;
  SetLength(buffer^, basecapacity); //need to create a new string to prevent aliasing
  //if length(buffer^) < basecapacity then
  //else UniqueString(buffer^);    //or could uniquestring be enough?

  next := pchar(buffer^);
  bufferend := next + length(buffer^);
end;

procedure TStrBuilder.final;
begin
  if next <> bufferend then begin
    setlength(buffer^, count);
    next := pchar(buffer^) + length(buffer^);
    bufferend := next;
  end;
end;

function TStrBuilder.count: integer;
begin
  result := next - pointer(buffer^);
end;

procedure TStrBuilder.reserveadd(delta: integer);
var
  oldlen: Integer;
begin
  if next + delta > bufferend then begin
    oldlen := count;
    SetLength(buffer^, max(2*length(buffer^), oldlen + delta));
    next := pchar(buffer^) + oldlen;
    bufferend := pchar(buffer^) + length(buffer^);
  end;
end;

procedure TStrBuilder.add(c: char);
begin
  if next >= bufferend then reserveadd(1);
  next^ := c;
  inc(next);
end;

procedure TStrBuilder.add(const s: string);
var
  l: sizeint;
begin
  l := length(s);
  if l = 0 then exit;
  if next + l > bufferend then reserveadd(l);
  move(pchar(pointer(s))^, next^, l);
  inc(next, l);
end;

procedure TStrBuilder.add(const codepoint: integer);
var
  l: sizeint;
begin
  l := strGetUnicodeCharacterUTFLength(codepoint);
  if next + l > bufferend then reserveadd(l);
  strGetUnicodeCharacterUTF(codepoint, next);
  inc(next, l);
end;

procedure TStrBuilder.add(const p: pchar; const l: integer); inline;
begin
  if l <= 0 then exit;
  if next + l > bufferend then reserveadd(l);
  move(p^, next^, l);
  inc(next, l);
end;

function charEncodeHexDigitUp(digit: integer): char;
begin
  case digit of
    0..9: result := chr(ord('0') + digit);
    $A..$F: result := chr(ord('A') - $A + digit);
    else begin assert(false); result := #0; end;
  end;
end;

procedure TStrBuilder.addhexentity(codepoint: integer);
begin
  add('&#x');
  if codepoint <= $FF then begin
    if codepoint > $F then add(charEncodeHexDigitUp( codepoint shr 4 ));
    add(charEncodeHexDigitUp(  codepoint and $F ))
  end else addhexnumber(codepoint);
  add(';');
end;

procedure TStrBuilder.addhexnumber(codepoint: integer);
var
  digits: Integer;
begin
  digits := 1;
  while codepoint shr (4 * digits) > 0 do inc(digits);
  add(IntToHex(codepoint, digits));
end;

{$endif}


{$IFNDEF FPC}
function SwapEndian(const w: Word): Word;
//aabb => bbaa
begin
  result := Word((w shl 8) or (w shr 8));
end;

function SwapEndian(const w: DWord): DWord;
//aabbccdd => ddccbbaa
var w1, w2: word;
begin
  w1 := Word(w shr 16);
  w2 := Word(w);
  result := (Word((w2 shl 8) or (w2 shr 8)) shl 16)
          or Word((w1 shl 8) or (w1 shr 8));
end;
{$ENDIF}




function intLog10(i: longint): longint;
begin
  result:=0;
  while i >=10 do begin
    inc(result);
    i:=i div 10;
  end;
end;

function intLog(n, b: longint): longint;
begin
  result:=0;
  while n >=b do begin
    inc(result);
    n:=n div b;
  end;
end;

{procedure intFactor(const n, p: longint; out e, r: longint);
var pe, pold: longint;
begin
  r := n;
  e := 0;
  if r mod p <> 0 then exit;

  pold := p;
  pe := p * p;
  e := 1;
  while (r mod pe = 0)  do begin
    e := e * 2;
    if (pe >= $ffff) then break;
    pold := pe;
    pe := pe * pe;
  end;

  pe := pold * p;
  while r mod pe = 0 do begin
    inc(e);
    pold := pe;
    pe := pe * p;
  end;

  r := n div pold;
end;             }

{$IFNDEF FPC}
procedure DivMod(const a, b: integer; out res, modulo: integer);
begin
  res := a div b;
  modulo := a - res * b;
end;
{$ENDIF}

procedure intFactor(const n, p: longint; out e, r: longint);
var
  m: Integer;
  d: Integer;
begin
  r := n;
  e := 0;
  d := 0;
  m := 0;
  DivMod(r,p,d,m);
  while m = 0 do begin
    r := d;
    DivMod(r,p,d,m);
    inc(e);
  end;
end;

function gcd(a, b: integer): integer;
begin
  if b<a then result := gcd(b,a)
  else if a=0 then result := b
  else if a=b then result := a
  else result:=gcd(b mod a, a);
end;

function gcd(a, b: cardinal): cardinal;
begin
  if b<a then result := gcd(b,a)
  else if a=0 then result := b
  else if a=b then result := a
  else result:=gcd(b mod a, a);
end;

function gcd(a, b: int64): int64;
begin
  if b<a then result := gcd(b,a)
  else if a=0 then result := b
  else if a=b then result := a
  else result:=gcd(b mod a, a);
end;

function lcm(a, b: int64): int64;
begin
  result := a * b div gcd(a,b);
end;

function coprime(a,b:cardinal): boolean;
begin
  if (a = 1) or (b=1) then result := true
  else if (a = 0) or (b=0) then result := false//according to wikipedia
  else result:=gcd(a,b) = 1;
end;

//========================mathematical functions========================

function factorial(i: longint): float;
var j:longint;
begin
  if i<0 then begin result := factorial(-i); exit; end;
  result:=1;
  for j:=2 to i do
    result := result * j;
end;
function binomial(n,k: longint): float;
var i:longint;
begin
  if (k=0) or (n=k) then begin result := 1; exit; end;
  if n=0 then begin result := 1; exit; end;
  if n-k<k then begin result := binomial(n,n-k); exit; end;


  // /n\      n!            1*2*...*n           (n-k+1)*(n-k+2)*..*n
  // | | = -------- = ----------------------- = --------------------
  // \k/   k!(n-k)!   1*2*..*k * 1*2*..*(n-k)      2   *   3 *..*k

  result:=1;
  for i:=n-k+1 to n do
    result := result * i;
  for i:=2 to k do
    result := result / i;
end;

function binomialExpectation(n: longint; p: float): float;
begin
  result:=n*p;
end;

function binomialVariance(n: longint; p: float): float;
begin
  result:=n*p*(1-p);
end;

function binomialDeviation(n: longint; p: float): float;
begin
  result:=sqrt(n*p*(1-p));
end;

function binomialProbability(n: longint; p: float; k: longint): float;
begin
  if (k<0)or(k>n) then result := 0
  else result:=binomial(n,k)*intpower(p,k)*intpower(1-p,n-k);
end;

function binomialProbabilityGE(n: longint; p: float; k: longint): float;
var i:longint;
begin
  result:=0;
  for i:=k to n do
    result := result + binomialProbability(n,p,i);
end;

function binomialProbabilityLE(n: longint; p: float; k: longint): float;
var i:longint;
begin
  result:=0;
  for i:=0 to k do
    result := result + binomialProbability(n,p,i);
end;

function binomialProbabilityDeviationOf(n: longint; p: float; dif: float
  ): float;
var m: float;
    i:longint;
begin
  m:=n*p;
  result:=0;
  for i:=max(1,ceil(m-dif)) to min(n-1,floor(m+dif)) do
    result:=Result+binomialProbability(n,p,i);
  result:=1-result;
end;

function binomialProbabilityApprox(n: longint; p: float; k: longint): float;
var sigma:float;
begin
  if (k<0)or(k>n) then begin result := 0; exit; end;
  sigma:=binomialDeviation(n,p);
  if sigma>=3 then //Moivre and Laplace
    result:=1/(sigma*sqrt(2*pi)) * exp(sqr(k-n*p)/(2*sigma*sigma))
   else
    result:=intpower(n*p,k)/factorial(k) * exp(-n*p); //Poisson
end;

function binomialZScore(n: longint; p: float; k: longint): float;
begin
  result:=(k-binomialExpectation(n,p)) / binomialDeviation(n,p);
end;




//========================date/time functions========================
{$IFDEF windows}
function dateTimeToFileTime(const date: TDateTime): TFileTime;
var sysTime: TSYSTEMTIME;
    temp: TFILETIME;
begin
  DateTimeToSystemTime(date,sysTime);
  SystemTimeToFileTime(sysTime,temp);
  LocalFileTimeToFileTime(temp,result);
end;

function fileTimeToDateTime(const fileTime: TFileTime;convertTolocalTimeZone: boolean=true): TDateTime;
var sysTime: TSystemTime;
    localFileTime: tfiletime;
begin
  if convertTolocalTimeZone then FileTimeToLocalFileTime(filetime,localFileTime)
  else localFileTime:=filetime;
  FileTimeToSystemTime(localFileTime, sysTime);
  result:=SystemTimeToDateTime(sysTime);
end;
{$ENDIF}

procedure intSieveEulerPhi(const n: cardinal; var totient: TLongwordArray);
var
  p,j,e: cardinal;
  exps: array[1..32] of cardinal;
  powers: array[0..32] of cardinal;
  exphigh: cardinal;
begin
  setlength(totient, n+1);
  totient[0] := 0;
  //initialize array for numbers that are prime (also handles the case of numbers only divisible by 2)
  for p:=1 to n do totient[p] := 1;

  //initialize array for numbers that are divisible by 4 (numbers divisible by 2 and not by 4 were handled above)
  j := 4;
  while j <= n do begin
    e := (j) and (-j);     //calculate the largest e (or k) with e = 2^k dividing j
    totient[j] := e shr 1;
    inc(j,  4);
  end;

  for p:=3 to n do begin
    if totient[p] = 1 then begin //prime
      exps[1] := 1;
      powers[0] := 1;
      powers[1] := p;
      exphigh := 1;
      e := 1;
      j := p;
      while j <= n do begin
        totient[j] := totient[j div powers[e]] * (powers[e-1]) * (p - 1);

        inc(j, p);

        //we need to find the largest e with (j mod p^e) = 0, so write j in base p and count trailing zeros
        exps[1] := exps[1] +  1;
        e:=1;
        if exps[e] = p then begin
          repeat
            exps[e] := 0;
            inc(e);
            exps[e] := exps[e] +  1;
          until  (e > exphigh) or (exps[e] < p);

          if exps[exphigh] = 0 then begin
            powers[exphigh + 1] := powers[exphigh] * p;
            inc(exphigh);
            exps[exphigh] := 1;
          end;
        end;
      end;
    end;
  end;
end;


procedure intSieveDivisorCount(n: integer; var divcount: TLongintArray);
var
 i: Integer;
 j: LongInt;
begin
  setlength(divcount, n+1);
  divcount[0] := 0;
  for i:=1 to high(divcount) do divcount[i] := 1;
  for i:=2 to high(divcount) do begin
    j:=i;
    while j < length(divcount) do begin
      divcount[j] := divcount[j] + 1;
      inc(j, i);
    end;
  end;
end;

function dateIsLeapYear(const year: integer): boolean;
begin
  result := (year mod 4 = 0) and ((year mod 100 <> 0) or (year mod 400 = 0))
end;

function dateWeekOfYear(const date:TDateTime):word; overload;
var month, day, year: word;
begin
  DecodeDate(date,year,month,day);
  result := dateWeekOfYear(year,month,day);
end;

function dateWeekOfYear(year, month, day: integer): word;overload;
//ISO Week after Claus T�ndering  http://www.tondering.dk/claus/cal/week.php#weekno
var a,b,c,s,e,f,g,d,n: longint;
    startOfYear: boolean;
begin
  dec(month);
  dec(day);
  startOfYear:=month in [0,1];
  a:=year;
  if startOfYear then dec(a);
  b:=a div 4 - a div 100 + a div 400;
  c:=(a-1) div 4 - (a-1) div 100 + (a-1) div 400;
  s:=b-c;
  if startOfYear then begin
    e:=0;
    f:=day + 31*month;
  end else begin
    e:=s+1;
    f:=day+(153*(month-2)+2)div 5 + 59 + s;
  end;

  g:=(a+b) mod 7;
  d:=(f+g-e) mod 7;
  n:=f+3-d;
  if n<0 then result:=53-(g-s) div 5
  else if n>364+s then result:=1
  else result:=n div 7+1;
end;

//const DATETIME_PARSING_FORMAT_CHARS = ['h','n','s','d','y','Z','z'];


type T9Ints = array[1..9] of integer;

function dateTimeParsePartsTryInternal(input,mask:RawByteString; var parts: T9Ints; options: TDateTimeParsingFlags): TDateTimeParsingResult;
type THumanReadableName = record
  n: RawByteString;
  v: integer;
end;
const DefaultShortMonths: array[1..17] of THumanReadableName = (
   //english
   (n:'jan'; v:1), (n:'feb'; v:2), (n:'mar'; v: 3), (n:'apr'; v:4), (n:'may'; v:5), (n:'jun'; v:6)
  ,(n:'jul'; v:7), (n:'aug'; v:8), (n:'sep'; v: 9), (n:'oct'; v:10), (n:'nov'; v:11), (n:'dec'; v:12),
   //german (latin1)
   (n:'m'#$E4'r'; v:3), (n:'mai'; v:5), (n:'okt'; v:10), (n:'dez'; v:12),
   //german (utf8)
   (n:'m'#$C3#$A4'r'; v:3)
  );
const DefaultLongMonths: array[1..21] of THumanReadableName = (
  //english
  (n:'january';v:1), (n:'february';v:2), (n:'march';v:3), (n:'april';v: 4), (n:'may';v: 5), (n:'june';v:6),
  (n:'july';v:7), (n:'august';v:8), (n:'september';v:9), (n:'october';v:10), (n:'november';v:11), (n:'december';v:12),
  //german
  (n:'januar';v:1), (n:'februar';v:2), (n:'m'#$E4'rz';v:3), (n:'mai';v: 5), (n:'juni';v:6),
  (n:'juli';v:7), (n:'oktober';v:10), (n:'dezember';v:12),
  (n:'m'#$C3#$A4'rz';v:3));

function readNumber(const s:RawByteString; var ip: integer; const count: integer): integer;
begin
  if (dtpfStrict in options) and ((ip > length(s)) or not (s[ip] in ['0'..'9'])) then begin
    result := -1;
    exit;
  end;
  result := StrToIntDef(copy(s, ip, count), -1);
  inc(ip,  count);
end;

var
  i: Integer;

  prefix, mid, suffix: RawByteString;
  p: Integer;

  count: integer;
  base: ansichar;
  index: Integer;

  mp, ip: integer;
  positive: Boolean;
  backup: T9Ints;
  truecount: Integer;
  newres: TDateTimeParsingResult;


begin
  truecount := 0; //hide warning
  p := pos('[', mask);
  if p > 0 then begin
    suffix := mask;
    prefix := copy(mask, 1, p - 1);
    mid := strSplitGetBetweenBrackets(suffix, '[', ']', true);

    backup := parts;
    result := dateTimeParsePartsTryInternal(input, prefix+mid+suffix, parts, options);
    if result <> dtprSuccess then parts := backup
    else  exit;
    {if pos('[', mid) = 0 then begin
      formatChars:=0;
      for i:=1 to length(mid) do
        if (mid[i] in DATETIME_PARSING_FORMAT_CHARS) then inc(formatChars);  //todo: check for ", but really, whotf cares?
      for i:=1 to formatChars-1 do begin
        for j:=1 to length(mid) do
          if (mid[j] in DATETIME_PARSING_FORMAT_CHARS) then begin //mmm <> mm??
            delete(mid, j, 1);
            break;
          end;
        backup := parts;
        result := dateTimeParsePartsTryInternal(input, prefix+mid+suffix, parts);
        if result then exit
        else parts := backup;
      end;
    end;}
    newres := dateTimeParsePartsTryInternal(input, prefix+suffix, parts, options);
    if newres <> dtprSuccess then begin
      parts := backup;
      if result = dtprFailure then result := newres;
    end else result := newres;
    exit;
  end;


  result := dtprSuccess;
  mp:=1;
  ip:=1;
  while mp<=length(mask) do begin
    case mask[mp] of
      'h','n','s','d', 'm', 'y', 'Y', 'Z', 'z', 'a': begin
        count := 0;
        base := mask[mp];
        if mask[mp] <> 'a' then begin
          while (mp <= length(mask)) and (mask[mp] = base) do begin inc(mp); inc(count); end;
          truecount:=count;
          if (mp <= length(mask)) and (mask[mp] = '+') then begin
            if (base = 'm') and (truecount >= 3) then begin inc(count); inc(mp); end
            else begin
              while (ip + count <= length(input)) and (input[ip+count] in ['0'..'9']) do inc(count);
              inc(mp);
              if count > 9 then begin
                result := dtprFailureValueTooHigh; //input is invalid, but continue parsing, so we do not report value-too-high on input with completely invalid format, just because there is a large number at the beginning
                inc(ip, count-4); //jump ahead, so there are no problems with invalid integers
                count := 4;
              end else if (ip <= length(input)) and (input[ip] = '-') and (base = 'y') then dec(count);
            end;
          end;
        end else begin //am/pm special case
          if (mp + 4 <= length(mask)) and (strliequal(@mask[mp], 'am/pm', 5)) then inc(mp, 5)
          else if (mp + 2 <= length(mask)) and (strliequal(@mask[mp], 'a/p', 3)) then inc(mp, 3)
          else if (ip > length(input)) or (input[ip] <> 'a') then begin result := dtprFailure; exit; end
          else begin inc(mp); inc(ip); continue; end;
        end;

        index := -1;
        case base of
          'y', 'Y': index := 1; 'm': index := 2; 'd': index := 3;
          'h': index := 4; 'n': index := 5; 's': index := 6;
          'z': index := 7;
          'Z': index := 8;
          'a': index := 9;
          else assert(false);
        end;

        if (ip+count-1 > length(input)) then begin result := dtprFailure; exit; end;

        case base of
          'y': if (input[ip] = '-') then begin //special case: allow negative years
            inc(ip);
            parts[index] := - readNumber(input,ip,count);
            if parts[index] = --1 then begin result := dtprFailure; exit; end;
            continue;
          end;
          'm': case truecount of
            3, 4: begin //special case verbose month names
              parts[2] := high(parts[2]);
              if count >= 4 then begin
                //special month name handling
                for i:=low(DefaultLongMonths) to high(DefaultLongMonths) do
                  if strliequal(@input[ip], DefaultLongMonths[i].n, length(DefaultLongMonths[i].n)) then begin
                     inc(ip,  length(DefaultLongMonths[i].n));
                     parts[2] := DefaultLongMonths[i].v;
                     break;
                   end;
                if parts[2] <> high(parts[2]) then continue;
                {$IFDEF HASDefaultFormatSettings}
                for i:=1 to 12 do
                  if strliequal(@input[ip], DefaultFormatSettings.LongMonthNames[i], length(DefaultFormatSettings.LongMonthNames[i])) then begin
                    inc(ip,  length(DefaultFormatSettings.LongMonthNames[i]));
                    parts[2] := i;
                    break;
                  end;
                if parts[2] <> high(parts[2]) then continue;
                {$ENDIF}
              end;
              if truecount = 3 then begin
                //special month name handling
                mid:=LowerCase(input[ip]+input[ip+1]+input[ip+2]);
                for i:=low(DefaultShortMonths) to high(DefaultShortMonths) do
                  if ((length(DefaultShortMonths[i].n) = 3) and (mid = DefaultShortMonths[i].n)) or
                     ((length(DefaultShortMonths[i].n) <> 3) and strliequal(@input[ip], DefaultShortMonths[i].n, length(DefaultShortMonths[i].n))) then begin
                       inc(ip,  length(DefaultShortMonths[i].n));
                       parts[2] := DefaultShortMonths[i].v;
                       break;
                     end;
                if parts[2] <> high(parts[2]) then continue;
                {$IFDEF HASDefaultFormatSettings}
                for i:=1 to 12 do
                  if ((length(DefaultFormatSettings.ShortMonthNames[i]) = 3) and (DefaultFormatSettings.ShortMonthNames[i] = mid)) or
                     (strliequal(@input[ip], DefaultFormatSettings.ShortMonthNames[i], length(DefaultFormatSettings.ShortMonthNames[i]))) then begin
                       inc(ip,  length(DefaultFormatSettings.ShortMonthNames[i]));
                       parts[2] := i;
                       break;
                     end;
                if parts[2] <> high(parts[2]) then continue;
                {$ENDIF}
              end;
              result := dtprFailure;
              exit;
            end;
          end;
          'Z': begin //timezone
            if ip > length(input) then begin result := dtprFailure; exit; end;
            if input[ip] = 'Z' then begin parts[index] := 0; inc(ip); end //timezone = utc
            else if (input[ip] in ['-','+']) then begin
              parts[index]  := 0;
              positive := input[ip] = '+';
              inc(ip);
              parts[index] := 60 * readNumber(input, ip, 2);
              if parts[index] = -1 then begin result := dtprFailure; exit; end;
              if ip <= length(input) then begin
                if input[ip] = ':' then inc(ip)
                else if dtpfStrict in options then begin result := dtprFailure; exit; end;
                if input[ip] in ['0'..'9'] then begin
                  i := readNumber(input, ip, 2);
                  if (i = -1) or (i > 59) then begin result := dtprFailure; exit; end;
                  parts[index] := parts[index] +  i;
                end;
              end else if dtpfStrict in options then begin result := dtprFailure; exit; end;
              if not positive then parts[index] := - parts[index];
            end else begin result := dtprFailure; exit; end;
            continue;
          end;
          'a': begin //am/pm or a/p
            if (input[ip] in ['a', 'A']) then parts[index] := 0
            else if (input[ip] in ['p', 'P']) then parts[index] := 12
            else begin result := dtprFailure; exit; end;
            inc(ip);
            if mask[mp-1] = 'm' then begin
              if not (input[ip] in ['m', 'M']) then begin result := dtprFailure; exit; end;
              inc(ip);
            end;
            continue;
          end;
        end;

        parts[index] := readNumber(input, ip, count);
        if parts[index] = -1 then begin result := dtprFailure; exit; end;

        if base = 'z' then
          for i:=count + 1 to 9 do
            parts[index] := parts[index] *  10; //fixed length ms
        if (base = 'y') and (count <= 2) then
          if (parts[index] >= 0) and (parts[index] < 100) then
            if parts[index] < 90 then parts[index] := parts[index] + 2000
            else parts[index] := parts[index] + 1900;
      end;
      ']': raise EDateTimeParsingException.Create('Invalid mask: missing [, you can use \] to escape ]');
      '"': begin   //verbatim
        inc(mp);
        while (mp <= length(mask)) and (ip <= length(input)) and (mask[mp] <> '"') and  (mask[mp] = input[ip]) do begin
          inc(ip);
          inc(mp);
        end;
        if (mp > length(mask)) or (mask[mp] <> '"') then begin result := dtprFailure; exit; end;
        inc(mp);
      end;
      ' ',#9: begin //skip whitespace
        if ip > length(input) then begin result := dtprFailure; exit; end;
        while (mp <= length(mask)) and (mask[mp] in [' ',#9]) do inc(mp);
        if not (input[ip] in [' ',#9]) then begin result := dtprFailure; exit; end;
        while (ip <= length(input)) and (input[ip] in [' ',#9]) do inc(ip);
      end
      else if (mask[mp] = '$') and (mp  = length(mask)) then begin
        if ip <> length(input) + 1 then result := dtprFailure;
        exit;
      end else if (ip > length(input)) or (mask[mp]<>input[ip]) then begin result := dtprFailure; exit; end
      else begin
        inc(mp);
        inc(ip);
      end;
    end;
  end;
end;



function dateTimeParsePartsTry(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PInteger = nil; outtimezone: PInteger = nil; options: TDateTimeParsingFlags = []): TDateTimeParsingResult;
var parts: T9Ints;
  i: Integer;
  mask2: RawByteString;
const singleletters: RawByteString = 'mdhns';
begin
  for i:=low(parts) to high(parts) do parts[i] := high(parts[i]);
  mask2 := trim(mask);
  for i:=1 to length(singleletters) do begin//single m,d,h,n,s doesn't make sense, so replace x by [x]x
    if strlcount(singleletters[i], pansichar(mask2), length(mask2)) <> 1 then continue;
    mask2 := StringReplace(mask2, singleletters[i], '['+singleletters[i]+']'+singleletters[i],[]);
  end;
  result := dateTimeParsePartsTryInternal(trim(input), mask2, parts, options);
  if result <> dtprSuccess then exit;
  if assigned(outYear) then outYear^:=parts[1];
  if assigned(outMonth) then outMonth^:=parts[2];
  if assigned(outDay) then outDay^:=parts[3];
  if assigned(outHour) then begin
    outHour^:=parts[4];
    if parts[9] = 12 then inc(outHour^, 12);
  end;
  if assigned(outMinutes) then outMinutes^:=parts[5];
  if assigned(outSeconds) then outSeconds^:=parts[6];
  if assigned(outSecondFraction) then outSecondFraction^:= parts[7];
  if assigned(outTimeZone) then outtimezone^:= parts[8];
end;

procedure dateTimeParsePartsNew(const input,mask:RawByteString; outYear, outMonth, outDay: PInteger; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PInteger = nil; outtimezone: PInteger = nil);
begin
  if dateTimeParsePartsTry(input, mask, outYear, outMonth, outDay, outHour, outMinutes, outSeconds, outSecondFraction, outtimezone) <> dtprSuccess then
    raise Exception.Create('The date time ' + input + ' does not correspond to the date time format ' + mask);
end;

function timeZoneOldToNew(const tz: Double): integer;
begin
  if IsNan(tz) then result := high(integer)
  else result := round(tz * MinsPerDay);
end;

function timeZoneNewToOld(const tz: integer): double;
begin
  if tz = high(integer) then result := NaN
  else result := tz / MinsPerDay;
end;

const TryAgainWithRoundedSeconds: RawByteString = '<TryAgainWithRoundedSeconds>';


function dateTimeFormatInternal(const mask: RawByteString; const y, m, d, h, n, s, nanoseconds, timezone: integer): RawByteString;
var mp: integer;
  function nextMaskPart: RawByteString;
  function isValid(const c: ansichar): boolean;
  begin
    case c of
      'y','Y': result := (y <> 0) and (y <> high(integer));
      'm': result := (m <> 0) and (m <> high(integer));
      'd': result := (d <> 0) and (d <> high(integer));
      'h': result := (h <> 0) and (h <> high(integer));
      'n': result := (n <> 0) and (n <> high(integer));
      's': result := (s <> 0) and (s <> high(integer));
      'z': result := (nanoseconds <> 0) and (nanoseconds <> high(integer));
      'Z': result := (timezone <> high(Integer));
      else raise exception.Create('impossible');
    end;
  end;

  const SPECIAL_MASK_CHARS = ['y','Y','m','d','h','n','s','z','Z'];
  var
    oldpos: Integer;
    okc: ansichar;
    i: Integer;
  begin
    while (mp <= length(mask)) and (mask[mp] = '[') do begin
      oldpos := mp;
      result := strcopyfrom(mask, mp);
      result := strSplitGetBetweenBrackets(result, '[', ']', false);
      mp := mp +  length(result) + 2;
      okc := #0;
      for i:=1 to length(result) do
        if (result[i] in SPECIAL_MASK_CHARS) and isValid(result[i]) then begin
          okc := result[i];
          break;
        end;
      if (okc <> #0) and ((oldpos = 1) or (mask[oldpos-1] <> okc)) and ((mp > length(mask)) or (mask[mp] <> okc)) then begin
        result := dateTimeFormatInternal(result, y, m, d, h, n, s, nanoseconds, timezone);
        if pointer(result) = pointer(TryAgainWithRoundedSeconds) then exit;
        result := '"' + result + '"';
        exit;
      end;
      result:='';
    end;
    while (mp <= length(mask)) and (mask[mp] = '"') do begin
      oldpos := mp;
      inc(mp);
      while (mp <= length(mask)) and (mask[mp] <> '"') do
        inc(mp);
      inc(mp);
      result := copy(mask, oldpos, mp - oldpos);
      exit;
    end;
    if mp > length(mask) then exit;
    if mask[mp] = '$' then begin inc(mp); begin result := ''; exit; end; end;
    oldpos := mp;
    if mask[mp] in SPECIAL_MASK_CHARS then begin
      while (mp <= length(mask)) and (mask[mp] = mask[oldpos]) do inc(mp);
      result := copy(mask, oldpos, mp - oldpos);
      if (mp <= length(mask)) and (mask[mp] = '+') then inc(mp);
    end else begin
      while (mp <= length(mask)) and not (mask[mp] in (SPECIAL_MASK_CHARS + ['$','"','['])) do inc(mp);
      result := copy(mask, oldpos, mp - oldpos);
    end;
  end;

var part: RawByteString;
  temp: Int64;
  scale: Integer;
  toadd: RawByteString;
  len: Integer;
begin
  mp := 1;
  result := '';
  while mp <= length(mask) do begin
    part := nextMaskPart;
    if pointer(part) = pointer(TryAgainWithRoundedSeconds) then begin result := TryAgainWithRoundedSeconds; exit; end;
    if length(part) = 0 then continue;
    case part[1] of
      'y','Y': result := result +  strFromInt(y, length(part));
      'm': result := result +  strFromInt(m, length(part));
      'd': result := result +  strFromInt(d, length(part));
      'h': result := result +  strFromInt(h, length(part));
      'n': result := result +  strFromInt(n, length(part));
      's': result := result +  strFromInt(s, length(part));
      'z': begin
        if (mask[mp-1] = '+') and (length(part) < 6) then len := 6
        else len := length(part);
        if len < 9 then begin
          scale := powersOf10[9 - len];
          temp := nanoseconds div scale;
          if nanoseconds mod scale >= scale div 2 then inc(temp); //round
        end else begin
          temp := nanoseconds;
          if len > 9 then len := 9 //we do not have those digits
        end;
        if temp >= powersOf10[len] then begin result := TryAgainWithRoundedSeconds; exit; end; //rounding overflowed
        toadd := strTrimRight(strFromInt(temp, len), ['0']);
        result := result +  toadd;
        if length(toadd) < length(part) then result := result +  strDup('0', length(part) - length(toadd));
      end;
      'Z': if timezone <> high(Integer) then begin; //no timezone
        if timezone = 0 then result := result + 'Z'
        else
          if timezone > 0 then result := result +  '+' + strFromInt(timezone div 60, 2) + ':' + strFromInt(timezone  mod 60, 2)
          else                 result := result +  '-' + strFromInt(-timezone div 60, 2) + ':' + strFromInt(-timezone mod 60, 2);
      end;
      '"': result := result +  copy(part, 2, length(part) - 2);
      else result := result +  part;
    end;
  end;
end;

procedure dateTimeParsePartsOld(const input, mask: RawByteString; outYear, outMonth, outDay: PInteger; outHour, outMinutes,
  outSeconds: PInteger; outSecondFraction: PDouble = nil; outtimezone: PDateTime = nil);
var
  tempns: Integer;
  tempzone: Integer;
begin
  dateTimeParsePartsNew(input, mask, outYear, outMonth, outDay, outHour, outMinutes, outSeconds, @tempns, @tempzone);
  if assigned(outSecondFraction) then outSecondFraction^ := tempns / 1000000000.0;
  if Assigned(outtimezone) then outtimezone^ := timeZoneNewToOld(tempzone);
end;

function dateTimeParseNew(const input, mask: RawByteString; outtimezone: PInteger): TDateTime;
var y,m,d: integer;
    hour, minutes, seconds: integer;
    nanoseconds: integer;
    timeZone: integer;
begin
  dateTimeParsePartsNew(input, mask, @y, @m, @d, @hour, @minutes, @seconds, @nanoseconds, @timeZone);

  if d=high(d) then raise EDateTimeParsingException.Create('No day contained in '+input+' with format '+mask+'');
  if m=high(m) then raise EDateTimeParsingException.Create('No month contained in '+input+' with format '+mask+'');
  if y=high(y) then raise EDateTimeParsingException.Create('No year contained in '+input+' with format '+mask+'');
  if hour=high(hour) then raise EDateTimeParsingException.Create('No hour contained in '+input+' with format '+mask+'');
  if minutes=high(minutes) then raise EDateTimeParsingException.Create('No minute contained in '+input+' with format '+mask+'');
  if seconds=high(seconds) then raise EDateTimeParsingException.Create('No second contained '+input+' with format '+mask+'');

  result := trunc(EncodeDate(y,m,d)) + EncodeTime(hour,minutes,seconds,0);
  if nanoseconds <> high(nanoseconds) then result := result +  nanoseconds / (1000000000.0 * SecsPerDay);
  if outtimezone <> nil then outtimezone^ := timeZone
  else if timeZone <> high(Integer) then result := result -  timeZone * 60 / SecsPerDay;
end;

function dateTimeParseOld(const input, mask: RawByteString; outtimezone: PDateTime): TDateTime;
var
  tempzone: Integer;
begin
  if not assigned(outtimezone) then result := dateTimeParseNew(input, mask, nil)
  else begin
    result := dateTimeParseNew(input, mask, @tempzone);
    outtimezone^ := timeZoneNewToOld(tempzone);
  end;
end;

function dateTimeFormatNew(const mask: RawByteString; y, m, d, h, n, s: Integer; nanoseconds: integer; timezone: integer): RawByteString;
const invalid = high(integer);
begin
  Result := dateTimeFormatInternal(mask,y,m,d,h,n,s,nanoseconds,timezone);
  if pointer(Result) = Pointer(TryAgainWithRoundedSeconds) then begin
    inc(s);
    //handle overflow
    if s >= 60 then begin
      s := 0;
      if n <> invalid then begin
        inc(n);
        if n >= 60 then begin
          n := 0;
          if h <> invalid then begin
            inc(h);
            if h >= 24 then begin
              h := 0;
              if d <> invalid then begin
                inc(d);
                if (y <> invalid) and (m <> invalid) and (d > MonthDays[dateIsLeapYear(y), m]) then begin
                   d := 1;
                   inc(m);
                   if m > 12 then begin
                     m := 1;
                     inc(y);
                     if y = 0 then inc(y);
                   end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    Result := dateTimeFormatInternal(mask, y,m,d,h,n,s, 0, timezone);
  end;
end;


function dateTimeFormatOLD(const mask: RawByteString; y, m, d, h, n, s: integer; const secondFraction: double; const timezone: TDateTime): RawByteString;
var
  nanoseconds: Int64;
begin
  nanoseconds := 0;
  if not IsNan(secondFraction) then
    nanoseconds := round(secondFraction * 1000000000);
  result := dateTimeFormatNew(mask, y, m, d, h, n, s, nanoseconds, timeZoneOldToNew(timezone));
end;


function dateTimeFormat(const mask: RawByteString; const dateTime: TDateTime): RawByteString;
var
  y,m,d: Integer;
  h,n,s,ms: word;
begin
  dateDecode(dateTime, @y, @m, @d);
  DecodeTime(dateTime, h, n, s, ms);
  result := dateTimeFormatNEW(mask, y, m, d, h, n, s, ms*1000000);
end;

function dateTimeEncodeOLD(const y, m, d, h, n, s: integer; const secondFraction: double): TDateTime;
begin
  result := dateEncode(y,m,d) + EncodeTime(h,n,s,0) + secondFraction / SecsPerDay;
end;

procedure timeParsePartsNew(const input, mask: RawByteString; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PInteger; outtimezone: PInteger);
begin
  dateTimeParsePartsNew(input, mask, nil, nil, nil, outHour, outMinutes, outSeconds, outSecondFraction, outtimezone);
end;

procedure timeParsePartsOld(const input, mask: RawByteString; outHour, outMinutes, outSeconds: PInteger; outSecondFraction: PDouble;
  outtimezone: PDateTime);
begin
  dateTimeParsePartsOld(input, mask, nil, nil, nil, outHour, outMinutes, outSeconds, outSecondFraction, outtimezone);
end;

function timeParse(const input, mask: RawByteString): TTime;
var
  hour, minutes, seconds: integer;
  nanoseconds, timezone: integer;
begin
  timeParsePartsNew(input,mask,@hour,@minutes,@seconds,@nanoseconds,@timeZone);
  if hour=high(hour) then raise EDateTimeParsingException.Create('No hour contained in '+input+' with format '+mask+'');
  if minutes=high(minutes) then raise EDateTimeParsingException.Create('No minute contained in '+input+' with format '+mask+'');
  if seconds=high(seconds) then raise EDateTimeParsingException.Create('No second contained '+input+' with format '+mask+'');
  result := EncodeTime(hour,minutes,seconds,0);
  if nanoseconds <> high(nanoseconds) then result := result + nanoseconds / 1000000000.0 / SecsPerDay;
  if timezone <> high(timezone) then result := result -  timeZone * 60 / SecsPerDay;
end;

function timeFormatOld(const mask: RawByteString; const h, n, s: integer; const secondFraction: double; const timezone: TDateTime): RawByteString;
begin
  result := dateTimeFormatOLD(mask, high(integer), high(integer), high(integer), h, n, s, secondFraction, timezone);
end;

procedure dateParsePartsNew(const input, mask: RawByteString; outYear, outMonth, outDay: PInteger; outtimezone: PInteger);
begin
  dateTimeParsePartsNew(input, mask, outYear, outMonth, outDay, nil, nil, nil, nil, outtimezone);
end;

procedure dateParsePartsOLD(const input, mask: RawByteString; outYear, outMonth, outDay: PInteger; outtimezone: PDateTime);
var
  temptimezone: Integer;
begin
  dateParsePartsNew(input, mask, outYear, outMonth, outDay, @temptimezone);
  if assigned(outtimezone) then
    outtimezone^ := timeZoneNewToOld(temptimezone);
end;

function dateParse(const input, mask: RawByteString): longint;
var y,m,d: integer;
begin
  dateParsePartsNew(input, mask, @y, @m, @d);
  if d=high(d) then raise EDateTimeParsingException.Create('No day contained in '+input+' with format '+mask+'');
  if m=high(m) then raise EDateTimeParsingException.Create('No month contained in '+input+' with format '+mask+'');
  if y=high(y) then raise EDateTimeParsingException.Create('No year contained in '+input+' with format '+mask+'');
  result := trunc(EncodeDate(y,m,d));
end;

function dateFormat(const mask: RawByteString; const y, m, d: integer; const timezone: TDateTime): RawByteString;
begin
  result := dateTimeFormatNEW(mask, y, m, d, high(integer), high(integer), high(integer), timeZoneOldToNew(timezone));
end;

function dateEncodeTry(year, month, day: integer; out dt: TDateTime): boolean;
var leap: boolean;
    century, yearincent: int64;
begin
  {$ifdef ALLOWYEARZERO} if year <= 0 then dec(year);{$endif}
  leap := dateIsLeapYear(year);
  result := (year <> 0) and
            (month >= 1) and (month <= 12) and (day >= 1) and (day<=MonthDays[leap,month]);
  if not result then exit;
  dt := - DateDelta; // -693594
  if year > 0 then dec(year);
  //end else begin
  //  dt := -  DateDelta; //not sure if this is correct, but it fits at the borders
  //end;
  century := year div 100;
  yearincent := year - 100*century;
  dt := dt +  (146097*century) div 4  + (1461* yearincent) div 4 +  DateMonthDaysCumSum[leap, month-1] + day;
end;

function dateEncode(year, month, day: integer): TDateTime;
begin
  if not dateEncodeTry(year, month, day, result) then
    raise EDateTimeParsingException.Create('Invalid date: '+inttostr(year)+'-'+inttostr(month)+'-'+inttostr(day));
end;

procedure dateDecode(date: TDateTime; year, month, day: PInteger);
var
  datei: int64;
  //century, yearincent: int64;
  tempyear, tempmonth, tempday: integer;
  temp: word;
  leap: Boolean;
begin
  if year = nil then year := @tempyear;
  if month = nil then month := @tempmonth;
  if day = nil then day := @tempday;

  year^ := 0;
  month^ := 0;
  day^ := 0;
  datei := trunc(date) + DateDelta;
  if datei > 146097 then begin // decode years over 65535?, 146097 days = 400 years so it is tested
    DecodeDate(((146097 + datei - 365) mod 146097) - DateDelta + 365, PWord(year)^, PWord(month)^, PWord(day)^);
    year^ := year^ + ((datei - 365) div 146097) * 400;
  end else if datei  <= 0 then begin
    datei := -DateDelta - datei + 1;
    DecodeDate(datei, PWord(year)^, PWord(month)^, PWord(day)^);
    year^ := -year^;
    {$ifdef ALLOWYEARZERO}inc(year^);{$endif}
    //year is correct, but days are inverted
    leap := dateIsLeapYear(year^);
    datei := datei +   DateMonthDaysCumSum[leap, 12] + 1 - 2 * (DateMonthDaysCumSum[leap,month^-1] + day^);
    DecodeDate(datei, temp, PWord(month)^, PWord(day)^);
  end else DecodeDate(date, PWord(year)^, PWord(month)^, PWord(day)^);
                      {todo: implement own conversion?
  datei := trunc(date);
  if datei <= -DateDelta then begin

  end else begin
    datei := (datei + DateDelta) * 4;
    century    := datei div 146097;  datei := datei - century    * 146097;
    yearincent := datei div   1461 ; datei := datei - yearincent *   1461;
    datei := datei div 4;

    year^ := century * 100 + yearincent + 1;
    leap := (year^ mod 4 = 0) and ((year^ mod 100 <> 0) or (year^ mod 400 = 0));
    month^ := (datei - 5) div 30;
  end;                   }
end;



(*
{ TMap }

function TMap.getKeyID(key: T_Key): longint;
var i:longint;
begin
  result:=0-1; //WTF!!
  for i:=0 to high(data) do
    if data[i].key=key then
      begin result := i; exit; end;
end;

procedure TMap.insert(key: T_Key; value: T_Value);
begin
  if getKeyID(key)<>0-1 then exit;
  SetLength(data,length(data)+1);
  data[high(data)].key:=key;
  data[high(data)].value:=value;
end;

procedure TMap.remove(key: T_Key);
var id:longint;
begin
  id:=getKeyID(key);
  if id=0-1 then exit;
  data[id]:=data[high(data)];
  setlength(data,length(data)-1);
end;

function TMap.get(key: T_Key): T_Value;
var id:longint;
begin
  id:=getKeyID(key);
  if id= 0-1 then raise exception.create('key does not exists');
  result:=data[id].value;
end;

function TMap.existsKey(key: T_Key): boolean;
begin
  result:=getKeyID(key)<>(0-1); //WTF!
end;
  *)
  (*
  procedure setInsertAll(oldSet: TIntSet; insertedSet: TIntSet);
  var
    i: Integer;
  begin
    for i:=0 to high(insertedSet.data) do
      oldSet.insert(insertedSet.data[i]);
  end;

  procedure setRemoveAll(oldSet: TIntSet; removedSet: TIntSet);
  var
    i: Integer;
  begin
    for i:=high(removedSet.data) downto 0 do
      oldSet.remove(removedSet.data[i]);
  end;
    *)

//================================Others===================================
type TSortData = Pointer;
     PSortData = ^TSortData; //ppointer would be to confusing (and howfully there will be generics in the stable binaries soon)
//universal stabile sort function (using merge sort in the moment)
procedure stableSortSDr(a,b: pansichar; compareFunction: TPointerCompareFunction; compareFunctionData: TObject; tempArray: array of TSortData);
const psize = sizeof(TSortData);
var length,i,j,mi: cardinal;
    m,n,oldA:PAnsiChar;
    tempItem: TSortData;
begin
  //calculate length and check if the input (size) is possible
  length:=(b-a) div sizeof(TSortData);
  if @a[sizeof(TSortData) * length] <> b then
    raise Exception.Create('Invalid size for sorting');
  if b<=a then
    exit; //no exception, b<a is reasonable input for empty array (and b=a means it is sorted already)
  inc(length); //add 1 because a=b if there is exactly one element

  //check for small input and use insertsort if small
  if length<8 then begin
    for i:=1 to length-1 do begin
      j:=i;
      //use place to insert
      while (j>0) and (compareFunction(compareFunctionData, a + (j-1)*psize, a+i*psize) > 0) do
        dec(j);
      if i<>j then begin
        //save temporary in tempItem (size is checked) and move block forward
        tempItem:=PSortData(a+i*psize)^;
        move((a+j*psize)^, (a+(j+1)*psize)^, psize*(i-j));
        PSortData(a+j*psize)^:=tempItem;
      end;
    end;
    exit; //it is now sorted with insert sort
  end;


  //use merge sort
  assert(length<=cardinal(high(tempArray)+1));
  //rec calls
  mi:=length div 2;
  m:=a+mi*psize;   //will stay constant during merge phase
  n:=a+(mi+1)*psize; //will be moved during merge phase
  stableSortSDr(a, m, compareFunction, compareFunctionData,tempArray);
  stableSortSDr(n, b, compareFunction, compareFunctionData,tempArray);

  //merging
  oldA:=a;
  i:=0;
  while (a <= m) and (n <= b) do begin
    if compareFunction(compareFunctionData,a,n)<=0 then begin
      tempArray[i]:=PSortData(a)^;
      inc(a, psize); //increase by pointer size
    end else begin
      tempArray[i]:=PSortData(n)^;
      inc(n, psize);
    end;
    inc(i);
  end;
  while a <= m do begin
    tempArray[i]:=PSortData(a)^;
    inc(a, psize);
    inc(i);
  end;
  while n <= b do begin
    tempArray[i]:=PSortData(n)^;
    inc(n, psize);
    inc(i);
  end;

  move(tempArray[0],oldA^,length*sizeof(TSortData));
end;

//just allocates the memory for the recursive stableSort4r
//TODO: make it iterative => merge the two functions
procedure stableSortSD(a,b: PAnsiChar; compareFunction: TPointerCompareFunction; compareFunctionData: TObject);
const psize = sizeof(TSortData);
var tempArray: array of TSortData;
    length:longint;
begin
  //calculate length and check if the input (size) is possible
  length:=(b-a) div psize; //will be divided by pointer size automatically
  if @a[length*psize] <> b then
    raise Exception.Create('Invalid size for sorting');
  if b<=a then
    exit; //no exception, b<a is reasonable input for empty array (and b=a means it is sorted already)y
  inc(length); //add 1 because a=b if there is exactly one element
  setlength(tempArray,length);
  stableSortSDr(a,b,compareFunction,compareFunctionData,tempArray);
end;

type TCompareFunctionWrapperData = record
  realFunction: TPointerCompareFunction;
  data: TObject;
end;
    PCompareFunctionWrapperData=^TCompareFunctionWrapperData;
    PPointer=^Pointer;

function compareFunctionWrapper(c:TObject; a,b:pointer):longint;
var data: ^TCompareFunctionWrapperData absolute c;
begin
//  data:=PCompareFunctionWrapperData(c);
  result:=data^.realFunction(data^.data,ppointer(a)^,ppointer(b)^);
end;
function compareRawMemory(c:TObject; a, b:pointer):longint;
var size: integer;
begin
  size := PtrInt(pointer(c));
  result := CompareByte(a^, b^, size);
end;

procedure stableSort(a,b: pointer; size: longint;
  compareFunction: TPointerCompareFunction; compareFunctionData: TObject );
var tempArray: array of pointer; //assuming sizeof(pointer) = sizeof(TSortData)
    tempBackArray: array of longint;
    length:longint;
    data: TCompareFunctionWrapperData;
    tempData: pansichar;
    i: Integer;
begin
  if size=sizeof(TSortData) then begin
    stableSortSD(a,b,compareFunction,compareFunctionData);
    exit;
  end;
  //use temporary array (merge sort will anyways use additional memory)
  length:=(PAnsiChar(b)-PAnsiChar(a)) div size;
  if @PAnsiChar(a)[length*size] <> b then
    raise Exception.Create('Invalid size for sorting');
  inc(length);
  setlength(tempArray,length);
  if {$IFNDEF FPC}@{$ENDIF}compareFunction = nil then begin
    compareFunction:=@compareRawMemory; //todo: use different wrappers for the two if branches
    compareFunctionData:=tobject(pointer(PtrInt(size)));
  end;
  if size < sizeof(TSortData) then begin
    //copy the values in the temp array
    for i:=0 to length-1 do
      move(PAnsiChar(a)[i*size], tempArray[i], size);
    stableSortSD(@tempArray[0],@tempArray[length-1], compareFunction,compareFunctionData);
    for i:=0 to length-1 do
      move(tempArray[i], PAnsiChar(a)[i*size], size);
  end else begin
    //fill the temp array with pointer to the values
    for i:=0 to length-1 do
      tempArray[i]:=@PAnsiChar(a)[i*size];
    //and then call with wrapper function
    data.realFunction:=compareFunction;
    data.data:=compareFunctionData;
    stableSortSD(@tempArray[0],@tempArray[length-1], @compareFunctionWrapper,TObject(@data));
    //we now have a sorted pointer list
    //create back map (hashmap pointer => index in tempArray)
    setlength(tempBackArray,length);
    for i:=0 to length-1 do
      tempBackArray[(pansichar(tempArray[i])-pansichar(a)) div size]:=i;
    //move to every position the correct object and update pointer so they not point to garbage after every change
    getMem(tempData, size); //temporary object
    for i:=0 to length-1 do begin
      //swap
      move(PAnsiChar(a)[i*size], tempData^, size);
      move(tempArray[i]^,PAnsiChar(a)[i*size],size);
      move(tempData^, tempArray[i]^, size);
      //search pointer pointing to PBYTE(a)[i*size] and set to tempArray[i]
      tempArray[tempBackArray[i]]:=tempArray[i];
      tempBackArray[(PAnsiChar(tempArray[tempBackArray[i]])-PAnsiChar(a)) div size]:=tempBackArray[i];
    end;

    FreeMem(tempData);
  end;

end;

function stableSort(intArray: TLongintArray;
  compareFunction: TPointerCompareFunction; compareFunctionData: TObject): TLongintArray;
begin
  result := intArray;
  if length(intArray)<=1  then exit;
  stableSort(@intArray[0],@intArray[high(intArray)],sizeof(intArray[0]),compareFunction,compareFunctionData);
end;

function compareString(c:TObject; a, b:pointer):longint;
begin
  result := striCompareClever(PString(a)^, PString(b)^);
end;

function stableSort(strArray: TStringArray; compareFunction: TPointerCompareFunction; compareFunctionData: TObject): TStringArray;
begin
  result := strArray;
  if length(strArray)<=1  then exit;
  if assigned(compareFunction) then stableSort(@strArray[0],@strArray[high(strArray)],sizeof(strArray[0]),compareFunction,compareFunctionData)
  else stableSort(@strArray[0],@strArray[high(strArray)],sizeof(strArray[0]),@compareString,nil);
end;


function binarySearch(a,b: pointer; size: longint; compareFunction: TBinarySearchFunction = nil; compareFunctionData: TObject=nil; choosen: TBinarySearchChoosen = bsAny; condition: TBinarySearchAcceptedConditions = [bsEqual]): pointer;
var temp: PAnsiChar;
  l, h, m: Integer;
  acceptedFlags, moveFlags: array[TValueSign] of boolean;
  cmpResult: TValueSign;
begin
  result := nil;
  if pansichar(b) < pansichar(a) then exit;

  //the comparison result looks like:  +1 +1 +1 0 0 0 0 -1 -1 -1

  acceptedFlags[-1] := bsGreater in condition;
  acceptedFlags[0]  := bsEqual in condition;
  acceptedFlags[+1] := bsLower in condition;


  if (bsLower in condition) and (choosen <> bsLast) then begin
    cmpResult := Sign(compareFunction(compareFunctionData, a));
    if acceptedFlags[cmpResult] then result := a;
    exit;
  end;
  if (bsGreater in condition) and (choosen = bsLast) then begin
    cmpResult := Sign(compareFunction(compareFunctionData, b));
    if acceptedFlags[cmpResult] then result := b;
    exit;
  end;


  l := 0;
  h := (PtrUInt(b) - PtrUInt(a)) div size;


  moveFlags[-1] := true; //bsGreater in condition;
  moveFlags[0]  := (bsEqual in condition) <> (choosen = bsLast);
  moveFlags[+1] := false; //bsLower in condition;

  //choose first (or any)
  while l <= h do begin
    m := l + (h - l) div 2;
    temp := pansichar(a) + m * size;
    cmpResult := Sign(compareFunction(compareFunctionData, temp));
    if acceptedFlags[cmpResult] then begin
      result := temp;
      if (choosen = bsAny) then exit;
    end;
    if  moveFlags[cmpResult] then h := m - 1
    else l := m + 1;
  end;
end;



function eUTF8: TSystemCodePage;
begin
  result := CP_UTF8;
end;

function eWindows1252: TSystemCodePage;
begin
  result := CP_WINDOWS1252;
end;


{$I bbutils.inc}

end.

