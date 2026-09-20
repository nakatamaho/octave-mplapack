#include <stdexcept>

#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{

using Real = mpfrxx::mpfr_class;
using Complex = mpfrxx::mpc_class;

void require(bool condition, const char *message)
{
    if (!condition) {
        throw std::runtime_error(message);
    }
}

} // namespace

int main()
{
    try {
        constexpr mpfr_prec_t precision = 128;
        Real real_one = Real::with_precision(precision, 1.0);
        Real real_zero = Real::with_precision(precision, 0.0);
        Real real_out = Real::with_precision(precision, 0.0);

        {
            MplapackMpfrPrecisionScope scope(precision);
            Rgemm("N", "N", 1, 1, 1, real_one, &real_one, 1,
                  &real_one, 1, real_zero, &real_out, 1);
        }
        require(real_out.to_double() == 1.0, "Rgemm result mismatch");

        Complex complex_one =
            Complex::with_precision(precision, 1.0, 0.0);
        Complex complex_zero =
            Complex::with_precision(precision, 0.0, 0.0);
        Complex complex_out = complex_zero;
        {
            MplapackMpfrPrecisionScope scope(precision);
            Cgemm("N", "N", 1, 1, 1, complex_one, &complex_one, 1,
                  &complex_one, 1, complex_zero, &complex_out, 1);
        }
        require(mpfr_get_d(mpc_realref(complex_out.mpc_data()), MPFR_RNDN)
                    == 1.0,
                "Cgemm real result mismatch");
        require(mpfr_get_d(mpc_imagref(complex_out.mpc_data()), MPFR_RNDN)
                    == 0.0,
                "Cgemm imaginary result mismatch");
    } catch (const std::exception&) {
        return 1;
    }
    return 0;
}
