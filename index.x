# pwg - a password generator
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
	@put(default state);
	@put(process args);
@end(main)
```
* The `@f(main)` function initializes the state object and processes
  command line arguments
* The global state will keep track of how many characters of each group
  the algorithm generates

```
@def(includes)
	#include <string>
	#include <iostream>
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
@def(globals)
	struct Counts {
		int upper = 3;
		@put(other counts);
	};
@end(globals)
```

```
@def(default state)
	Counts counts {};
@end(default state)
```

```
@add(default state)
	std::string upper {
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	};
@end(default state)
```

```
@add(globals)
	template<typename RE>
	std::string random_select(
		const std::string &source,
		int count,
		RE &re
	) {
		std::string result;
		@put(random select);
		return result;
	}
@end(globals)
```

```
@add(includes)
	#include <cassert>
	#include <random>
@end(includes)
```

```
@def(unit-tests)
	using test_engine =
		std::linear_congruential_engine<
			unsigned, 1, 0, 0x7ff
		>;
@end(unit-tests)
```

```
@add(unit-tests) {
	test_engine te(0);
	assert(
		random_select("abc", 4, te) ==
			"aaaa"
	);
} @end(unit-tests)
```

```
@add(default state)
	int seed = (std::random_device {})();
@end(default state)
```

```
@def(generate pw)
	std::mt19937 re { seed };
	pw += random_select(
		upper, counts.upper, re
	);
@end(generate pw)
```

```
@def(random select)
	int max = source.size() - 1;
	std::uniform_int_distribution<int>
		d { 0, max };
	for (int i = 0; i < count; ++i) {
		result += source[d(re)];
	}
@end(random select)
```

```
@def(other counts)
	int lower = 3;
	int digit = 2;
	int special = 2;
@end(other counts)
```

```
@add(default state)
	std::string lower {
		"abcdefghijklmnopqrstuvwxyz"
	};
	std::string digit {
		"0123456789"
	};
	std::string special {
		".,:;!?+-*/[](){}"
	};
@end(default state)
```

```
@add(generate pw)
	pw += random_select(
		lower, counts.upper, re
	);
	pw += random_select(
		digit, counts.digit, re
	);
	pw += random_select(
		special, counts.special, re
	);
@end(generate pw)
```

```
@add(globals)
	template<typename RE>
	std::string random_permute(
		std::string str,
		RE &re
	) {
		@put(random permute);
		return str;
	}
@end(globals)
```

```
@add(unit-tests) {
	test_engine te(0);
	assert(
		random_permute("abc", te) == "bca"
	);
} @end(unit-tests)
```

```
@add(generate pw)
	pw = random_permute(pw, re);
@end(generate pw)
```

```
@def(random permute)
	for (
		int i = str.size() - 1; i > 0; --i
	) {
		std::uniform_int_distribution<int>
			d { 0, i };
		std::swap(str[i], str[d(re)]);
	}
@end(random permute)
```

```
@def(process args)
	if (argc > 1) {
		counts.upper = std::stoi(argv[1]);
	}
	if (argc > 2) {
		counts.lower = std::stoi(argv[2]);
	}
	if (argc > 3) {
		counts.digit = std::stoi(argv[3]);
	}
@end(process args)
```

```
@add(process args)
	if (argc > 4) {
		counts.special = std::stoi(argv[4]);
	}
	if (argc > 5) {
		special = argv[5];
	}
	if (argc > 6) {
		seed = std::stoi(argv[6]);
	}
@end(process args)
```

