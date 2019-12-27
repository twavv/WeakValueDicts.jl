# WeakValueDicts
[![Build Status](https://travis-ci.com/travigd/WeakValueDicts.jl.svg?branch=master)](https://travis-ci.com/travigd/WeakValueDicts.jl)
[![codecov](https://codecov.io/gh/travigd/WeakValueDicts.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/travigd/WeakValueDicts.jl)

```julia
julia> using WeakValueDicts

julia> mutable struct MyStruct
           value::Any
       end

julia> wvd = WeakValueDict()
WeakValueDict{Any,Any} with 0 entries

# Hold an explicit reference to an instance of MyStruct so it wont be GC'd
julia> foo = MyStruct("foo")
MyStruct("foo")

julia> wvd["foo"] = foo
MyStruct("foo")

julia> wvd["foo"]
MyStruct("foo")

# Clear the reference and run the garbage collector
julia> foo = nothing

julia> Base.GC.gc(true)

# We no longer have a foo entry in the dict because it was finalized (GC'd)
julia> wvd["foo"]
ERROR: KeyError: key "foo" not found
```

## Limitations
Note: All values in `WeakValueDict`s must be mutable due to how Julia implements finalizers.
Mutable datatypes include `String`, `Array`, and mutable structs but excludes types such as `Int` and immutable structs (i.e., structs without the `mutable` keyword).
