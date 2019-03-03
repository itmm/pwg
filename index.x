# pwg - a password generator
* Generates random passwords
* Number of upper case, lower case,
  digits, and special chars can be
  passed as arguments

```
@Def(file: pwg.cpp)
	@put(includes)
	@put(globals)
	int main(int argc, char *argv[]) {
		@put(main)
	}
@end(file: pwg.cpp)
```

```
@def(includes)
	#include <string>
@end(includes)
```

```
@def(main)
	{ @put(unit-tests); }
	@put(default state);
	@put(process args);
	std::string pw;
	@put(generate pw);
	@put(print pw);
@end(main)
```

```
@add(includes)
	#include <iostream>
@end(includes)
```

```
@def(print pw)
	std::cout << pw << '\n';
@end(print pw)
```

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

