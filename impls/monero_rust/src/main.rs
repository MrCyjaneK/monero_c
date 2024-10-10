fn main() {
    unsafe {
        MONERO_DEBUG_test0();
    }
    println!("Called MONERO_DEBUG_test0 successfully.");
}

extern "C" {
    fn MONERO_DEBUG_test0();
}
