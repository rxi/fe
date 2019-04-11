
# C API
To use `fe` in a project a `fe_Context` must first be intialized;
this is done by using the `fe_open()` function. The function expects a
block of memory (typically greater than 16kb), the block is used by the
context to store objects and context state and should remain valid for
the lifetime of the context. `fe_close()` should be called when you are
finished with a context, this will assure any `ptr` objects are properly
garbage collected.

```c
int   size = 1024 * 1024;
void *data = malloc(size);

fe_Context *ctx = fe_open(data, size);

/* ... */

fe_close(ctx);
free(data);
```


## Running a script
To run a script it should first be read then evaluated; this should be
done in a loop if there are several root-level expressions contained in
the script. `fe_readfp()` is provided as a convenience to read from a
file pointer; `fe_read()` can be used with a custom `fe_ReadFn` callback
function to read from other sources.

```c
FILE *fp = fopen("test.fe", "rb");
int gc = fe_savegc(ctx);

for (;;) {
  fe_Object *obj = fe_readfp(ctx, fp);

  /* break if there's nothing left to read */
  if (!obj) { break; }

  /* evaluate read object */
  fe_eval(ctx, obj);

  /* restore GC stack which would now contain both the read object and
  ** result from evaluation */
  fe_restoregc(ctx, gc);
}

fclose(fp);
```


## Calling a function
A function can be called by creating a list and evaulating it; for
example, we could add two numbers using the `+` function:

```c
int gc = fe_savegc(ctx);

fe_Object *objs[3];
objs[0] = fe_symbol(ctx, "+");
objs[1] = fe_number(ctx, 10);
objs[2] = fe_number(ctx, 20);

fe_Object *res = fe_eval(ctx, fe_list(ctx, objs, 3));
printf("result: %g\n", fe_tonumber(ctx, res));

/* discard all temporary objects pushed to the GC stack */
fe_restoregc(ctx, gc);
```


## Creating a cfunc
A `cfunc` can be created by using the `fe_cfunc()` function with a
`fe_CFunc` function argument. The `cfunc` can be bound to a global
variable by using the `fe_set()` function. `cfunc`s take a context and
argument list as its arguments and returns a result object. The result
should never be `NULL`; in the case of wanting to return `nil` the value
returned by `fe_bool(ctx, 0)` should be used.

The `pow` function from `math.h` could be wrapped as such:

```c
static fe_Object* f_pow(fe_Context *ctx, fe_Object *arg) {
  float x = fe_tonumber(ctx, fe_nextarg(ctx, &arg));
  float y = fe_tonumber(ctx, fe_nextarg(ctx, &arg));
  return fe_number(ctx, pow(x, y));
}

fe_set(ctx, fe_symbol(ctx, "pow"), fe_cfunc(ctx, f_pow));
```

The `cfunc` could then be called like any other function:

```clojure
(print (pow 2 10))
```


## Creating a ptr
The `ptr` object type is provided to allow for custom objects. By default
no type checking is performed and thus pointers must be wrapped by the
user and tagged to assure type safety if more than one type of pointer
is used.

A `ptr` object can be created by using the `fe_ptr()` function.

The `gc` and `mark` handlers are provided for dealing with `ptr`s
regarding garbage collection. Whenever a `ptr` is marked by the GC the
`mark` handler is called on it — this is useful if the `ptr` stores
additional objects which also need to be marked via `fe_mark()`. The
`gc` handler is called on the `ptr` when it becomes unreachable and is
garbage collected, such that the resources used by the `ptr` can be
freed. The handlers can be set by setting the relevant fields in the
struct returned by `fe_handlers()`.


## Error handling
When an error occurs the `fe_error()` is called; by default, the
error and stack traceback is printed and the program exited. If you want
to recover from an error the `error` handler field in the struct returned
by `fe_handlers()` can be set and `longjmp()` can be used to exit the
handler; the context is left in a safe state and can continue to be
used. New `fe_Object`s should not be created inside the error handler.
