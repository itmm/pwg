
	
	#include <string>

	#include <iostream>

	#include <cassert>
	#include <random>

	
	struct Counts {
		int upper = 3;
		
	int lower = 3;
	int digit = 2;
	int special = 2;
;
	};

	template<typename RE>
	std::string random_select(
		const std::string &source,
		int count,
		RE &re
	) {
		std::string result;
		
	int max = source.size() - 1;
	std::uniform_int_distribution<int>
		d { 0, max };
	for (int i = 0; i < count; ++i) {
		result += source[d(re)];
	}
;
		return result;
	}

	template<typename RE>
	std::string random_permute(
		std::string str,
		RE &re
	) {
		
	for (
		int i = str.size() - 1; i > 0; --i
	) {
		std::uniform_int_distribution<int>
			d { 0, i };
		std::swap(str[i], str[d(re)]);
	}
;
		return str;
	}

	int main(int argc, char *argv[]) {
		
	{ 
	using test_engine =
		std::linear_congruential_engine<
			unsigned, 1, 0, 0x7ff
		>;
 {
	test_engine te(0);
	assert(
		random_select("abc", 4, te) ==
			"aaaa"
	);
}  {
	test_engine te(0);
	assert(
		random_permute("abc", te) == "bca"
	);
} ; }
	
	Counts counts {};

	std::string upper {
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	};

	int seed = (std::random_device {})();

	std::string lower {
		"abcdefghijklmnopqrstuvwxyz"
	};
	std::string digit {
		"0123456789"
	};
	std::string special {
		".,:;!?+-*/[](){}"
	};
;
	
	if (argc > 1) {
		counts.upper = std::stoi(argv[1]);
	}
	if (argc > 2) {
		counts.lower = std::stoi(argv[2]);
	}
	if (argc > 3) {
		counts.digit = std::stoi(argv[3]);
	}

	if (argc > 4) {
		counts.special = std::stoi(argv[4]);
	}
	if (argc > 5) {
		special = argv[5];
	}
	if (argc > 6) {
		seed = std::stoi(argv[6]);
	}
;
	std::string pw;
	
	std::mt19937 re { seed };
	pw += random_select(
		upper, counts.upper, re
	);

	pw += random_select(
		lower, counts.upper, re
	);
	pw += random_select(
		digit, counts.digit, re
	);
	pw += random_select(
		special, counts.special, re
	);

	pw = random_permute(pw, re);
;
	
	std::cout << pw << '\n';
;

	}
