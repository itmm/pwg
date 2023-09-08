# pwg – a password generator

* Generates random passwords
* Number of upper case, lower case, digits, and special chars can be
  passed as arguments
* The repository for this project is at `https://github.com/itmm/pwg`
* Sources are extracted into `pwg.cpp`

```c++
// includes
// globals

int main(int argc, char *argv[]) {
	{
		// unit-tests
	}
	// main
}
```
* First the included files are specified
* so the rest of the program can use them
* Then global elements are defined
* so the main function can use them
* At last the main function is defined
* This is the central entry point of the program
* Before running the main algorithm the `main` function runs all
  unit-tests
* It is scoped into a local block so all elements that are needed in a
  unit-test are destroyed before the main algorithm starts

```c++
// ...
	// main
	// state
	// process args
	// generate
// ...
```
* The `main` function initializes the state object and processes
  command line arguments
* The state will keep track of how many characters of each group that
  the algorithm generates
* The state can be changed with command line arguments that the
  `main` function processes next

```c++
// ...
// includes
	#include <string>
	#include <iostream>
// ...
```
* The algorithm needs the `<string>` header for the `std::string`
  class
* and `<iostream>` to write them

```c++
// ...
	// generate
	std::string pw;
	// generate pw
	std::cout << pw << '\n';
// ...
```
* The algorithm stores the generated password in `pw`
* After the generation it writes the password to standard output

```c++
// ...
	// state
	int upper_count = 3;
	std::string upper_set { "ABCDEFGHJKLMNPQRSTUVWXYZ" };
// ...
```
* `pwg` generates a password from different character groups
* For each group there is one variable that holds the number of
  characters that are chosen from this group
* and a `std::string` with all characters in this group

```c++
// ...
// includes
	#include <random>
// ...
```
* The `<random>` header from C++ is used to generate random numbers

```c++
// ...
// globals
	using Uniform = std::uniform_int_distribution<int>;

	template<typename RE> std::string random_select(
		const std::string &source,
		int count, RE &re
	) {
		std::string result;
		// random select
		return result;
	}
// ...
```
* Define type for uniform distribution
* This shortens the code parts that use random distributions
* It must be declared before the functions are declared that use it
* The function `random_select` chooses a number of random characters
  from a given set
* It does not return a permutation so it can choose the same character
  multiple times in one go
* It is a template function to allow any random engine to be passed

```c++
// ...
		// unit-tests
		using TestEngine = std::linear_congruential_engine<
			unsigned, 1, 0, 0x7ff
		>;
		// unit-tests 2
// ...
```
* For unit-testing `pwg` uses a simple random engine that will always
  return `0`

```c++
// ...
// includes
	#include <exception>
// ...
```
* The unit-tests use the standard exceptions

```c++
// ...
		// unit-tests 2
		{
			TestEngine te { 0 };
			if (random_select("abc", 4, te) != "aaaa") {
				throw std::logic_error("random select");
			}
		}
// ...
```
* With this degenerated random engine `random_select` will always
  return the first character the expected number of times

```c++
// ...
		// random select
		int max = source.size() - 1;
		if (max < 0) {
			throw std::invalid_argument("no chars");
		}
		Uniform d { 0, max };
		for (int i = 0; i < count; ++i) {
			result += source[d(re)];
		}
// ...
```
* `random_select` expects that the character set is not empty
* It builds a uniform distribution so it chooses each character with the
  same probability

```c++
// ...
	// state
	auto seed { (std::random_device {})() };
// ...
```
* For the real random engine `pwg` generates a random seed
* The user can overwrite this `seed` with a command line argument to
  generate deterministic results
* Also the invocation of `std::random_device` can be time consuming to
  `pwg` uses a Mersenne Twister algorithm instead

```c++
// ...
	// generate pw
	std::mt19937 re { seed };
	// generate pw 2
// ...
```
* `pwg` initialises the Mersenne Twister with the seed value

```c++
// ...
	// generate pw 2
	pw += random_select(upper_set, upper_count, re);
	// generate pw 3
// ...
```
* `pwg` chooses the specified number of upper case letters

```c++
// ...
	// state
	int lower_count = 3;
	std::string lower_set { "abcdefghijkmnopqrstuvwxyz" };
// ...
```
* For the lower letters `pwg` also specifies a default count and
  character set

```c++
// ...
	// generate pw 3
	pw += random_select(
		lower_set, lower_count, re
	);
	// generate pw 4
// ...
```
* `pwg` chooses the specified number of upper case letters
* But the lower case letters are following the upper case letters
* `pwg` must shuffle the resulting string to generate a stronger
  password
* But other characters may be added before the shuffeling

```c++
// ...
// includes
	#include <algorithm>
// ...
```
* Defines shuffle function

```c++
// ...
	// generate pw 4
	std::shuffle(pw.begin(), pw.end(), re);
// ...
```
* The `main` function uses `random_shuffle` to perturbate the
  letters from the different categories

```c++
// ...
	// state
	int digit_count = 2;
	std::string digit_set { "23456789" };
// ...
```
* Digits are also supported as part of a password

```c++
// ...
	// generate pw 3
	pw += random_select(digit_set, digit_count, re);
// ...
```
* `pwg` chooses random digits and adds them to the password before
  performing the permutation

```c++
// ...
	// state
	int special_count = 2;
	std::string special_set { ".,:;!?+-*/[](){}" };
// ...
```
* Special characters are also supported as part of a password

```c++
// ...
	// generate pw 3
	pw += random_select(
		special_set, special_count, re
	);
// ...
```
* `pwg` chooses random special characters and adds them to the password
  before performing the permutation

```c++
// ...
// globals
	int to_int(const std::string &s, int d) {
		try {
			d = std::stoi(s);
		}
		catch (...) {
			// to int err msg
		}
		return d;
	}
// ...
```
* `to_int` can cope with cases that the provided string cannot be
  converted to an integer

```c++
// ...
			// to int err msg
			std::cerr << "Can't convert `" <<
				s << "` to integer; " <<
				"will use " << d <<
				" instead.\n";
// ...
```
* `to_int` prints this error message, if the string cannot be
  converted to an integer

```c++
// ...
	// process args
	if (argc > 1) {
		upper_count = to_int(
			argv[1], upper_count
		);
	}
// ...
```
* The first command line argument is the number of upper-case letters
  in the generated password

```c++
// ...
	// process args
	if (argc > 2) {
		lower_count = to_int(
			argv[2], lower_count
		);
	}
// ...
```
* The second command line argument is the number of lower-case letters
  in the generated password

```c++
// ...
	// process args
	if (argc > 3) {
		digit_count = to_int(
			argv[3], digit_count
		);
	}
// ...
```
* The third command line argument is the number of digits in the
  generated password

```c++
// ...
	// process args
	if (argc > 4) {
		special_count = to_int(
			argv[4], special_count
		);
	}
// ...
```
* The fourth command line argument is the number of special characters
  in the generated password

```c++
// ...
	// process args
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
// ...
```
* The fifth command line argument is the set of special characters used
  in the generated password

```c++
// ...
	// process args
	if (argc > 6) {
		seed = to_int(argv[6], seed);
	}
// ...
```
* The sixth command line argument is an integer that is used as a seed
  for the random number generator
* By using a seed `pwg` will show deterministic behaviour

