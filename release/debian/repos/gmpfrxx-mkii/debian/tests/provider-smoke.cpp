#include <gmpxx_mkII.h>

#include <cmath>

int main()
{
    const auto one = gmpxx::mpf_class::with_precision(256, 1.0);
    const auto two = gmpxx::mpf_class::with_precision(256, 2.0);
    const gmpxx::mpf_class result = one + two;
    if (result.get_prec() != 256) {
        return 1;
    }
    return std::abs(result.to_double() - 3.0) < 1e-15 ? 0 : 1;
}
