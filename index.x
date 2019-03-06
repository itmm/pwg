# pwg – a password generator
* Generates random passwords
* Number of upper case, lower case,
  digits, and special chars can be
  passed as arguments

```
@Def(| c++ -x c++ -o pwg -)
	@put(parts)
@end(| c++ -x c++ -o pwg -)
```
* The generated code will be piped directly into the C++ compiler
* The `-x c++` informs the compiler that the input is C++
* The compiler will generate the object file `pwg`
* The program consits of different parts
* Invoking `hx` without arguments will build the executable and the
  HTML documentation

```
@def(parts)
	@put(includes)
@end(parts)
```
* First the included files are specified
* so the rest of the program can use hem

```
@add(parts)
	@put(globals)
@end(parts)
```
* Then global elements are defined
* so the main function can use them

```
@add(parts)
	int main(int argc, char *argv[]) {
		@put(main)
	}
@end(parts)
```
* At last the main function is defined
* This is the central entry point of the program

```
@def(main)
	{ @put(unit-tests); }
@end(main)
```
* Before runningt the main algorithm the `@f(main)` function runs all
  unit-tests
* It is scoped into a local block so all elements that are needed in a
  unit-test are destroyed before the main algorithm starts

```
@add(main)
	@put(state);
	@put(process args);
@end(main)
```
* The `@f(main)` function initializes the state object and processes
  command line arguments
* The state will keep track of how many characters of each group that
  the algorithm generates
* The state can be changed with command line arguments that the
  `@f(main)` function processes next

```
@def(includes)
	#include @s(<string>)
	#include @s(<iostream>)
@end(includes)
```
* The algorithm needs the `@s(<string>)` header for the `std::string`
  class
* and `@s(<iostream>)` to write them

```
@add(main)
	std::string pw;
	@put(generate pw);
	std::cout << pw << '\n';
@end(main)
```
* The algorithm stores the generated password in `pw`
* After the generation it writes the password to standard output

```
@def(state)
	int upper_count = 3;
	std::string upper_set {
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	};
@end(state)
```
* `pwg` generates a password from different character groups
* For each group there is one variable that holds the number of
  characters that are chosen from this group
* and a `std::string` with all characters in this group

```
@add(includes)
	#include @s(<random>)
@end(includes)
```
* The `@s(<random>)` header from C++ is used to generate random numbers

```
@def(globals)
	using Uniform =
		std::@t(uniform_int_distribution)<
			int
		>;
@end(globals)
```
* Define type for uniform distribution
* This shortens the code parts that use random distributions
* It must be declared before the functions are declared that use it

```
@add(globals)
	template<typename @t(RE)>
	std::string random_select(
		const std::string &source,
		int count, @t(RE) &re
	) {
		std::string result;
		@put(random select);
		return result;
	}
@end(globals)
```
* The function `@f(random_select)` chooses a number of random characters
  from a given set
* It does not return a permutation so it can choose the same character
  multiple times in one go
* It is a template function to allow any random engine to be passed

```
@def(unit-tests)
	using TestEngine =
		std::@t(linear_congruential_engine)<
			unsigned, 1, 0, 0x7ff
		>;
@end(unit-tests)
```
* For unit-testing `pwg` uses a simple random engine that will always
  return `0`

```
@add(includes)
	#include @s(<exception>)
@end(includes)
```
* The unit-tests use the standard exceptions

```
@add(unit-tests) {
	TestEngine te { 0 };
	if (
		random_select("abc", 4, te) !=
			"aaaa"
	) {
		throw std::logic_error(
			"random select"
		);
	}
} @end(unit-tests)
```
* With this degenerated random engine `@f(random_select)` will always
  return the first character the expected number of times

```
@def(random select)
	int max = source.size() - 1;
	if (max < 0) {
		throw std::invalid_argument(
			"no chars"
		);
	}
	Uniform d { 0, max };
	for (int i = 0; i < count; ++i) {
		result += source[d(re)];
	}
@end(random select)
```
* `@f(random_select)` expects that the character set is not empty
* It builds a uniform distribution so it choses each character with the
  same probability

```
@add(state)
	int seed = (std::@t(random_device) {})();
@end(state)
```
* For the real random engine `pwg` generates a random seed
* The user can overwrite this `seed` with a command line argument to
  generate deterministic results
* Also the invocation of `std::@t(random_device)` can be time consuming to
  `pwg` uses a Mersenne Twister algorithm instead

```
@def(generate pw)
	std::@t(mt19937) re { seed };
@end(generate pw)
```
* `pwg` initialises the Mersenne Twister with the seed value

```
@add(generate pw)
	pw += random_select(
		upper_set, upper_count, re
	);
@end(generate pw)
```
* `pwg` chooses the specified number of upper case letters

```
@add(state)
	int lower_count = 3;
	std::string lower_set {
		"abcdefghijklmnopqrstuvwxyz"
	};
@end(state)
```
* For the lower letters `pwg` also specifies a default count and
  character set

```
@add(generate pw)
	pw += random_select(
		lower_set, lower_count, re
	);
@end(generate pw)
```
* `pwg` chooses the specified number of upper case letters
* But the lower case letters are following the upper case letters

```
@add(generate pw)
	@put(add other chars);
	@put(shuffle pw);
@end(generate pw)
```
* `pwg` must shuffle the resulting string to generate a stronger
  password
* But other characters may be added before the shuffeling

```
@add(globals)
	template<typename @t(RE)>
	std::string random_permute(
		std::string str, @t(RE) &re
	) {
		@put(random permute);
		return str;
	}
@end(globals)
```
* The function `@f(random_permute)` randomly shuffles all the characters
  in a string
* and return the shuffeled result
* It receives a generic random engine to ease unit-tests

```
@def(shuffle pw)
	pw = random_permute(pw, re);
@end(shuffle pw)
```
* The `@f(main)` function uses `@f(random_permute)` to perturbate the
  letters from the different categories

```
@def(random permute)
	int i = str.size() - 1;
	for (; i > 0; --i) {
		Uniform d { 0, i };
		std::swap(str[i], str[d(re)]);
	}
@end(random permute)
```
* `@f(random_permute)` exchanges the last character in the string with
  a character at a random position in the string
* Then it exchanges the second to last character with a character at a
  random position up to and including this string
* This continues until there is only one character left

```
@add(unit-tests) {
	TestEngine te { 0 };
	if (
		random_permute("abc", te) != "bca"
	) {
		throw std::logic_error(
			"random permute"
		);
	}
} @end(unit-tests)
```
* In this unit-test always the first position is used for swaps
* So `@s(abc)` becomes `@s(cba)` in the first iteration of the loop
* Then `@s(cba)` becomes `@s(bca)` and that is the final result

```
@add(state)
	int digit_count = 2;
	std::string digit_set {
		"0123456789"
	};
@end(state)
```
* Digits are also supported as part of a password

```
@def(add other chars)
	pw += random_select(
		digit_set, digit_count, re
	);
@end(add other chars)
```
* `pwg` chooses random digits and adds them to the password before
  performing the permutation

```
@add(state)
	int special_count = 2;
	std::string special_set {
		".,:;!?+-*/[](){}"
	};
@end(state)
```
* Special characters are also supported as part of a password

```
@add(add other chars)
	pw += random_select(
		special_set, special_count, re
	);
@end(add other chars)
```
* `pwg` chooses random special characters and adds them to the password
  before performing the permutation

```
@add(globals)
	int to_int(
		const std::string &s, int d
	) {
		try {
			d = std::stoi(s);
		}
		catch (...) {
			@put(to int err msg);
		}
		return d;
	}
@end(globals)
```
* `@f(to_int)` can cope with cases that the provided string cannot be
  converted to an integer

```
@def(to int err msg)
	std::cerr << "Can't convert `" <<
		s << "` to integer; " <<
		"will use " << d <<
		" instead.\n";
@end(to int err msg)
```
* `@f(to_int)` prints this error message, if the string cannot be
  converted to an integer

```
@def(process args)
	if (argc > 1) {
		upper_count = to_int(
			argv[1], upper_count
		);
	}
@end(process args)
```
* The first command line argument is the number of upper-case letters
  in the generated password

```
@add(process args)
	if (argc > 2) {
		lower_count = to_int(
			argv[2], lower_count
		);
	}
@end(process args)
```
* The second command line argument is the number of lower-case letters
  in the generated password

```
@add(process args)
	if (argc > 3) {
		digit_count = to_int(
			argv[3], digit_count
		);
	}
@end(process args)
```
* The third command line argument is the number of digits in the
  generated password

```
@add(process args)
	if (argc > 4) {
		special_count = to_int(
			argv[4], special_count
		);
	}
@end(process args)
```
* The fourth command line argument is the number of special characters
  in the generated password

```
@add(process args)
	if (argc > 5) {
		std::string s { argv[5] };
		if (s.size()) {
			special_set = argv[5];
		} else {
			std::cerr << "Specials are "
				"empty; will use `" <<
				special_set <<
				"` instead.\n";
		}
	}
@end(process args)
```
* The fifth command line argument is the set of special characters used
  in the generated password

```
@add(process args)
	if (argc > 6) {
		seed = to_int(argv[6], seed);
	}
@end(process args)
```
* The sixth command line argument is an integer that is used as a seed
  for the random number generator
* By using a seed `pwg` will show deterministic behaviour

