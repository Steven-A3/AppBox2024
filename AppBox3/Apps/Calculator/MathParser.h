/**********************************************************************
 *
 *  PRODUCT: Bestcode Math Parser
 *  COPYRIGHT:  (C) COPYRIGHT Suavi Ali Demir 2008-2011
 *
 *  The source code for this program is not GNU or is not free. 
 *  Source code is distributed with the math parser binaries to improve
 *  maintanability of the software and the user of the software is not
 *  granted rights to modify and use source code to create a 
 *  competitive product. 
 *
 *  The user is granted rights to modify and recompile source code 
 *  to fix bugs/incompatibilities in the binaries which user has purchased.
 *  
 *  Resulting binaries cannot be re-sold as a competitive product but they 
 *  can be used solely to replace the original binaries.
 *  
 *  Copyright and all rights of this software, irrespective of what 
 *  has been deposited with the U.S. Copyright Office belongs 
 *  to Suavi Ali Demir.
 *  
 *  09/25/2011. version 3.0: Support for arbitrary precision arithmetic (MAPM library). 
 *	
 *  08/28/2011. version 2.9: Support for complex numbers. 
 *					BugFix: m_VariableCallback should be initialized to NULL.
 * 
 *  01/24/2011. version 2.8 Bug Fix: Inside Parse function, j index is reaching tmp.length which is
 *                          supposed to contain null terminator for a string. 
 *
 *  02/07/2010. version 2.7 Bug Fix: lastWasOperator = 0; was missing in FindLastOper, case 'E'. 
 *
 *  08/10/2009. version 2.6 BugFix: IsVariableUsed method broken.
 * 
 *  08/07/2009. version 2.5 VariableCallback - setVariableCallback support.
 * 							User defined function takes variable name as a parameter and returns
 * 							the value of it.
 * 
 * 	11/04/2008. version 2.4 GetDefinedFunctionInfo() returns functions AND parameter counts.
 *							Invalid input check for SQRT.			
 * 							Thanks to Blake Madden for most of the v2 bug fixes and new features.
 * 							Visual C++ support for floating-point error control, structured exception handling,
 * 							and throwing ParserException on Division by Zero, Overflow.   
 *  10/27/2008. version 2.3 Bug Fix: toUpper should be ToUpper. Cannot instantiate template.
 * 							Bug Fix: IsFuncUsed() iter->second is no longer func pointer, 
 * 							but iter->second->fPtr is now.
 * 							Optionally check for div by zero using macros.
 * 	10/20/2008. version 2.2 LOGN fix. Comments wrong. % should be modulo operator instead of intdiv.
 * 				
 *  10/04/2008. version 2.1 Use basic_stringstream<_CharT> instead of string stream to support unicode.
 * 							Check for defined(UNICODE) for better VC++ support.	
 *  09/23/2008. version 2.0 Enhancement: user defined functions now take the calling parser 
 *   							instance as a parameter so that their implementation can use current
 * 								application context that can be carried down via parser instance.  
 *  08/25/2008. version 1.1 Bug Fix: 0*E-1*P has problem. It thinks it is scientific notation.
 *  
 ***********************************************************************/

/** \mainpage Math Parser for C++

bcParserCPP is a formula parser class for C++. It makes it possible for your application to parse and evaluate a mathematical expression string at runtime.

The Math Parser for C++ product comes as a CMathParser C++ Template Class which you can easily include into your C++ projects and parse mathematical expressions with no effort. 

MathParser.h is delivered as standard C++ source code ready to include in any C++ project with 1 line. MathParser.h can be used with Visual C++ (Any version), GNU C++ Compiler (3.x and above) and possibly others.

Math Parser for C++ library features include:

Easy to use, simple C++ API. <br>
Comes with predefined functions.<br> 
You can create custom functions/variables and get a callback to your functions that you define in your source code.<br> 
VariableCallback to provide values for undefined variables. <br>
Optimization: Constant expression elimination for repeated tasks.<br> 
Operators: +, -, /, *, ^ <br>
Logical Operators: <, >, =, <>, >=, <=, &, |, ! [IF(condition,case1,case2) is supported]<br> 
Paranthesis: (, {, [ <br>
Functions in the form of: f(x1, x2, ..., xN)<br> 
Common math.h functions predefined. <br>
Pluggable numeric and character types via C++ Template mechanism.<br> 
Royalty free distribution for your binaries. <br>
Portable (Windows, Linux, Mac OSX) C++ Source code is included.<br> 
bcParserCPP, Math Parser for C++, is especially useful in scientific, engineering programs as well as financial spread sheet implementations.<br>

<a href="http://www.bestcode.com/html/math_parser_for_cpp.html">http://www.bestcode.com/html/math_parser_for_cpp.html</a>
*/

#ifndef __MATH_PARSER_H_
#define __MATH_PARSER_H_

//#include "resource.h"       // main symbols

#include <map>
#include <vector>
#include <string>
#include <float.h>
#include <time.h>
#include <wchar.h>
#include <sstream>
#include <math.h>

#include <limits>

//#define _DEBUG_OUT

//If you are going to use the parser with std::complex, then define this.
//#define _COMPLEX

//If you are going to use the parser with float, double, long double, then define this.
//#define _DOUBLE

//If you are going to use the parser with a arbitrary precision decimal type such as MAPM then define this:
//#define _DECIMAL


#ifdef _COMPLEX
#include <complex>
#include "boost/math/complex.hpp"
#endif

//#define _DECIMAL
#ifdef _DECIMAL
//MAMP is a free library that provides support for a MAMP decimal numeric type:
//http://www.tc.umn.edu/~ringx004/mapm-main.html
#include <M_APM.H>
#endif


//Undefine this if you don't want predefined functions for your Math Parser.
#define PREDEFINE_FUNCTIONS

#ifdef _DEBUG_OUT
//help debug:
#include <iostream>
#define DEBUGOUT(x) (cout << x << endl)
#define DEBUGOUT2(x,y) (cout << x << y << endl)
#else
#define DEBUGOUT(x)
#define DEBUGOUT2(x,y)
#endif //_DEBUG_OUT

//forward:
template<typename _CharT, typename _ValueT> class CMathParser;


#ifndef _T
//#define USE_WIDE_CHARS
#if defined(USE_WIDE_CHARS) || defined(UNICODE)
#define CHAR_TYPE wchar_t
#define _T(c) (L##c)
#else
#define CHAR_TYPE char
#define _T(c) c
#endif
#endif //_T

#define MAX_NAME_LEN 255
#define MAX_NAME_LEN_STR _T("255")

//define CATCH_FP_ERRORS if your compiler supports structured exception handling and floating point exceptions.
//#define CATCH_FP_ERRORS //Windows Only. When you define CATCH_FP_ERRORS, and set compiler for SEH you don't need CHECK_SANITY 

#ifdef CATCH_FP_ERRORS

#include <windows.h> //for EXCEPTION_ACCESS_VIOLATION
#include <Excpt.h> //Visual C++ only?

#else
//Define CATCH_FP_ERRORS_CHECKS if you want to throw exception when division by zero, 
//or infinity is encountered. 
//This is useful for compilers that don't have floating point exception support.
	#ifndef _DECIMAL
		#define CATCH_FP_ERRORS_CHECKS
	#endif
#endif

using namespace std;

#ifndef isinf
//define isinf(x) here.
#endif

#ifdef CATCH_FP_ERRORS_CHECKS 
#define CHECK_INFINITY(x, _CharT, _ValueT) (numeric_limits<_ValueT>::has_infinity && (numeric_limits<_ValueT>::infinity()==x || numeric_limits<_ValueT>::infinity()==-x) ? throw CParserException<_CharT>(_T("INFINITY encountered.")) : x)
//#define CHECK_INFINITY(x, _CharT, _ValueT) (isinf(x) ? throw CParserException<_CharT>("INFINITY") : x)
#define CHECK_DIVBYZERO(x, _CharT) (0.0==x ? throw CParserException<_CharT>(_T("Division by Zero")) : x)

#else
#define CHECK_INFINITY(x, _CharT, _ValueT) (x)
#define CHECK_DIVBYZERO(x, _CharT) (x)

#endif


#ifndef BOOL
//boolean:
#define BOOL bool

#ifndef TRUE
#define TRUE true
#endif

#ifndef FALSE
#define FALSE false
#endif

#endif //BOOL


/**
 * CParserException is used to report errors during parsing and evaluation in
 * CMathParser class.
 * GetMessage() function can be used to retrieve error message.
 * GetInvalidPortionOfExpression() function reports the problematic 
 * part of the mathematical expression that caused the error.
 */
template<typename _CharT> class CParserException {
public:
	explicit CParserException(basic_string<_CharT> msg) {
		this->m_Message = msg;
	}
	explicit CParserException(basic_string<_CharT> msg,
			basic_string<_CharT> invExpr) {
		this->m_Message = msg;
		this->m_InvalidPortionOfExpression = invExpr;
	}
	explicit CParserException(_CharT* msg) {
		this->m_Message = msg;
	}
	//destructor:
	~CParserException() {
	} //not virtual!

	/*
	 * Returns the error message as a string.
	 */
	basic_string<_CharT> GetMessage() {
		return this->m_Message;
	}
	/*
	 * Returns the sub expression that the parser could not parse (might be empty).
	 */
	basic_string<_CharT> GetInvalidPortionOfExpression() {
		return this->m_InvalidPortionOfExpression;
	}
private:
	basic_string<_CharT> m_Message;
	basic_string<_CharT> m_InvalidPortionOfExpression;
	//private constructor.
	CParserException() {
	}
};

bool G_Radian;
////////////////////////////////////////////////////////////////////////////////
//Functions that the parser accepts and uses
//Users can also assign their own functions

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _avg(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT x[], const int count){
	if(count==0){
		return 0;
	}
	_ValueT sum=0;
	for(int i=0; i<count; i++){
		sum+=x[i];
	}
    return sum/(_ValueT)count;
}


//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _sum(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT x[], const int count){
	_ValueT sum=0;
	for(int i=0; i<count; i++){
		sum+=x[i];
	}
    return sum;
}

////////////////////////////////////////////////////////////////////////////////
//Logical operator functions:
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
// 
#ifdef _COMPLEX
template<typename _CharT, typename _ValueT> complex<double> _greater(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
	//Should we require imaginary parts to be 0?
	return p[0].real() > p[1].real();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> complex<double> _less(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
    return p[0].real() < p[1].real();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> complex<double> _ltEquals(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
    return p[0].real() <= p[1].real();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> complex<double> _gtEquals(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
    return p[0].real() >= p[1].real();
}

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _sqrt(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
  return sqrt(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _cotan(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
    return complex<double>(1)/std::tan(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _arctan(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
	return boost::math::atan(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> complex<double> _modulo(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
	//TODO: Check imaginary part:
	int p1 = (int)floor(p[0].real());
	int p2 = (int)floor(p[1].real());

	CHECK_INFINITY(p[0], _CharT, double);
	CHECK_INFINITY(CHECK_DIVBYZERO(p[1], _CharT), _CharT, double);
	return p1 % p2;
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _and(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
	
	return complex<double>(p[0].real() && p[1].real(), p[0].imag() && p[0].imag());
}

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _or(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
	return complex<double>(p[0].real() || p[1].real(), p[0].imag() || p[0].imag());
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _abs(CMathParser<_CharT, _ValueT> *pParentParser, const complex<double> p[], const int count){
    return abs(p[0]);
}
#endif //_COMPLEX


#ifdef _DECIMAL
template<typename _CharT, typename _ValueT> _ValueT _cotan(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
    return 1/p[0].tan();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _arctan(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
	return p[0].atan();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _modulo(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
	return p[0] % p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _and(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
    if(p[0]==0.0 || p[1]==0.0){ //will this equality really work?
    	return MAPM(0.0);
    }else{
    	return MAPM(1.0);
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _or(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
    if(p[0]!=0.0 || p[1]!=0.0){
    	return MAPM(1.0);
    }else{
    	return MAPM(0.0);
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _abs(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
    return p[0].abs();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _sqrt(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
#ifdef CATCH_FP_ERRORS_CHECKS
	if(p[0]<0){
		throw CParserException<_CharT>(_T("Error: value for square root must be greater than or equal to zero."));
	}
#endif
    return p[0].sqrt();
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _trunc(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
	MAPM temp = p[0].ceil();
	if(temp>p[0]){
		return temp-1;
	}
	if(temp<p[0]){
		return temp+1;
	}
    return temp;
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> MAPM _ceil(CMathParser<_CharT, _ValueT> *pParentParser, const MAPM p[], const int count){
	return p[0].ceil();
}


#endif //_DECIMAL

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _rnd(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return int(rand() * int(p[0]) / RAND_MAX); //RAND_MAX is the maximum _ValueT returned by the rand() function 
}

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _sign(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
	if (p[0] < 0)
      return -1;
    else
      if (p[0] > 0)
        return 1.0;
      else
        return 0.0;
}

template<typename _CharT, typename _ValueT> _ValueT _if(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return (p[0]!=0.0) ?  p[1] : p[2]; //TRUE if non-zero.
}
//Complex has it's own definitions for these functions
#ifndef _COMPLEX 
//------------------------------------------------------------------------------
// 
template<typename _CharT, typename _ValueT> _ValueT _greater(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
	return p[0] > p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _less(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0] < p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _ltEquals(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0] <= p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _gtEquals(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0] >= p[1];
}
#endif
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _not(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0]==0.0;
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _notEquals(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0]!=p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _equal(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0]==p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> double _and(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    return p[0] && p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> double _or(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    return p[0] || p[1];
}
////////////////////////////////////////////////////////////////////////////////
//Arithmetic functions:
//
template<typename _CharT, typename _ValueT> _ValueT _unaryadd(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
     return p[0];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _add(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0] + p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _subtract(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0] - p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _multiply(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return p[0] * p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _divide(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
	//CHECK_INFINITY(p[0], _CharT, _ValueT);
	//CHECK_INFINITY(CHECK_DIVBYZERO(p[1], _CharT), _CharT, _ValueT);
	return p[0] / p[1];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> double _modulo(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
	int p1 = (int)floor(p[0]);
	int p2 = (int)floor(p[1]);

	//CHECK_INFINITY(p[0], _CharT, double);
	//CHECK_INFINITY(CHECK_DIVBYZERO(p[1], _CharT), _CharT, double);
	return p1 % p2;
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _intdiv(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
	CHECK_INFINITY(p[1], _CharT, _ValueT);
    return floor(floor(p[0]) / CHECK_DIVBYZERO(floor(p[1]), _CharT));
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _negate(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return -p[0];
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _intpower(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return pow(p[0], floor(p[1]));
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _square(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return (p[0]*p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _power(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return pow(p[0], p[1]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _sin(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    if(G_Radian) {
        return sin(p[0]);
    }
    else {
        return sin(DegreesToRadians(p[0]));
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _cos(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    if(G_Radian) {
        return cos(p[0]);
    }
    else {
        return cos(DegreesToRadians(p[0]));
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _arctan(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
	return atan(p[0]);
}
//------------------------------------------------------------------------------
template<typename _CharT, typename _ValueT> _ValueT _arcsin(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    if(G_Radian) {
        return asin(p[0]);
    }
    else {
        return asin(DegreesToRadians(p[0]));
    }
}
//------------------------------------------------------------------------------
template<typename _CharT, typename _ValueT> _ValueT _arccos(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    if(G_Radian) {
        return acos(p[0]);
    }
    else {
        return acos(DegreesToRadians(p[0]));
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _arctanh(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    if(G_Radian) {
        return atanh(p[0]);
    }
    else {
        return atanh(DegreesToRadians(p[0]));
    }
}
//------------------------------------------------------------------------------
template<typename _CharT, typename _ValueT> _ValueT _arcsinh(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    if(G_Radian) {
        return asinh(p[0]);
    }
    else {
        return asinh(DegreesToRadians(p[0]));
    }}
//------------------------------------------------------------------------------
template<typename _CharT, typename _ValueT> _ValueT _arccosh(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    if(G_Radian) {
        return acosh(p[0]);
    }
    else {
        return acosh(DegreesToRadians(p[0]));
    }}

//
template<typename _CharT, typename _ValueT> _ValueT _sinh(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    if(G_Radian) {
        return (exp(p[0])-exp(-p[0]))*0.5;
    } else {
        double t = DegreesToRadians(p[0]);
        return (exp(t)-exp(-t))*0.5;
    }
   // return sinh(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _cosh(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    if(G_Radian) {
        return (exp(p[0])+exp(-p[0]))*0.5;
    }
    else {
        double t = DegreesToRadians(p[0]);
            return (exp(t)+exp(-t))*0.5;
    }
}

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _tanh(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    if(G_Radian) {
        return tanh(p[0]);
    }
    else {
        double t = DegreesToRadians(p[0]);
        return tanh(t);
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _cotan(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
        if(G_Radian) {
            return 1/tan(p[0]);//CHECK_INFINITY(CHECK_DIVBYZERO(tan(p[0]),_CharT),_CharT, _ValueT);
        } else {
            return 1/tan(DegreesToRadians(p[0]));//CHECK_INFINITY(CHECK_DIVBYZERO(tan(DegreesToRadians(p[0])),_CharT),_CharT, _ValueT);

        }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _arccotan(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    if(G_Radian) {
        return (atan(1/p[0]));
    } else {
        return (atan(1/DegreesToRadians(p[0])));
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _tan(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    if(G_Radian) {
        return tan(p[0]);
    }
    else {
        return tan(DegreesToRadians(p[0]));
    }
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _exp(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return exp(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _ln(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return log(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _log10(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return log10(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _log2(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return log2(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _logN(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    //return CHECK_INFINITY(log(p[1]),_CharT, _ValueT)/CHECK_INFINITY(CHECK_DIVBYZERO(log(p[0]),_CharT),_CharT, _ValueT);
    return log(p[1])/log(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _sqrt(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
#ifdef CATCH_FP_ERRORS_CHECKS
	if(p[0]<0){
		//throw CParserException<_CharT>(_T("Error: value for square root must be greater than or equal to zero."));
	}
#endif
    return sqrt(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _cbrt(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
#ifdef CATCH_FP_ERRORS_CHECKS
	if(p[0]<0){
		//throw CParserException<_CharT>(_T("Error: value for cube root must be greater than or equal to zero."));
	}
#endif
    return cbrt(p[0]);
}

template<typename _CharT, typename _ValueT> _ValueT _nthrt(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
#ifdef CATCH_FP_ERRORS_CHECKS
	if(p[0]<0){
		//throw CParserException<_CharT>(_T("Error: value for NTH root must be greater than or equal to zero."));
	}
#endif
    return pow(p[0], (double)(1/p[1]));
}

double fact(double n) { return n == 1 ? n :n*fact(n-1);}
template<typename _CharT, typename _ValueT> _ValueT _fact(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
#ifdef CATCH_FP_ERRORS_CHECKS
	if(p[0]<1){
		//throw CParserException<_CharT>(_T("Error: value for factorial must be greater than or equal to 1."));
	}
#endif
    return fact(p[0]);
}

//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _abs(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    return fabs(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _min(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
	_ValueT minVal=p[0];
	for(int i=1; i<count; i++){
		if(p[i]<minVal){
			minVal = p[i];
		}
	}
	return minVal;
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _max(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
#ifndef _COMPLEX
	_ValueT maxVal=p[0];
	for(int i=1; i<count; i++){
		if(p[i]>maxVal){
			maxVal = p[i];
		}
	}
	return maxVal;
#else
	throw CParserException<_CharT>(_T("MAX function is not supported for complex numbers."));
#endif	
	
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> double _trunc(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
    return int(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> double _ceil(CMathParser<_CharT, _ValueT> *pParentParser, const double p[], const int count){
	return ceil(p[0]);
}
//------------------------------------------------------------------------------
//
template<typename _CharT, typename _ValueT> _ValueT _floor(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
	return floor(p[0]);
}

//------------------------------------------------------------------------------
template<typename _CharT, typename _ValueT> _ValueT _random(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count){
    return rand() * p[0] / RAND_MAX;
}


/**
 * Generic node, base class for all nodes. Expression given by the user as a string is parsed 
 * and then is represented by a tree of CNode objects.
 */
template<typename _ValueT> class CNode {
public:
	/**
	 * Node types. Not to require RTTI.
	 */
	enum NODE_TYPE {BASIC, VARIABLE, ONEPARAM, TWOPARAM, NPARAM};
	explicit CNode() {
	}
	/**
	 * Virtual destructor.
	 */
	virtual ~CNode() {
	}
	/**
	 * Return the value that this node evaluates to. This method will typically
	 * trigger a cascade of GetValue() calls in the expression tree that it represents
	 * and it will return the resulting value.
	 */
	virtual _ValueT GetValue()=0;
	/**
	 * Returns true if the variable or function whose address is given as a parameter used in this expression tree.
	 * Returns false if it is not found.
	 */
	virtual BOOL IsUsed(void *Addr)=0;
	/**
	 * Optimize evaluates constant values at compile time.
	 */
	virtual void Optimize()=0;
	/**
	 * Home made RTTI replacement.
	 */
	virtual NODE_TYPE GetType()=0;
};

/**
 * Node type that holds constant values. Expression given by the user is parsed and then represented
 * by a tree of CNode objects.
 */
template <typename _ValueT> class CBasicNode : public CNode<_ValueT> {
private:
	_ValueT Value;
public:
	explicit CBasicNode(_ValueT Val) :
		CNode<_ValueT>() {
		Value = Val;
	}
	virtual ~CBasicNode() {
	}
	/**
	 * Return the literal value.
	 */
	virtual _ValueT GetValue() {
		return Value;
	}
	/**
	 * Return FALSE since variables or functions cannot be found in CBasicNode.
	 */
	virtual BOOL IsUsed(void *Addr) {
		return FALSE;
	}
	/**
	 * Does nothing since there is nothing to optimize.
	 */
	virtual void Optimize() { //Optimize evaluates constant values at compile time.
		//nothing to do.
	}
	/**
	 * Returns CNode::BASIC as the node type.
	 */
	virtual typename CNode<_ValueT>::NODE_TYPE GetType() {
		return CNode<_ValueT>::BASIC;
	}
};

/**
 * Special case to improve performance. COneParamNode one parameter functions such as SIN(X).
 */
template <typename _CharT, typename _ValueT> class COneParamNode :
	public CNode<_ValueT> {
public:
	/**
	 * Parent parser instance. Used to call the user defined function implementation. In some cases,
	 * a user defined function can make use of the parser instance to solve domain specific problems.
	 */
	CMathParser<_CharT,_ValueT> *pParentParser;
	/**
	 * The only parameter of this function. For example X in SIN(X).
	 */
	CNode<_ValueT> *Child;
	/**
	 * User defined function to call.
	 */
	typename CMathParser<_CharT,_ValueT>::PParserFunction fPtr;
public:
	explicit COneParamNode(CMathParser<_CharT,_ValueT> *pParentParser, CNode<_ValueT> *ChildNode,
			typename CMathParser<_CharT,_ValueT>::PParserFunction FuncAddr) :
		CNode<_ValueT>() {
		Child = ChildNode;
		fPtr = FuncAddr;
		this->pParentParser = pParentParser; 
	}
	virtual ~COneParamNode() {
		delete Child;
	}
	/**
	 * Invoke the underlying function with the proper parameter and return the result.
	 * When the parameter's value is requested, this can trigger a series of GetValue() calls across the 
	 * expression sub-tree.
	 */
	virtual _ValueT GetValue() {
		_ValueT param_array[1];
		param_array[0] = Child->GetValue();
		_ValueT value = this->fPtr(pParentParser, param_array, 1);
		return value;
	}
	/**
	 * Is the function or the variable whose address is given used in this node tree?
	 */
	virtual BOOL IsUsed(void *Addr) {
		return (Addr == fPtr) || Child->IsUsed(Addr);
	}
	/**
	 * Optimize the node tree by evaluating constant sub-branches at expression compile time.
	 */
	virtual void Optimize() {
		CMathParser<_CharT, _ValueT>::OptimizeNode(Child);
	}
	/**
	 * Return CNode::ONEPARAM as the node type.
	 */
	virtual typename CNode<_ValueT>::NODE_TYPE GetType() {
		return CNode<_ValueT>::ONEPARAM;
	}
};

/**
 * Special case to improve performance. CTwoParamNode tow parameter functions such as POW(X,Y).
 */
template <typename _CharT, typename _ValueT> class CTwoParamNode :
	public CNode<_ValueT> {
public:
	/**
	 * Parent parser instance. Used to call the user defined function implementation. In some cases,
	 * a user defined function can make use of the parser instance to solve domain specific problems.
	 */
	CMathParser<_CharT,_ValueT> *pParentParser;
	/**
	 * The first parameter of this function. For example X in POW(X,Y).
	 */
	CNode<_ValueT> *Left;
	/**
	 * The second parameter of this function. For example Y in POW(X,Y).
	 */
	CNode<_ValueT> *Right;
	/**
	 * User defined function to call.
	 */
	typename CMathParser<_CharT,_ValueT>::PParserFunction fPtr;
public:
	explicit CTwoParamNode(CMathParser<_CharT,_ValueT> *pParentParser, CNode<_ValueT> *LeftNode, CNode<_ValueT> *RightNode,
			typename CMathParser<_CharT,_ValueT>::PParserFunction FuncAddr) :
		CNode<_ValueT>() {
		Left = LeftNode;
		Right = RightNode;
		fPtr = FuncAddr;
		this->pParentParser = pParentParser;
	}

	virtual ~CTwoParamNode() {
		delete Left;
		delete Right;
	}
	/**
	* Return the value of the sub-expression tree represented by this node.
	*/
	virtual _ValueT GetValue() {
		_ValueT param_array[2];
		param_array[0] = Left->GetValue();
		param_array[1] = Right->GetValue();
		_ValueT value = this->fPtr(pParentParser, param_array, 2);
		return value;
	}
	/**
	 * Is the function or the variables whose address is given used in this sub-expression?
	 */
	virtual BOOL IsUsed(void *Addr) {
		return (Addr == fPtr) || Left->IsUsed(Addr) || Right->IsUsed(Addr);
	}
	/**
	 * Optimize the sub-expression tree by evaluating constant sub-expressions at compile time.
	 */
	virtual void Optimize() {
		CMathParser<_CharT, _ValueT>::OptimizeNode(Left);
		CMathParser<_CharT, _ValueT>::OptimizeNode(Right);
	}
	/**
	 * Return CNode::TWOPARAM as the node type.
	 */
	virtual typename CNode<_ValueT>::NODE_TYPE GetType() {
		return CNode<_ValueT>::TWOPARAM;
	}
};

/**
 * CNParamNode represents functions that take any number of parameters.
 * For example SUM(P1, P2, P3, P4, .... ,PN)
 */
template <typename _CharT, typename _ValueT> class CNParamNode :
	public CNode<_ValueT> {
public:
	/**
	 * Parent parser instance. Used to call the user defined function implementation. In some cases,
	 * a user defined function can make use of the parser instance to solve domain specific problems.
	 */
	CMathParser<_CharT,_ValueT> *pParentParser;
	/**
	 * Nodes that represent the parameters of this function node. For example X,Y,Z in SUM(X,Y,Z).
	 */
	CNode<_ValueT> **nodes;
	/**
	 * Number of parameters that this node takes.
	 */
	int pCount;
	/**
	 * The function to call.
	 */
	typename CMathParser<_CharT,_ValueT>::PParserFunction fPtr;
	_ValueT* param_array; //used to pass values into the function that we call.
public:
	explicit CNParamNode(CMathParser<_CharT,_ValueT> *pParentParser, CNode<_ValueT> **nodes, int nodeCount,
			typename CMathParser<_CharT,_ValueT>::PParserFunction FuncAddr) :
		CNode<_ValueT>() {
		this->nodes = nodes;
		this->pCount = nodeCount;
		this->fPtr = FuncAddr;
		if (pCount>0) {
			param_array = new _ValueT[pCount];
		} else {
			param_array = NULL;
		}
		this->pParentParser = pParentParser;
	}
	virtual ~CNParamNode() {
		for (int i=0; i<pCount; i++) {
			delete nodes[i];
		}
		delete[] nodes;
		if (param_array!=NULL) {
			delete[] param_array;
		}
	}
	/**
	 * Return the computed value of this node.
	 */
	virtual _ValueT GetValue() {
		for (int i=0; i<pCount; i++) {
			param_array[i]=nodes[i]->GetValue();
		}
		//note that param_array can be null and pCount==0
		_ValueT value = this->fPtr(pParentParser, param_array, pCount);
		DEBUGOUT2("Returning: ", value);
		return value;
	}
	/**
	 * Is the variable or the function whose address is given used in the expression?
	 */
	virtual BOOL IsUsed(void *Addr) {
		if (Addr==fPtr) {
			return TRUE;
		}
		for (int i=0; i<pCount; i++) {
			if (nodes[i]->IsUsed(Addr)) {
				return TRUE;
			}
		}
		return FALSE;
	}
	/**
	 * Optimize the sub-expression by collapsing constant expressions.
	 */
	virtual void Optimize() {
		for (int i=0; i<pCount; i++) {
			CMathParser<_CharT, _ValueT>::OptimizeNode(nodes[i]);
		}
	}
	/**
	 * Return node type CNode::NPARAM
	 */
	virtual typename CNode<_ValueT>::NODE_TYPE GetType() {
		return CNode<_ValueT>::NPARAM;
	}
};

/**
 * A node that represents variables in the expression.
 */
template<typename _ValueT> class CVarNode : public CNode<_ValueT> {
private:
	_ValueT* pVar; //address of the variable in the variable list
public:
	explicit CVarNode(_ValueT* variable) :
		CNode<_ValueT>() {
		pVar = variable;
	}
	virtual ~CVarNode() {
		//delete pVar; MUST NOT delete here. It is the m_Variables list who will delete it later.
	}
	/**
	 * Return the value of the variable.
	 */
	virtual _ValueT GetValue() {
		return *pVar;
	}
	/**
	 * Does this node represent the variable whose address is passed as a parameter?
	 */
	virtual BOOL IsUsed(void *Addr) {
		return Addr==pVar;
	}
	/**
	 * Does nothing. Nothing to optimize in a variable.
	 */
	virtual void Optimize() {
		//Optimize evaluates constant values at compile time.
		//nothing to do in this case.
	}
	/**
	 * Return CNode::VARIABLE
	 */
	virtual typename CNode<_ValueT>::NODE_TYPE GetType() {
		return CNode<_ValueT>::VARIABLE;
	}
};

/**
 * A variable node for variables that are not predefined. Their values will be provided
 * by the application via callback function.
 */
template<typename _CharT, typename _ValueT> class CUnknownVarNode : public CNode<_ValueT> {
	typedef basic_string<_CharT> string_t;
private:
	/**
	 * Name of the variable that this node represents.
	 */
	string_t m_VarName;
	/**
	 * Math parser instance that will be used to resolve the value of the variable
	 * via callback.
	 */
	CMathParser<_CharT, _ValueT>* m_MathParser;
public:
	explicit CUnknownVarNode(CMathParser<_CharT, _ValueT>* Parser, const string_t varName) :
		CNode<_ValueT>() {
		m_VarName = varName;
		m_MathParser = Parser;
	}
	virtual ~CUnknownVarNode() {
		//delete pVar; MUST NOT delete here. It is the m_Variables list who will delete it later.
	}
	/**
	 * Return the value of the variable by invoking the variable callback function that is 
	 * registered on the parser instance.
	 */
	virtual _ValueT GetValue() {
		//if(m_MathParser->GetVariableCallback()==NULL){
		//	throw typename CMathParser<_CharT, _ValueT>::ParserException(_T("VariableCallback function is NULL, but expression contains an unknown variable."));
		//}
		return m_MathParser->GetVariableCallback()(m_MathParser, m_VarName);
	}
	/**
	 * This method answers the question "Is Variable XYZ used in this part of the expression?".
	 */
	virtual BOOL IsUsed(void *Addr) {
		if(Addr==NULL){
			return m_MathParser->m_VarNameToSearchFor==m_VarName;
		}
		return FALSE;
	}
	/**
	 * Nothing to optimize in this node. A No-op.
	 */
	virtual void Optimize() {
		//Optimize evaluates constant values at compile time.
		//nothing to do in this case.
	}
	/**
	 * Return CNode::VARIABLE
	 */
	virtual typename CNode<_ValueT>::NODE_TYPE GetType() {
		return CNode<_ValueT>::VARIABLE;
	}
};

/**
 * A utility class to hold the function pointer for a user defined function and the number of parameters
 * that are needed to call that function.
 */
template<typename functype> class FunctionEntry {
public:
	functype fPtr;
	int pCount;
	//_ValueT *params; //buffer to use to pass parameters while calling this function.
	explicit FunctionEntry(functype funcAddr, int paramCount) {
		this->fPtr = funcAddr;
		this->pCount = paramCount;
		//params = new _ValueT[paramCount];
	}
	//destructor:
	//~FunctionEntry(){
	//	delete[] params;
	//}
};

/**
 * CMathParser C++ template class parses and evaluates expressions given as string at runtime.
 * User can define variables, functions, set variable values, 
 * set a mathematical expression and request that it's value be computed.
 * CMathParser will convert the string expression to an internal representation of a tree
 * structure. If Optimization is turned on, it will walk the tree to convert non-parametric 
 * branches (branches whose values do not depend on variables) into a constant value. 
 * Once this is done successfully, the expression can be evaluated very quickly for 
 * different variable values.
 */
template<typename _CharT, typename _ValueT> class CMathParser {
	friend class COneParamNode<_CharT, _ValueT>;
	friend class CTwoParamNode<_CharT, _ValueT>;
	friend class CNParamNode<_CharT, _ValueT>;
	friend class CUnknownVarNode<_CharT, _ValueT>;

public:
	/**
	 * String type used in variable, function names, and reporting messages.
	 * It is nothing but a basic_string<> of std.
	 */
	typedef basic_string<_CharT> string_t;

	/**
	 * ParserFunction type specifies the prototype of the functions that users can
	 * add to the list of available functions with N parameters to be used in an expression.
	 * p[] array holds the value for each paramater.
	 * count is the number of paramaters (number of elements in p[]). 
	 */
	typedef _ValueT ParserFunction(CMathParser<_CharT, _ValueT> *pParentParser, const _ValueT p[], const int count);

	typedef ParserFunction* PParserFunction;

	/**
	 * VariableCallback is a callback function that is implemented by the user to provide
	 * the values for variables that are not predefined before parse operation.
	 * Please see CMathParser::setVariableCallback(VariableCallback) for more information.   
	 */
	typedef _ValueT VariableCallback(CMathParser<_CharT, _ValueT> *pParentParser, const string_t varName);

	typedef VariableCallback* PVariableCallback;
	
	/**
	 * Errors are reported as ParserException.
	 */
	typedef CParserException<_CharT> ParserException;

protected:
	typedef map <string_t, _ValueT*, less<string_t> > TVarMap;
	typedef map <string_t, FunctionEntry<PParserFunction>*, less<string_t> >
			TFunctionMap;
	
private:
	_CharT m_temp[MAX_NAME_LEN+1]; //for temporary use

	/**
	 * expression to parse.
	 */
	string_t m_Expression;

	/**
	 * Flag that tells we need to parse again before we can evaluate.
	 */
	BOOL m_Dirty;
	/**
	 * Optimize constant expression sub-trees or not?
	 */	
	BOOL m_OptimizationOn;

	/**
	 * Root node of expression tree.
	 */
	CNode<_ValueT>* m_Node;

	/**
	 * Map of variable names to variable addresses.
	 */
	TVarMap m_Variables;

	/**
	 * Map of function names to function addresses.
	 */
	TFunctionMap m_Functions;

	/**
	 * A callback function that is implemented by the user to provide values for undefined variables.
	 * If m_VariableCallback is NULL, all variables in the expression must be defined before parsing.
	 */
	PVariableCallback m_VariableCallback;
	
	/**
	 * A temporary variable to hold the value of a variable name we are currently searching.
	 * This is hack to implement CUnknownVarNode::IsUsed() method in a backward compatible way.
	 */
	string_t m_VarNameToSearchFor;
	
	/**
	 * Is a given character value within valid range
	 * to be used in a function or variable name?
	 */
	static BOOL isValidChar(int index, _CharT c) {
		if (index==0) {
			if ( (c>='A') && (c<='Z') ) {
				return TRUE;
			}
			if (c=='_') {
				return TRUE;
			}
			return FALSE;
		}
		if ( ((c>='A') && (c<='Z')) || ((c>='0') && (c<='9') )) {
			return TRUE;
		}
		if (c=='_') {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * Trim spaces from both ends of a string.
	 */
	static string_t Trim(const string_t val) {
		int len = (int)val.length();
		int st = 0;

		while ((st < len) && (val[st] <= ' ')) {
			st++;
		}
		while ((st < len) && (val[len - 1] <= ' ')) {
			len--;
		}
		return ((st > 0) || ((unsigned int)len < val.length())) ? val.substr(
				st, len-st) : val;
	}

	/**
	 * RemoveChars given chars from given string.
	 */
	static string_t RemoveChars(const string_t &str, _CharT chrToRemove) {
		string_t temp;
		int i;
		int len = str.length();

		for (i=0; i<len; i++) {
			if (str[i]!=chrToRemove)
				temp+= str[i];
		}
		return temp;
	}

	/**
	 * Valid name definition for function and variable names.
	 */
	static BOOL isValidName(const string_t name) {
		unsigned int len = (int)name.length();
		for (unsigned int i=0; i<len; i++) {
			if (!isValidChar(i, name[i])) {
				return FALSE;
			}
		}
		return TRUE;
	}

	/**
	 * Trims surplus brackets from both ends of the expression as long as expression value
	 * is not effected by this change.
	 */
	static BOOL RemoveOuterBrackets(string_t &formula) { //removes unncessary outer brackets in an expression
		string_t temp;
		int Len;
		bool result = FALSE;

		//has to be careful about (X+1)-(Y-1)
		//should not remove the outer brackets here thinking that they are unnecessary
		//but should remove when ((X+1)-(Y-1))
		temp = formula;
		//ShowMessage(copy('hello', 2, 0));
		//Copy('hello', 2, 0) does not return empty string!!
		Len = (int)temp.length();
		while ((Len>2) && (temp[0] == '(') && (temp[Len-1] == ')')) {
			temp = temp.substr(1, temp.length()-2);

			//trim the spaces: ((  (X)))-2
			string::size_type pos1 = temp.find_first_not_of(' ');
			string::size_type pos2 = temp.find_last_not_of(' ');
			if (pos1 != string::npos) {
				if (pos2 != string::npos) {
					temp=temp.substr(pos1, pos2 - pos1 + 1);
				} else {
					temp=temp.substr(pos1, temp.length()-pos1+1);
				}
			} else {
				if (pos2 != string::npos) {
					temp=temp.substr(0, pos2 + 1);
				}
			}

			if (CheckBrackets(temp)==-1) { //if we did not screw up then assign to the return value
				result = TRUE;
				formula = temp;
			}
			Len = (int)temp.length();
		}
		return result;
	}
	/**
	 * Return TRUE if given expression is a valid literal value for _ValueT.
	 * Use this one for wchar_t.
	 */
	static BOOL IsValidNumber(const basic_string<wchar_t> &formula,
			_ValueT &Number) {
		wchar_t *endptr = 0;
		//There needs to be a = operator for _ValueT that converts a double into _ValueT. 
		Number = wcstod(formula.c_str(), &endptr);
		return (0 == *endptr); //if TRUE then it is a number, endptr is the position the error occured.
	}
	/**
	 * Return TRUE if given expression is a valid literal value for _ValueT.
	 * Use this one for char.
	 */
	static BOOL IsValidNumber(const basic_string<char> &formula, _ValueT &Number) {
		char *endptr = 0;
		//There needs to be a = operator for _ValueT that converts a double into _ValueT. 
		Number = strtod(formula.c_str(), &endptr);
		return (0 == *endptr); //if TRUE then it is a number, endptr is the position the error occured.
	}

	/**
	 * Convert a string to uppercase. 
	 */
	static inline string_t ToUpper(string_t str) {
		const int length = (const int)str.length();
		string_t temp;
		for (int i=0; i!=length; ++i) {
			temp+= toupper(str[i]);
		}
		return temp;
	}

	/**
	 * Verify that the brackets of an expression are not messed up.
	 * For example, this expression's brackets are not valid:
	 * "X+((Y*3)"
	 */
	static int CheckBrackets(const string_t &formula) {
		//this function checks to see if the order and number of brackets are correct
		//it will say ok if it sees something like 3+()()
		int i, n=0, len = (int)formula.length();
		for (i = 0; i<len; i++) { //if length<1 loop won't execute
			if (formula[i] == '(')
				++n;
			else if (formula[i] == ')')
				--n;

			if (n<0)
				return i; //at any moment if expression is valid we cannot have more ) then (
		}
		return (n == 0) ? -1 : len;
	}

	/**
	 * Optimize a given node.
	 */
	static void OptimizeNode(CNode<_ValueT> * &Node) {
		Node->Optimize();
		if (Node->GetType()==CNode<_ValueT>::TWOPARAM) {
			CTwoParamNode<_CharT, _ValueT> *twoParamNode =
					(CTwoParamNode<_CharT, _ValueT>*)Node;
			if (twoParamNode->Left->GetType()==CNode<_ValueT>::BASIC
					&& twoParamNode->Right->GetType()==CNode<_ValueT>::BASIC) {
				CBasicNode<_ValueT> *NewNode;
				NewNode = new CBasicNode<_ValueT>(twoParamNode->GetValue());

				delete Node;
				Node = NewNode;
			}
			return;
		}

		if (Node->GetType()==CNode<_ValueT>::ONEPARAM) {
			COneParamNode<_CharT, _ValueT> *oneParamNode =
					(COneParamNode<_CharT, _ValueT>*)Node;
			if (oneParamNode->Child->GetType()==CNode<_ValueT>::BASIC) {
				CBasicNode<_ValueT> *NewNode;
				NewNode = new CBasicNode<_ValueT>(oneParamNode->GetValue());

				delete Node;
				Node = NewNode;
			}
			return;
		}

		if (Node->GetType()==CNode<_ValueT>::NPARAM) {
			CNParamNode<_CharT, _ValueT> *nParamNode =
					(CNParamNode<_CharT, _ValueT>*)Node;
			bool optimizeable = TRUE;
			for (int i=0, n=nParamNode->pCount; i<n; i++) {
				if (nParamNode->nodes[i]->GetType()!=CNode<_ValueT>::BASIC) {
					optimizeable=FALSE;
					break;
				}
			}
			if (optimizeable) {
				CBasicNode<_ValueT> *NewNode;
				NewNode = new CBasicNode<_ValueT>(nParamNode->GetValue());
				delete Node;
				Node = NewNode;
			}
			return;
		}
	}

	/**
	 * Convert an integer to string representation.
	 */
	string_t ToString(int i) {
		//itow_s(MAX_NAME_LEN, m_temp, MAX_NAME_LEN+1, 10);
		//return m_temp;
		basic_stringstream<_CharT> ss;
		ss << i;
		return ss.str();
	}

	/**
	 * Is the function or variable name too long?
	 */
	static void CheckName(const string_t upcName, const string_t varName)
			throw(ParserException) {
		if (upcName.length()>MAX_NAME_LEN) {
			string_t err = varName;
			err
					+= _T(" is too long. Maximum possible function or variable name length is ");
			err+= MAX_NAME_LEN_STR;
			err+= _T(".");
			throw ParserException(err);
		}
		for (unsigned int i = 0; i<upcName.length(); i++) {
			if ( !isValidChar(i, upcName[i]) ) { //must contain uppercase letters only
				string_t err = varName;
				err += _T(" is not a valid function or variable name.");
				throw ParserException(err);
			}
		}
	}

#ifdef CATCH_FP_ERRORS
	/**
	 * Error messages for structured exceptions.
	 * Disabled for now. GCC does not have fp control.
	 */
	 static CHAR_TYPE* GetStructuredExceptionMessage(int code){
		switch(code){
		 case EXCEPTION_ACCESS_VIOLATION: return _T("The thread attempts to read from or write to a virtual address for which it does not have access."); 
		 case EXCEPTION_ARRAY_BOUNDS_EXCEEDED: return _T("The thread attempts to access an array element that is out of bounds, and the underlying hardware supports bounds checking. ");
		 case EXCEPTION_BREAKPOINT: return _T("A breakpoint is encountered.");
		 case EXCEPTION_DATATYPE_MISALIGNMENT: return _T("The thread attempts to read or write data that is misaligned on hardware that does not provide alignment. For example, 16-bit values must be aligned on 2-byte boundaries, 32-bit values on 4-byte boundaries, and so on."); 
		 case EXCEPTION_FLT_DENORMAL_OPERAND: return _T("One of the operands in a floating point operation is denormal. A denormal value is one that is too small to represent as a standard floating point value."); 
		 case EXCEPTION_FLT_DIVIDE_BY_ZERO: return _T("The thread attempts to divide a floating point value by a floating point divisor of 0 (zero)."); 
		 case EXCEPTION_FLT_INEXACT_RESULT: return _T("The result of a floating point operation cannot be represented exactly as a decimal fraction."); 
		 case EXCEPTION_FLT_INVALID_OPERATION: return _T("An invalid floating point operation exception occured."); 
		 case EXCEPTION_FLT_OVERFLOW: return _T("The exponent of a floating point operation is greater than the magnitude allowed by the corresponding type."); 
		 case EXCEPTION_FLT_STACK_CHECK: return _T("The stack has overflowed or underflowed, because of a floating point operation."); 
		 case EXCEPTION_FLT_UNDERFLOW: return _T("The exponent of a floating point operation is less than the magnitude allowed by the corresponding type."); 
		 case EXCEPTION_ILLEGAL_INSTRUCTION: return _T("The thread tries to execute an invalid instruction."); 
		 case EXCEPTION_IN_PAGE_ERROR: return _T("The thread tries to access a page that is not present, and the system is unable to load the page. For example, this exception might occur if a network connection is lost while running a program over a network."); 
		 case EXCEPTION_INT_DIVIDE_BY_ZERO: return _T("The thread attempts to divide an integer value by an integer divisor of 0 (zero)."); 
		 case EXCEPTION_INT_OVERFLOW: return _T("The result of an integer operation causes a carry out of the most significant bit of the result."); 
		 case EXCEPTION_INVALID_DISPOSITION: return _T("An exception handler returns an invalid disposition to the exception dispatcher. Programmers using a high-level language such as C should never encounter this exception.");
		 case EXCEPTION_NONCONTINUABLE_EXCEPTION: return _T("The thread attempts to continue execution after a non-continuable exception occurs."); 
		 case EXCEPTION_PRIV_INSTRUCTION: return _T("The thread attempts to execute an instruction with an operation that is not allowed in the current computer mode."); 
		 case EXCEPTION_SINGLE_STEP: return _T("A trace trap or other single instruction mechanism signals that one instruction is executed."); 
		 case EXCEPTION_STACK_OVERFLOW: return _T("The thread uses up its stack."); 
		 default: return _T("Unknown error."); 
		}
	 }
#endif

public:
	/**
	 * Constructor to create a CMathParser instance.
	 * It initializes member variables and creates default functions and variables.
	 */
	CMathParser() {
		m_Expression = _T("");
		m_Node = NULL;
		m_Dirty = TRUE; //means it is not parsed yet.
		m_OptimizationOn = FALSE;
		m_VariableCallback = NULL;

		CreateDefaultFuncs();
		CreateDefaultVars();
#ifdef _COMPLEX
		SetVariable(_T("I"), complex<double>(0,1)); //The i constant: sqrt(-1)
#endif
	}

	/**
	 * Virtual destructor to free memory.
	 */
	virtual ~CMathParser() {
		if(m_Node!=NULL){
			delete m_Node;
			m_Node=NULL; //prevent a double delete.
		}
		DeleteAllVars(); //we need to dispose the pointers that hold numbers.
		DeleteAllFuncs();
	}

public:

	/**
	 * Parse the expression. It is fast to parse the expression once, 
	 * then loop to evaluate the expression multiple times by setting different variable 
	 * values.
	 * throws CMathParser::ParserException on error. 
	 */
	void Parse() throw (ParserException) {
		string_t temp = m_Expression;
		unsigned int i;

		if (! (temp.length() > 0)) {
			if(m_Node!=NULL){
				delete m_Node;
				m_Node=NULL; //prevent a double delete.
			}
			string_t err= _T("Expression is empty.");
			throw ParserException(err);
		}

		//we will check for uppercase version of function defs
		for (i = 0; i<temp.length(); i++){
			temp[i] = towupper(temp[i]);
		}

		unsigned int len = (unsigned int)temp.length();
		for (i = 0; i<len; i++) {
			if ((temp[i] == '[') || (temp[i] == '{')) { //scanning half way from start
				temp[i] = '(';
			} else if ((temp[i] == ']') || (temp[i] == '}')) {
				temp[i] = ')';
			}
		}

		//free the previous parse tree
		if(m_Node!=NULL){
			delete m_Node;
			m_Node=NULL; //prevent a double delete.
		}

		//call the recursive parsing function to generate the node structure tree
		if (CheckBrackets(temp)>-1) {
			string_t err= _T("Brackets do not match in expression ");
			err+= m_Expression;
			throw ParserException(err, temp);
		}

		CreateParseTree(temp, m_Node); //will throw ParserException if need be.
		//On exception, m_Node can be freed by next expression use, or by Parser destructor.

		/*
		 if (!SUCCEEDED(m_LastErr))
		 {
		 delete m_Node; //free doesn't assign nil to the pointer...
		 m_Node = NULL;
		 return m_LastErr;
		 }
		 */

		if (m_OptimizationOn) {
			Optimize(); //will make sure m_Node tree is lean and mean
		}

		m_Dirty = FALSE; //note that we parsed it once. Unless the expression is changed we do not need to reparse it.
	}

	/**
	 * Returns TRUE if the given function name is already registered as a function.
	 */
	inline BOOL IsFunction(string_t funcName) {
		string_t upcName = ToUpper(funcName);
		return m_Functions.find(upcName) != m_Functions.end();
	}

	/**
	 * Returns TRUE if the given variable name is already registered as a variable.
	 */
	inline BOOL IsVariable(string_t varName) {
		string_t upcName = toUpper(varName);
		return m_Variables.find(upcName) != m_Variables.end();
	}

	/**
	 * Return TRUE if a given variable was used in the current expression.
	 * Return FALSE if the expression does not contain this variable.
	 * Throw CMathParser::ParserException if the expression cannot be parsed.
	 */
	BOOL IsVariableUsed(string_t varName) throw (ParserException) {
		Parse(); //to create parse tree if it is not created yet.
		string_t upcName = ToUpper(varName);
		typename TVarMap::iterator iter = m_Variables.find(upcName);
		if (iter != m_Variables.end()) {
			if ((*iter).second != NULL) { //we need to check if it is not null, because there might be some null pointers in the tree
				return m_Node->IsUsed((*iter).second);
			}
		}else{
			m_VarNameToSearchFor = varName;
			BOOL rc = m_Node->IsUsed(NULL);
			m_VarNameToSearchFor = _T("");
			return rc;
		}
		return FALSE;
	}

	/**
	 * Return TRUE if a given function is being used in the current expression.
	 * Return FALSE if the expression is not using the function.
	 * Throw CMathParser::ParserException if the expression cannot be parsed.
	 */
	BOOL IsFuncUsed(string_t funcName) throw (ParserException) {
		Parse(); //to create parse tree if it is not created yet.
		string_t upcName = ToUpper(funcName);
		typename TFunctionMap::iterator oneIter = m_Functions.find(upcName);
		if (oneIter != m_Functions.end()) {
			if ((*oneIter).second != NULL) { //we need to check if it is not null, because there might be some null pointers in the tree
				return m_Node->IsUsed((void*)(*oneIter).second->fPtr);
			}
		}
		return FALSE;
	}

	/**
	 * Free the parse tree that was used to parse previous expression.
	 * This does not have to be called explicitly. 
	 * This is only useful for an unusual case where a very big expression was
	 * parsed and tree takes alot of memory and you want to free it because
	 * you will not use the parser instance for a while.
	 * Otherwise, next expression parse will delete previous tree.
	 */
	void FreeParseTree() {
		delete m_Node;
		m_Node = NULL;
		m_Dirty = TRUE; //so that next time we call Evaluate, it will call the Parse method.
	}

	/**
	 * Init random _ValueT generator for rnd built-in function.
	 */
	inline void Randomize() {
		time_t seconds = time(NULL);
		srand(seconds); //time() function does not compile in WinCE 5
	}

	/**
	 * Delete all functions defined for the parser.
	 */
	void DeleteAllFuncs() {
		typename TFunctionMap::iterator iter = m_Functions.begin();
		typename TFunctionMap::iterator end = m_Functions.end();
		while (iter != end) {
			delete (*iter++).second;
		}
		m_Functions.erase(m_Functions.begin(), end);
		m_Dirty = TRUE;
	}

	/**
	 * Delete all defined variables.
	 */
	void DeleteAllVars() {
		typename TVarMap::iterator iter = m_Variables.begin();
		typename TVarMap::iterator end = m_Variables.end();
		while (iter != end) {
			delete (*iter++).second;
		}
		m_Variables.erase(m_Variables.begin(), end);
		m_Dirty = TRUE;
	}

	/**
	 * Delete a function from defined functions list.
	 * Ignore if not found.
	 */
	void DeleteFunc(string_t funcName) {
		//this function deletes the variable only if it finds it.
		string_t upcName = ToUpper(funcName);
		typename TFunctionMap::iterator oneIter = m_Functions.find(upcName);
		if (oneIter != m_Functions.end() ) {
			delete (*oneIter).second;
			m_Functions.erase(oneIter);
			m_Dirty = TRUE;
		}
	}

	/**
	 * Delete an existing variable name.
	 * If it does not exist, it is ignored.
	 */
	void DeleteVar(string_t varName) {
		//this function deletes the variable only if it finds it.
		string_t upcName = toUpper(varName);

		typename TVarMap::iterator iter = m_Variables.find(upcName);
		if (iter != m_Variables.end()) //to use TStringList.Find the list must be sorted.
		{
			delete (*iter).second; //delete the _ValueT pointer stored in the map
			m_Variables.erase(iter);
			m_Dirty = TRUE;
		}
		//if the variable does not exist, ignore.
	}
	;

	/**
	 * Define a variable with initial value. 
	 */
	inline void CreateVar(string_t varName, _ValueT varValue) {
		SetVariable(varName, varValue);
	}

	/**
	 * Create a user defined function with given name, number of params, function address to call.
	 * The uppercase version of given function name can be used in the expressions.
	 * If the expression does not specify correct number of parameters, then a
	 * CMathParser::ParserException will be thrown during parsing. if number of parameters is specified as -1, then the
	 * function can take 1 or more number of parameters. Number of parameters will not be verified
	 * during parse operation.
	 * If invalid number of parameters are passed to a function, the function implementation itself can choose
	 * to throw exception during evaluate operation.
	 */
    inline double DegreeToRadian(double d) {
        return d * 3.14159265358979/ 180;
    }
    
	void CreateFunc(string_t newFuncName, int numParams,
			PParserFunction funcAddress) throw(ParserException) {
		string_t newName = ToUpper(newFuncName);
		CheckName(newName, newFuncName); //throw excetion if not valid.

		if (IsFuncRegistered(newName)) {
			string_t err= _T("Function ");
			err += newFuncName;
			err += _T(" already exists.");
			throw ParserException(err);
		} else {
			//if newFuncName doesn't exist it is inserted:
			m_Functions[newName] = new FunctionEntry<PParserFunction>(funcAddress,numParams); //add the variables and the object to hold the value with it.
		}
		m_Dirty= TRUE; //previously bad expression may now be ok, we should reparse it
	}

	/**
	 * Create default built-in variables such as X, Y, PI.
	 * Override to define different set of variables.
	 */
	virtual void CreateDefaultVars() {
		CreateVar(_T("X"), 0.0);
		CreateVar(_T("Y"), 0.0);
		CreateVar(_T("PI"), 3.14159265358979);
        CreateVar(_T("E"),  2.71828182845905);
	}

	/**
 	* Create default functions. 
 	* You can override CreateDefaultFuncs to define (or not define) 
 	* a different set of functions. 
 	* 
 	* Predefined functions that take one parameter are: 
	*	 SQR: Square function which can be used as SQR(X) 
	*
	*	 SIN: Sinus function which can be used as SIN(X), X is a real-type expression. Sin returns the sine of the angle X in radians. 
	*
	*	 COS: Cosinus function which can be used as COS(X), X is a real-type expression. COS returns the cosine of the angle X in radians. 
	*
	*	 ATAN: ArcTangent function which can be used as ATAN(X) 
	*
	*	 SINH: Sinus Hyperbolic function which can be used as SINH(X) 
	*
	*	 COSH: Cosinus Hyperbolic function which can be used as COSH(X) 
	*
	*	 COTAN: which can be used as COTAN(X) 
	*
	*	 TAN: which can be used as TAN(X) 
	*
	*	 EXP: which can be used as EXP(X) 
	*
	*	 LN: natural log, which can be used as LN(X) 
	*
	*	 LOG: 10 based log, which can be used as LOG(X) 
	*
	*	 SQRT: which can be used as SQRT(X) 
	*
	*	 ABS: absolute value, which can be used as ABS(X) 
	*
	*	 SIGN: SIGN(X) returns -1 if X<0; +1 if X>0, 0 if X=0; it can be used as SQR(X) 
	*
	*	 TRUNC: Discards the fractional part of a number. e.g. TRUNC(-3.2) is -3, TRUNC(3.2) is 3. 
	*
	*	 CEIL: CEIL(-3.2) = -3, CEIL(3.2) = 4 
	*
	*	 FLOOR: FLOOR(-3.2) = -4, FLOOR(3.2) = 3 
	*
	*	 RND:  Random number generator. 
	*
	*	 RND(X) generates a random INTEGER number such that 0 <= Result < int(X). Call Parser.Randomize to initialize the random number generator with a random seed value before using RND function in your expression. 
	*
	*	 RANDOM: Random number generator. 
	*
	*	 RANDOM(X) generates a random floating point number such that 0 <= Result < X. Call Parser.Randomize to initialize the random number generator with a random seed value before using RANDOM function in your expression. 
	*
	*	 Predefined functions that take two parameters are: 
	*
	*	 INTPOW: The INTPOW function raises Base to an integral power. INTPOW(2, 3) = 8. Note that result of INTPOW(2, 3.4) = 8 as well. 
	*
	*	 POW: The Power function raises Base to any power. For fractional exponents or exponents greater than MaxInt, Base must be greater than 0. 
	*
	*	 LOGN: The LogN function returns the log base N of X. Example: LOGN(10, 100) = 2 
	*
	*	 MIN: MIN(2, 3, 4, 5) is 2. 
	*
	*	 MAX: MAX(2, 3, 1, 0) is 3. 
	*
	*	 IF: IF(1, 2, 3) is 2.
	*
	*	 SUM: SUM(1, 2, 3, 4) is 10.
	*
	*	 AVG: AVG(1, 2, 3, 4, 5) is 3.
	* 
	*/
	virtual void CreateDefaultFuncs() {
#ifdef PREDEFINE_FUNCTIONS
		CreateFunc(_T("SQR"), 1, (PParserFunction)_square);
		CreateFunc(_T("SIN"), 1, (PParserFunction)_sin);
		CreateFunc(_T("COS"), 1, (PParserFunction)_cos);
		CreateFunc(_T("ATAN"), 1, (PParserFunction)_arctan);
        CreateFunc(_T("ASIN"), 1, (PParserFunction)_arcsin);
        CreateFunc(_T("ACOS"), 1, (PParserFunction)_arccos);
		CreateFunc(_T("SINH"), 1, (PParserFunction)_sinh);
		CreateFunc(_T("COSH"), 1, (PParserFunction)_cosh);
		CreateFunc(_T("COTAN"),1, (PParserFunction)_cotan);
		CreateFunc(_T("COT"),1, (PParserFunction)_cotan);        
        CreateFunc(_T("ACOTAN"),1,(PParserFunction)_arccotan);
		CreateFunc(_T("TAN"), 1, (PParserFunction)_tan);
        CreateFunc(_T("TANH"), 1, (PParserFunction)_tanh);
		CreateFunc(_T("ATANH"), 1, (PParserFunction)_arctanh);
        CreateFunc(_T("ASINH"), 1, (PParserFunction)_arcsinh);
        CreateFunc(_T("ACOSH"), 1, (PParserFunction)_arccosh);
		CreateFunc(_T("EXP"), 1, (PParserFunction)_exp);
		CreateFunc(_T("LN"), 1, (PParserFunction)_ln);
		CreateFunc(_T("LOG"), 1, (PParserFunction)_log10);
		CreateFunc(_T("LOG2"), 1, (PParserFunction)_log2);
		CreateFunc(_T("SQRT"), 1, (PParserFunction)_sqrt);
		CreateFunc(_T("CBRT"), 1, (PParserFunction)_cbrt);
		CreateFunc(_T("ABS"), 1, (PParserFunction)_abs);
        CreateFunc(_T("NTHRT"), 2, (PParserFunction)_nthrt);
        CreateFunc(_T("FACT"), 1, (PParserFunction) _fact);
#ifndef _COMPLEX
		CreateFunc(_T("SIGN"), 1, (PParserFunction)_sign);
		CreateFunc(_T("TRUNC"), 1, (PParserFunction)_trunc);
		CreateFunc(_T("CEIL"), 1, (PParserFunction)_ceil);
		CreateFunc(_T("FLOOR"), 1, (PParserFunction)_floor);
		#ifndef _DECIMAL
		CreateFunc(_T("RND"), 1, (PParserFunction)_rnd);
		#endif
		CreateFunc(_T("RANDOM"), 1, (PParserFunction)_random);
		CreateFunc(_T("MIN"), -1, (PParserFunction)_min);
		CreateFunc(_T("MAX"), -1, (PParserFunction)_max);
		CreateFunc(_T("MOD"), 2, (PParserFunction)_modulo); //2 params.
		CreateFunc(_T("INTPOW"), 2, (PParserFunction)_intpower);
#endif
		CreateFunc(_T("POW"), 2, (PParserFunction)_power);
		CreateFunc(_T("LOGN"), 2, (PParserFunction)_logN);
		CreateFunc(_T("IF"), 3, (PParserFunction)_if); //3 params
		CreateFunc(_T("SUM"), -1, (PParserFunction)_sum); //any number of params.
		CreateFunc(_T("AVG"), -1, (PParserFunction)_avg);
#endif
	}

	/**
	 * Evaluate the expression to it's value.
	 * Throw CMathParser::ParserException if the expression can not be parsed.
	 */
	_ValueT Evaluate() throw (ParserException) {
		if (m_Dirty) { //if the expression has been changed, we need to parse it again
			Parse(); //may throw exception.
		}

		_ValueT val;

#ifdef CATCH_FP_ERRORS
		unsigned int cw;
		unsigned int originalCW;

		//Set the x86 floating-point control word according to what
		//exceptions you want to trap. 
		_clearfp(); //Always call _clearfp before setting the control word.

		//Because the second parameter in the following call is 0, it
		//only returns the floating-point control word
		
		_controlfp_s(&cw, 0, 0); //Get the default control word.

		//Set the exception masks off for exceptions that you want to
		//trap.  When a mask bit is set, the corresponding floating-point
		//exception is blocked from being generating.
		cw &=~(EM_OVERFLOW|EM_UNDERFLOW|EM_ZERODIVIDE|
			   EM_DENORMAL|EM_INVALID);

		//For any bit in the second parameter (mask) that is 1, the 
		//corresponding bit in the first parameter is used to update
		//the control word.

		_controlfp_s(&originalCW, cw, MCW_EM); //Set it.
		//MCW_EM is defined in float.h.

		__try{
			//set the return value:
			val = m_Node->GetValue(); //this will start the chain reaction to get the
										//value of all nodes
		}
		//http://www.devx.com/cplus/Article/34993/1954
		__except(EXCEPTION_EXECUTE_HANDLER) {
			int code = GetExceptionCode();
			//__asm fnclex;
			_clearfp();

			//restore original value not to effect others:
			_controlfp_s(&cw, originalCW, MCW_EM);

			throw ParserException(GetStructuredExceptionMessage(code));
		}

		//restore original value not to effect others:
		_controlfp_s(&cw, originalCW, MCW_EM);
#else
		//this will start the chain reaction to get the value of all nodes
		val = m_Node->GetValue(); 
#endif

		DEBUGOUT2("Result is: ", val);
		return val;
	}

	/**
	 * Return current optimization setting.
	 * If OptimizationOn is set to TRUE, then the parser will eliminate 
	 * expression sub-trees that evaluate to a constant expression so that 
	 * they can be skipped in repeated evaluations.
	 */
	inline BOOL GetOptimizationOn() {
		return m_OptimizationOn;
	}

	/**
	 * If OptimizationOn is set to TRUE, then the parser will eliminate 
	 * expression sub-trees that evaluate to a constant expression so that 
	 * they can be skipped in repeated evaluations.
	 */
	inline void SetOptimizationOn(BOOL newVal) {
		m_OptimizationOn=newVal;
	}

	/**
	 * Set the value of a variable. This will define the variable if it is not defined yet.
	 */
	void SetVariable(string_t varName, _ValueT varValue) throw(ParserException) {
		string_t upcName = ToUpper(varName);

		if (m_Variables.find(upcName)!=m_Variables.end()) {
			*(m_Variables[upcName]) = varValue;
		} else {
			//if the variable does not exist, create it and assign the value:
			CheckName(upcName, varName);
			//new it up, so it's location in heap does not change.
			//we will point to it.
			_ValueT* pValue = new _ValueT();
			*pValue = varValue;
			m_Variables[upcName] = pValue;
		}
	}

	/**
	 * Get the current value of a variable.
	 * Throws CMathParser::ParserException if variable is not defined yet.
	 */
	_ValueT GetVariable(string_t varName) {
		string_t upcName = toUpper(varName);
		if (m_Variables.find(upcName) == m_Variables.end()) {
			string_t err= _T("Variable ");
			err += varName;
			err += _T(" does not exist.");
			throw ParserException(err);
		}
		return m_Variables[upcName];
	}

	/**
	 * Return value of variable Y.
	 * 
	 * Since X, and Y are commonly used in math expressions, CMathParser defines them by default.
	 * If you don't like X and Y, you can override CreateDefaultVars, or you can 
	 * call DeleteAllVars() function. 
	 */
	inline _ValueT GetY() {
		return GetVariable(_T("Y"));
	}
	/**
	 * Set value of variable Y.
	 * 
	 * Since X, and Y are commonly used in math expressions, CMathParser defines them by default.
	 * If you don't like X and Y, you can override CreateDefaultVars, or you can 
	 * call DeleteAllVars() function. 
	 */
	inline void SetY(_ValueT newVal) {
		SetVariable(_T("Y"), newVal);
	}
	/**
	 * Return value of variable X.
	 * 
	 * Since X, and Y are commonly used in math expressions, CMathParser defines them by default.
	 * If you don't like X and Y, you can override CreateDefaultVars, or you can 
	 * call DeleteAllVars() function. 
	 */
	inline _ValueT GetX() {
		return GetVariable(_T("X"));
	}
	/**
	 * Set value of variable X.
	 * 
	 * Since X, and Y are commonly used in math expressions, CMathParser defines them by default.
	 * If you don't like X and Y, you can override CreateDefaultVars, or you can 
	 * call DeleteAllVars() function. 
	 */
	inline void SetX(_ValueT newVal) {
		SetVariable(_T("X"), newVal);
	}

	/**
	 * Parse the expression, evaluate it and return the result.
	 */
	inline _ValueT GetValue() {
		return Evaluate();
	}

	/**
	 * Set the expression to parse.
	 * The expression may contain :
	 * 1. variables such as X, Y, Z, TEMP, STRESS, STRAIN etc.
	 * 2. functions such as SIN(X), MIN(A,B), MYFUNC(D)
	 * 3. constants such as 2, 3, 50
	 * 4. scientific notation like: 3E+10
	 * 5. aithmetic operators: +,-,*,/,%(modulus),^(power)
	 * 6. logical operators  : =,<,>,<>,>=,<=,!(not),&(and),|(or)
	 * 
	 * Example expressions are:
	 * 
	 * "X+Y/2"
	 * "SIN(X)+AVG(A,B,C)"
	 * "SUM(X,Y,Z,K,L)/5"
	 */
	inline void SetExpression(string_t expr, bool radian=TRUE) {
		m_Expression = expr;
		m_Dirty = TRUE;
        G_Radian = radian;
	}
	
	/**
	 * Return the current expression string.
	 */
	inline string_t GetExpression() {
		return m_Expression;
	}

	
	/**
	 *  VariableCallback is a function that is implemented by the user to provide values for undefined variables.
	 * 	If VariableCallback is set for the CMathParser instance, then the parser will
	 *  tolerate undefined variables during parsing and it will invoke the user defined
	 *  VariableCallback function to retrieve the variables values during evaluation.
	 *  If VariableCallback is NULL, then the parser will require that all variables used in an expression
	 *  are predefined before the parse operation.
	 *  VariableCallback is useful in situations where the application domain is so large that
	 *  defining every possible variable ahead of time is not possible. 
	 *  VariableCallback implementation should decide whether a variable name is valid and what it's
	 *  value should be. If the variable name is not valid, then the VariableCallback should throw
	 *  an exception and stop the expression evaluation.   
	 *  VariableCallback typedef for the function signature is as follows:
	 *  typedef _ValueT VariableCallback(CMathParser<_CharT, _ValueT> *pParentParser, const string_t varName);
	 *  The user defined function takes two parameters:
	 *  1. A pointer to the parser instance making this call.
	 *  2. The variable name as a string.
	 *  Return value shall be the desired value for this variable name.
	 *  If the variable is not valid, then an exception should be thrown.
	 *  CMathParser::ParserException is a good canditate to throw in such case.
	 */
	inline void SetVariableCallback(PVariableCallback callbackFunction){
		m_VariableCallback = callbackFunction;
		if(callbackFunction==NULL){
			m_Dirty = TRUE;
		}
	}

	/**
	 *  See SetVariableCallback.
	 */
	inline PVariableCallback GetVariableCallback(){
		return m_VariableCallback;
	}
	
	/*
	inline BOOL GetStrictFloatingPoint() {
		return m_CatchFpErrors;
	}
	inline void SetStrictFloatingPoint(BOOL newVal) {
		m_CatchFpErrors = newVal;
	}*/

	/**
	 * Returns the list of currently defined functions as a vector of strings.
	 */
	vector<string_t> GetDefinedFunctionNames() {
		typename TFunctionMap::iterator iter = m_Functions.begin();
		typename TFunctionMap::iterator end = m_Functions.end();
		vector<basic_string<_CharT> > names;
		while (iter != end) {
			names.push((*iter++).first);
		}
		return names;
	}
	/**
     * Returns the list of currently defined functions (and their respective param counts) as a map of strings and ints.
     * by Blake Madden.
     */
    std::map<string_t, int> GetDefinedFunctionInfo() {
        typename TFunctionMap::iterator iter = m_Functions.begin();
        typename TFunctionMap::iterator end = m_Functions.end();
        std::map<string_t, int> names;
        while (iter != end) {
            names.insert(std::make_pair<string_t, int>((*iter).first, (*iter).second->pCount));
            *iter++;
        }
        return names;
    }	
	/**
	 * Returns the list of currently defined variables as a vector of strings.
	 */
	vector<string_t> GetDefinedVariableNames() {
		typename TFunctionMap::iterator iter = m_Variables.begin();
		typename TFunctionMap::iterator end = m_Variables.end();
		vector<basic_string<_CharT> > names;
		while (iter != end) {
			names.push((*iter++).first);
		}
		return names;
	}

protected:
	/**
	 * In a given expression, find the last operation that needs to execute.
	 * Return -1 if not found. 
	 * For example: 
	 * "SIN(X)" has no last operation. -1 will be returned.
	 * "SIN(X)+COS(Y)" has '+' as the last operation.
	 * This operation node, if it existing will be the root node for the expression tree that 
	 * represents this formula.
	 */
	int FindLastOper(const string_t &formula) {
		//returns -1 if it cannot find anything
		//int Precedence = 7; //There are six operands and 7 is higher then all
		int Precedence = 13; //There are 12 operands and 13 is higher then all
		int BracketLevel = 0; //shows the level of brackets we moved through
		int Result = -1;
		unsigned int Len = (unsigned int)formula.length();
		int lastWasOperator = 0;

		for (unsigned int i = 0; i<Len; i++) //from left to right scan...
		{
			if (lastWasOperator>2) {
				return -1;
			}
			switch (formula[i]) {
			case ' ': //space
				break;
			case ')':
				--BracketLevel; //counting bracket levels
				lastWasOperator = 0;
				break;
			case '(':
				++BracketLevel;
				lastWasOperator = 0;
				break;

				//Logical operators:
			case '|':
				if (! (BracketLevel > 0 || lastWasOperator>0))
					if (Precedence >= 1) {
						Precedence = 1;
						Result = i;
					}
				++lastWasOperator;
				break;

			case '&':
				if (! (BracketLevel > 0 || lastWasOperator>0))
					if (Precedence >= 2) {
						Precedence = 2;
						Result = i;
					}
				++lastWasOperator;
				break;

			case '!':
				if (! (BracketLevel > 0 || lastWasOperator>0))
					if (Precedence >= 3) {
						Precedence = 3;
						Result = i;
					}
				++lastWasOperator;
				break;

			case '=':
				if (! (BracketLevel > 0 || lastWasOperator>0))
					if (Precedence >= 4) {
						Precedence = 4;
						Result = i;
					}
				//support for >= etc.
				if (lastWasOperator>0) {
					int prevOperIndex = i-lastWasOperator;
					if (formula[prevOperIndex]=='<' || formula[prevOperIndex]
							=='>') {
						break; //skip incrementing lastWasOperator variable.
					}
				}

				++lastWasOperator;
				break;

			case '>':
				if (! (BracketLevel > 0 || lastWasOperator>0))
					if (Precedence >= 5) {
						Precedence = 5;
						Result = i;
					}

				//support for <> etc.
				if (lastWasOperator>0) {
					if (formula[i-lastWasOperator]=='<') {
						break;
					}
				}

				++lastWasOperator;
				break;

			case '<':
				if (! (BracketLevel > 0 || lastWasOperator>0))
					if (Precedence >= 5) {
						Precedence = 5;
						Result = i;
					}
				++lastWasOperator;
				break;

			case '-':
				if (! (BracketLevel > 0 || lastWasOperator > 0)) //a main operation has to be outside the brackets
					if (Precedence >= 7) //seeking for lowest precedence
					{
						Precedence = 7;
						Result = i; //record the current index.
					}
				++lastWasOperator;
				break;
			case '+':
				if (! (BracketLevel > 0 || lastWasOperator > 0))
					if (Precedence >= 7) {
						Precedence = 7;
						Result = i;
					}
				++lastWasOperator;
				break;
			case '%':
				if (! (BracketLevel > 0 || lastWasOperator > 0))
					if (Precedence >= 9) {
						Precedence = 9;
						Result = i;
					}
				++lastWasOperator;
				break;
			case '/':
				if (! (BracketLevel > 0 || lastWasOperator > 0))
					if (Precedence >= 9) {
						Precedence = 9;
						Result = i;
					}
				++lastWasOperator;
				break;
			case '*':
				if (! (BracketLevel > 0 || lastWasOperator > 0))
					if (Precedence >= 9) {
						Precedence = 9;
						Result = i;
					}
				++lastWasOperator;
				break;
			case '^':
				if (! (BracketLevel > 0 || lastWasOperator > 0))
					if (Precedence >= 12) {
						Precedence = 12;
						Result = i;
					}
				++lastWasOperator;
				break;
			case 'E':
				if (i > 0 && lastWasOperator==0) {
					unsigned int ch = formula[i-1];
					if (ch >= '0' && ch <= '9') {//this E may be part of a number in scientific notation.
						int j=i;
						while (j > 0) { //trace back.
							--j;
							ch = formula[j];
							if (ch=='.' || (ch >= '0' && ch <= '9')) { //if it is not a function or variable name.
								continue;
							}
							if (ch=='_' || (ch>='A' && ch<='Z')) {//is it a func or var name?
								lastWasOperator = 0;
								break; //break the while loop.
							}
							++lastWasOperator; //it must be an operator or a paranthesis.
							break; //break the while loop.
						}
						if (j==0 && (ch >= '0' && ch <= '9')) {
							++lastWasOperator;
						}
					}else{
						lastWasOperator = 0;
					}
				} else {
					lastWasOperator = 0;
				}
				break;

			default:
				lastWasOperator = 0;
			}
		}
		return Result;
	}

	/**
	 * Determine if a given expression is a call to a function that takes two parameters.
	 * If so, tree structures representing left and right nodes will be returned as OUT parameters, too.
	 */
	BOOL IsTwoParamFunc(const string_t &formula, string_t &paramLeft,
			string_t &paramRight, PParserFunction *funcAddr, int CurrChar //gives the last operation index in the string
	) {
		_CharT *temp = m_temp;

		int Len= (int)formula.length();

		if (CurrChar>0) //if function in question is an operand
		{
			if (CurrChar>Len-2) {
				return FALSE;
			}
			int currCh = formula[CurrChar];

			//was it an operand also? we want to find <>, >=, <=
			if (currCh=='<') {
				int nextCh = formula[CurrChar+1]; //look ahead.
				if (nextCh=='>') {
					*funcAddr = (PParserFunction)_notEquals;
					paramLeft = formula.substr(0, CurrChar);
					paramRight= formula.substr(CurrChar+2, Len-CurrChar-2);
				} else if (nextCh=='=') {
					*funcAddr = (PParserFunction)_ltEquals;
					paramLeft = formula.substr(0, CurrChar);
					paramRight= formula.substr(CurrChar+2, Len-CurrChar-2);
				} else {
					*funcAddr = (PParserFunction)_less; //default case.
					paramLeft = formula.substr(0, CurrChar);
					paramRight= formula.substr(CurrChar+1, Len-CurrChar-1);
				}

				if (! (paramLeft.length()>0)) {
					return FALSE;
				}
				if (! (paramRight.length()>0)) {
					return FALSE;
				}
				return TRUE; //all output is assigned, now we return TRUE.
			} else if (currCh=='>') {
				wchar_t nextCh = formula[CurrChar+1];
				if (nextCh=='=') {
					*funcAddr = (PParserFunction)_gtEquals;
					paramLeft = formula.substr(0, CurrChar);
					paramRight= formula.substr(CurrChar+2, Len-CurrChar-2);
				} else {
					*funcAddr = (PParserFunction)_greater; //default case.
					paramLeft = formula.substr(0, CurrChar);
					paramRight= formula.substr(CurrChar+1, Len-CurrChar-1);
				}
				if (! (paramLeft.length()>0)) {
					return FALSE;
				}
				if (! (paramRight.length()>0)) {
					return FALSE;
				}
				return TRUE; //all output is assigned, now we return TRUE.
			} else {
				paramLeft = formula.substr(0, CurrChar);
				if (! (paramLeft.length()>0)) {
					return FALSE;
				}

				paramRight= formula.substr(CurrChar+1, Len-CurrChar-1);
				if (! (paramRight.length()>0)) {
					return FALSE;
				}

				switch (formula[CurrChar]) {
				case (_CharT)'+':
					*funcAddr = (PParserFunction)_add;
					break;
				case (_CharT)'-':
					*funcAddr = (PParserFunction)_subtract;
					break;
				case (_CharT)'*':
					*funcAddr = (PParserFunction)_multiply;
					break;
				case (_CharT)'/':
					*funcAddr = (PParserFunction)_divide;
					break;
				case (_CharT)'^':
					*funcAddr = (PParserFunction)_power;
					break;
				case (_CharT)'%':
					//*funcAddr = (PParserFunction)_intdiv;
					*funcAddr = (PParserFunction)_modulo;
					break;

					//logical operators:
				case (_CharT)'<':
					*funcAddr = (PParserFunction)_less;
					break;
				case (_CharT)'>':
					*funcAddr = (PParserFunction)_greater;
					break;
				case (_CharT)'=':
					*funcAddr = (PParserFunction)_equal;
					break;
				case (_CharT)'&':
					*funcAddr = (PParserFunction)_and;
					break;
				case (_CharT)'|':
					*funcAddr = (PParserFunction)_or;
					break;
				}
				return TRUE; //all output is assigned, now we return TRUE.
			}

		}
		//if we reach here, result is FALSE
		//if main operation is not an operand but a function
		int BracketLevel, paramStart;
		int i;
		if (formula[Len-1] == ')') //last character must be brackets closing function param list
		{
			i= 0;
			while (isValidChar(i, formula[i])) {
				if ( !(i<MAX_NAME_LEN+1)) {
					string_t err= _T("Function name in ");
					err+= formula;
					err+= _T(" is too long. Maximum possible name length is ");
					err+= MAX_NAME_LEN_STR;
					err+= _T(".");
					throw ParserException(err, formula);
				}
				temp[i]= formula[i];
				++i;
			}
			temp[i] = 0;
			while (formula[i] == ' ') { //skip spaces.
				++i;
			}
			if ((formula[i] == '(') && (i < Len-1)) {
				typename TFunctionMap::iterator iter = m_Functions.find(temp);
				if (iter != m_Functions.end()) {
					FunctionEntry<PParserFunction> *funcEntry = (*iter).second;
					if (funcEntry->pCount==2) { //allows exactly 2 params.
						*funcAddr = funcEntry->fPtr;
						paramStart= i+1;
						BracketLevel= 1;
						while (! (i>Len-1-1)) //last character is a ')', that's why we use i>Len-1
						{
							++i;
							switch (formula[i]) {
							case '(':
								++BracketLevel;
								break;
							case ')':
								--BracketLevel;
								break;
							case ',':
								if ( (1 == BracketLevel) && (i<Len-2)) //last character is a ')', that's why we use i<Len-2
								{
									paramLeft= formula.substr(paramStart, i
											-paramStart);
									paramRight= formula.substr(i+1, Len-1-1-i); //last character is a ')', that's why we use Len-1-i
									return TRUE; //we are sure that it is a two parameter function
								}
								break;
							}
						}
					}
				}
			}
		}
		return FALSE; //means we could not find it
	}

	/**
	 * Determine if a given expression is a call to a function that takes one parameters.
	 * If so, tree structures representing child node will be returned as OUT parameter, too.
	 */
	BOOL IsOneParamFunc(const string_t &formula, string_t &param,
			PParserFunction *funcAddr, int CurrChar) {
		_CharT *temp = m_temp;

		int paramStart;
		int Len= (int)formula.length();

		if (CurrChar == 0) //if function in question is an unary operand
		{
			param= formula.substr(1, Len-1);
			if (! (param.length()>0)) {
				return FALSE;
			}

			switch (formula[CurrChar]) {
			case (_CharT)'+':
				*funcAddr = (PParserFunction)_unaryadd;
				break;
			case (_CharT)'-':
				*funcAddr = (PParserFunction)_negate;
				break;
			case (_CharT)'!':
				*funcAddr = (PParserFunction)_not;
				break;
			default:
				return FALSE; //only + and - can be unary operators
			}
			return TRUE; //all output is assigned, now we exit.
		}
		//if we reach here, result is FALSE
		//if main operation is not an operand but a function
		if (formula[Len-1] == ')') //last character must be brackets closing function param list
		{
			int i= 0;
			while (isValidChar(i, formula[i])) {
				if ( !(i<MAX_NAME_LEN+1)) {
					string_t err= _T("Function name in ");
					err+= formula;
					err+= _T(" is too long. Maximum possible name length is ");
					err+= MAX_NAME_LEN_STR;
					err+= _T(".");
					throw ParserException(err, formula);
				}
				temp[i]= formula[i];
				++i;
			}
			temp[i] = 0;
			while (formula[i] == ' ') { //skip spaces.
				++i;
			}
			if ((formula[i] == '(') && (i < Len-2)) {
				typename TFunctionMap::iterator iter = m_Functions.find(temp);
				if (iter != m_Functions.end()) {
					FunctionEntry<PParserFunction> *funcEntry = (*iter).second;
					if (funcEntry->pCount==1) { //allows exactly 1 param.
						paramStart= i+1;
						*funcAddr = funcEntry->fPtr;
						param= formula.substr(paramStart, Len-paramStart-1); //check example: SIN(30)
						return TRUE; //we are sure that it is a two parameter function
					}
				}
			}
		}
		return FALSE;
	}
	/**
	 * Is this expression a function that takes N parameters.
	 */
	BOOL IsNParamFunc(const string_t &formula, vector<string_t> &params,
			PParserFunction *funcAddr) {
		_CharT *temp = m_temp;
		int Len= (int)formula.length();

		int BracketLevel, paramStart;
		int i;
		if (formula[Len-1] == ')') //last character must be brackets closing function param list
		{
			i= 0;
			while (isValidChar(i, formula[i])) {
				if ( !(i<MAX_NAME_LEN+1)) {
					string_t err= _T("Function name in ");
					err+= formula;
					err+= _T(" is too long. Maximum possible name length is ");
					err+= MAX_NAME_LEN_STR;
					err+= _T(".");
					throw ParserException(err, formula);
				}
				temp[i]= formula[i];
				++i;
			}
			temp[i] = 0; //add null terminator.
			while (formula[i]==' ') {
				++i;
			}
			if ((formula[i] == '(') && (i < Len-1)) {
				typename TFunctionMap::iterator iter = m_Functions.find(temp);
				if (iter != m_Functions.end()) {
					FunctionEntry<PParserFunction> *funcEntry = (*iter).second;
					*funcAddr = funcEntry->fPtr;
					paramStart= i+1;
					BracketLevel= 1;
					//int paramIndex = 0;
					while (! (i>Len-1-1)) //last character is a ')', that's why we use i>Len-1
					{
						++i;
						switch (formula[i]) {
						case '(':
							++BracketLevel;
							break;
						case ')':
							--BracketLevel;
							break;
						case ',':
							if ( (1 == BracketLevel) && (i<Len-2)) //last character is a ')', that's why we use i>Len-2
							{
								params.push_back(formula.substr(paramStart, i
										-paramStart));
								paramStart = i+1;
							}
							break;
						}
					}
					params.push_back(formula.substr(paramStart, Len-1
							-paramStart));
					//check to make sure we have correct number of parameters:
					if (funcEntry->pCount!=-1 && funcEntry->pCount
							!=params.size()) {
						string_t err= _T("Function ");
						err+= temp;
						err+= _T(" does not take ");
						err+= ToString((int)params.size());
						err+= _T(" parameters. ");
						err+= temp;
						err+= _T(" takes ");
						err+= ToString(funcEntry->pCount);
						err+= _T(" parameters.");
						throw ParserException(err, formula);
					}
					return TRUE;
				}
			}
		}
		return FALSE; //means we could not find it
	}

	/**
	 * Convert a string expression into a tree structure of CNode elements.
	 */
	void CreateParseTree(const string_t expressionToParse,
			CNode<_ValueT> * &Node) throw(ParserException) {
		DEBUGOUT(expressionToParse);

		string_t formula = Trim(expressionToParse);

		if (formula.length()==0) {
			string_t err= _T("Syntax error in expression ");
			err+= m_Expression;
			throw ParserException(err, expressionToParse);
		}

		bool wasChanged = RemoveOuterBrackets(formula); //remove unnecessary brackets
		//we should first remove brackets, and then check the formula length that might be modified
		//while removing brackets.

		if (wasChanged) {
			formula = Trim(formula);
			if (formula.length()==0) {
				string_t err= _T("Syntax error in expression ");
				err+= m_Expression;
				throw ParserException(err,expressionToParse);
			}
		}

		_ValueT num;

		if (IsValidNumber(formula, num) ) { //attach a number node in the structure
			Node = new CBasicNode<_ValueT>(num); //we create a number node and attach it to the *Node reference.
			return; // S_OK;
		}

		//if it is not a simple number
		if ((m_Variables.find(formula/*, varIndex*/)) != m_Variables.end()) {
			Node= new CVarNode<_ValueT>(m_Variables[formula]); //recursion will end on these points when we get to the basics
			return; // S_OK;
		}else if ((m_VariableCallback!=NULL) && isValidName(formula)){
			Node = new CUnknownVarNode<_CharT, _ValueT>(this, formula); 
			return;
		}

		//if it is not a variable
		CNode<_ValueT> *leftNode;
		string_t paramLeft;
		int LastOper= FindLastOper(formula);

		PParserFunction funcAddr= NULL;
		if (! (LastOper>0)) //if it is 0 then it is a unary operation which is a one param function
		{
			if (IsOneParamFunc(formula, paramLeft, &funcAddr, LastOper) ) {
				DEBUGOUT2("param: ", paramLeft);

				CreateParseTree(paramLeft, leftNode);
				Node= new COneParamNode<_CharT,_ValueT>(this, leftNode, funcAddr);
				return; //S_OK;
				//if it is a one param function then we exit, otherwise below code will execute
			}
		}

		CNode<_ValueT> *rightNode;
		string_t paramRight;

		if (IsTwoParamFunc(formula, paramLeft, paramRight, &funcAddr, LastOper) ) {
			DEBUGOUT2("left: ", paramLeft);
			DEBUGOUT2("right: ", paramRight);
			CreateParseTree(paramLeft, leftNode);

			CreateParseTree(paramRight, rightNode);

			Node= new CTwoParamNode<_CharT, _ValueT>(this, leftNode, rightNode, funcAddr);
			return; // S_OK;
		}

		vector<string_t> paramList;

		//if it is none of the above:
		if (IsNParamFunc(formula, paramList, &funcAddr) ) {
			//auto_ptr would not work as it does not use delete[], but uses delete.
			CNode<_ValueT> **nodes = new CNode<_ValueT>*[paramList.size()];
			memset(nodes, NULL, sizeof(CNode<_ValueT>*)*paramList.size());
			try {
				for(int i=0, n=(int)paramList.size(); i<n; i++) {
					CreateParseTree(paramList[i], nodes[i]);
				}
			} catch(ParserException &ex) {
				for(int i=0, n=paramList.size(); i<n; i++) {
					if(nodes[i]!=NULL){
						delete nodes[i];
						nodes[i]=NULL;
					}
				}
				delete[] nodes; //deallocate temp array.
				throw ex;
			} catch(...) {
				delete[] nodes; //deallocate temp array.
				string_t err = _T("Syntax error in <");
				err+= expressionToParse;
				err+= _T("> in expression <");
				err+= m_Expression;
				err+= _T(">");
				throw ParserException(err,expressionToParse);
			}
			//if there is a function address returned then we use it, otherwise we use function name
			Node= new CNParamNode<_CharT, _ValueT>(this, nodes, (int)paramList.size(), funcAddr);
			return; // S_OK;
		}

		string_t err= _T("Syntax error in <");
		err+= expressionToParse;
		err+= _T("> in expression <");
		err+= m_Expression;
		err+= _T(">");
		throw ParserException(err, expressionToParse);
		//when code reaches here it means we did not return TRUE so after compiling the expression.
	}

	/**
	 * Optimize the expression.
	 */
	inline void Optimize(void) {
		OptimizeNode(m_Node);
	}

	/**
	 * Is the given function defined? 
	 */
	inline BOOL IsFuncRegistered(const string_t name) {
		return m_Functions.find(name) != m_Functions.end();
	}
};

#endif //__MATH_PARSER_H_
