#line 10 "README.md"
// includes
#line 221
	#include <algorithm>
#line 127
	#include <exception>
#line 83
	#include <random>
#line 49
	#include <string>
	#include <iostream>
#line 11
// globals
#line 276
	int to_int(const std::string &s, int d) {
		try {
			d = std::stoi(s);
		}
		catch (...) {
			// to int err msg
#line 293
			std::cerr << "Can't convert `" <<
				s << "` to integer; " <<
				"will use " << d <<
				" instead.\n";
#line 282
		}
		return d;
	}
#line 91
	using Uniform = std::uniform_int_distribution<int>;
#line 12

#line 93
	template<typename RE> std::string random_select(
		const std::string &source,
		int count, RE &re
	) {
		std::string result;
		// random select
#line 149
		int max = source.size() - 1;
		if (max < 0) {
			throw std::invalid_argument("no chars");
		}
		Uniform d { 0, max };
		for (int i = 0; i < count; ++i) {
			result += source[d(re)];
		}
#line 99
		return result;
	}
#line 13
int main(int argc, char *argv[]) {
	{
		// unit-tests
#line 115
		using TestEngine = std::linear_congruential_engine<
			unsigned, 1, 0, 0x7ff
		>;
		// unit-tests 2
#line 135
		{
			TestEngine te { 0 };
			if (random_select("abc", 4, te) != "aaaa") {
				throw std::logic_error("random select");
			}
		}
#line 16
	}
	// main
#line 34
	// state
#line 256
	int special_count = 2;
	std::string special_set { ".,:;!?+-*/[](){}" };
#line 238
	int digit_count = 2;
	std::string digit_set { "23456789" };
#line 196
	int lower_count = 3;
	std::string lower_set { "abcdefghijkmnopqrstuvwxyz" };
#line 166
	auto seed { (std::random_device {})() };
#line 71
	int upper_count = 3;
	std::string upper_set { "ABCDEFGHJKLMNPQRSTUVWXYZ" };
#line 35
	// process args
#line 376
	if (argc > 6) {
		seed = to_int(argv[6], seed);
	}
#line 357
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
#line 344
	if (argc > 4) {
		special_count = to_int(
			argv[4], special_count
		);
	}
#line 331
	if (argc > 3) {
		digit_count = to_int(
			argv[3], digit_count
		);
	}
#line 318
	if (argc > 2) {
		lower_count = to_int(
			argv[2], lower_count
		);
	}
#line 305
	if (argc > 1) {
		upper_count = to_int(
			argv[1], upper_count
		);
	}
#line 36
	// generate
#line 60
	std::string pw;
	// generate pw
#line 178
	std::mt19937 re { seed };
	// generate pw 2
#line 187
	pw += random_select(upper_set, upper_count, re);
	// generate pw 3
#line 265
	pw += random_select(
		special_set, special_count, re
	);
#line 247
	pw += random_select(digit_set, digit_count, re);
#line 206
	pw += random_select(
		lower_set, lower_count, re
	);
	// generate pw 4
#line 229
	std::shuffle(pw.begin(), pw.end(), re);
#line 62
	std::cout << pw << '\n';
#line 18
}
