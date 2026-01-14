//! Rust-side logging utilities.

use std::sync::OnceLock;

/// Installs a basic logger if the host didn't install one.
///
/// This is safe to call multiple times.
pub(crate) fn ensure_logger_installed() {
    static LOGGER: OnceLock<()> = OnceLock::new();
    let _: &() = LOGGER.get_or_init(|| {
        static STDERR_LOGGER: StderrLogger = StderrLogger;

        // Default verbosity, can be overridden later via `set_max_level`.
        log::set_max_level(log::LevelFilter::Warn);

        // It`s ok if logger has already been set. That means that we are used
        // as rlib and not dylib. We don`t do that right now but that is
        // technically possible.
        drop(log::set_logger(&STDERR_LOGGER));
    });
}

/// Sets the Rust-side max log level (filter).
pub(crate) fn set_max_level(level: log::LevelFilter) {
    ensure_logger_installed();
    log::set_max_level(level);
}

/// Minimal logger implementation for the [`log`] facade.
///
/// Routes [`log::Level::Error`] and [`log::Level::Warn`] to `stderr` and
/// everything else to `stdout`.
struct StderrLogger;

impl log::Log for StderrLogger {
    fn enabled(&self, metadata: &log::Metadata<'_>) -> bool {
        metadata.level() <= log::max_level()
    }

    #[expect(
        clippy::print_stdout,
        clippy::print_stderr,
        reason = "intentional"
    )]
    fn log(&self, record: &log::Record<'_>) {
        if !self.enabled(record.metadata()) {
            return;
        }

        let file = record.file().unwrap_or("?");
        let line = record.line().unwrap_or(0);
        let msg = format!(
            "[{level}] {target} ({file}:{line}): {args}",
            level = record.level(),
            target = record.target(),
            file = file,
            line = line,
            args = record.args()
        );

        match record.level() {
            log::Level::Error | log::Level::Warn => eprintln!("{msg}"),
            log::Level::Info | log::Level::Debug | log::Level::Trace => {
                println!("{msg}");
            }
        }
    }

    fn flush(&self) {}
}
