#[cfg_attr(target_os = "windows", path = "windows/hi.rs")]
#[cfg_attr(not(target_os = "windows"), path = "not-win/hi.rs")]
mod hi;

fn main() {
    hi::hi();
}
