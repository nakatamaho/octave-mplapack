// Test-only audit probe for the gmpfrxx_mkII external default-context ABI.
// This file is not installed and is not part of the Octave package.

#include <gmpfrxx_mkII/detail/gmp_default_context.hpp>

#include <atomic>
#include <cstdint>
#include <iostream>
#include <thread>

namespace {

bool valid(const gmpxx_mkII_default_context_v1& context, std::uint64_t expected)
{
    return context.abi_version == gmpfrxx_mkII::detail::gmp_default_context_abi_version &&
           context.struct_size == sizeof(gmpxx_mkII_default_context_v1) &&
           context.mpf_precision_bits == expected;
}

} // namespace

int main()
{
    gmpxx_mkII_default_context_v1 initial{};
    gmpxx_mkII_get_current_default_context_v1(&initial);
    if (initial.abi_version != gmpfrxx_mkII::detail::gmp_default_context_abi_version ||
        initial.struct_size != sizeof(gmpxx_mkII_default_context_v1) ||
        initial.mpf_precision_bits == 0 ||
        gmpxx_mkII_default_context_mode_v1() !=
            GMPXX_MKII_DEFAULT_CONTEXT_EXTERNAL_PROVIDER ||
        gmpxx_mkII_default_context_provider_token_v1() == nullptr) {
        std::cerr << "invalid initial gmpfrxx provider context\n";
        return 1;
    }

    gmpxx_mkII_default_context_v1 main_context = initial;
    main_context.mpf_precision_bits = 1024;
    gmpxx_mkII_set_thread_default_context_v1(&main_context);

    gmpxx_mkII_default_context_v1 observed{};
    gmpxx_mkII_get_current_default_context_v1(&observed);
    if (!valid(observed, 1024)) {
        std::cerr << "main-thread provider context update failed\n";
        return 1;
    }

    std::atomic<std::uint64_t> worker_a{0};
    std::atomic<std::uint64_t> worker_b{0};
    std::thread a([&] {
        auto context = main_context;
        context.mpf_precision_bits = 256;
        gmpxx_mkII_set_thread_default_context_v1(&context);
        gmpxx_mkII_default_context_v1 current{};
        gmpxx_mkII_get_current_default_context_v1(&current);
        worker_a.store(current.mpf_precision_bits);
    });
    std::thread b([&] {
        auto context = main_context;
        context.mpf_precision_bits = 2048;
        gmpxx_mkII_set_thread_default_context_v1(&context);
        gmpxx_mkII_default_context_v1 current{};
        gmpxx_mkII_get_current_default_context_v1(&current);
        worker_b.store(current.mpf_precision_bits);
    });
    a.join();
    b.join();

    gmpxx_mkII_get_current_default_context_v1(&observed);
    if (worker_a.load() != 256 || worker_b.load() != 2048 || !valid(observed, 1024)) {
        std::cerr << "provider context is not thread-local\n";
        return 1;
    }

    gmpxx_mkII_reset_thread_default_context_v1();
    gmpxx_mkII_get_current_default_context_v1(&observed);
    if (observed.mpf_precision_bits != initial.mpf_precision_bits) {
        std::cerr << "provider context reset failed\n";
        return 1;
    }

    std::cout << "gmpfrxx provider ABI/TLS PASS\n";
    return 0;
}
