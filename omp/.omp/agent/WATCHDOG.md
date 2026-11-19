# Watchdog notes

Especially watch for:

- A new helper, wrapper, or branch that duplicates an existing implementation instead of reusing it.
- A retained old path beside a new path selected by a flag or a fallback on error.
- A name that promises behavior the code does not implement.
- A hidden fallback, a swallowed error, or a default branch that hides a failure from the caller.
- A new path that bypasses an existing normalizer, boundary check, or error vocabulary.
- A helper or type with a single caller that could be inlined or merged.
- A guard that repeats a check the caller or the normalizer already performs.
