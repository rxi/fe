# fe
A *tiny*, embeddable language implemented in ANSI C

```clojure
(= reverse (fn (lst)
  (let res nil)
  (while lst
    (= res (cons (car lst) res))
    (= lst (cdr lst))
  )
  res
))

(= animals '("cat" "dog" "fox"))

(print (reverse animals)) ; => ("fox" "dog" "cat")
```

## Overview
* Supports numbers, symbols, strings, pairs, lambdas, macros
* Lexically scoped variables, closures
* Small memory usage within a fixed-sized memory region — no mallocs
* Simple mark and sweep garbage collector
* Easy to use C API
* Portable ANSI C — works on 32 and 64bit
* Concise — less than 800 sloc

---

* **[Demo Scripts](scripts)**
* **[C API Overview](doc/capi.md)**
* **[Language Overview](doc/lang.md)**
* **[Implementation Overview](doc/impl.md)**


## Contributing
The library focuses on being lightweight and minimal; pull requests will
likely not be merged. Bug reports and questions are welcome.


## License
This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.
