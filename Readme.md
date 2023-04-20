ReusableFunctions
=================

Automated storage and retrieval of results for Julia functions calls.
ReusableFunctions is a module of [MADS](http://madsjulia.github.io/Mads.jl).

Installation
-------------

```julia
import Pkg; Pkg.add("ReusableFunctions")
```

Example
---------

```julia
import ReusableFunctions
function f(x)
    @info("function f is executed!")
    sleep(1)
    return x
end
f_reuse = ReusableFunctions.maker3function(f);

julia> f(1) # normal function call
[ Info: function f is executed!
1

# function call using ReusableFunctions function
# the first time f_reuse() is called the original function f() is called
julia> f_reuse(1)
[ Info: function f is executed!
1

# function call using ReusableFunctions function
# the second time f_reuse() is called he original function f() is NOT called
# the already stored output from the first call is reported
julia> f_reuse(1)
1
```

Documentation
-------------

ReusableFunctions functions are documented at [https://madsjulia.github.io/Mads.jl/Modules/ReusableFunctions](https://madsjulia.github.io/Mads.jl/Modules/ReusableFunctions)

Projects:
---------

* [MADS](https://github.com/madsjulia)
* [SmartTensors](https://github.com/SmartTensors)
* [SmartML](https://github.com/SmartTensors/SmartML.jl)

Publications, Presentations
--------------------------

* [mads.gitlab.io](http://mads.gitlab.io)
* [madsjulia.github.io](https://madsjulia.github.io)
* [SmartTensors](https://SmartTensors.github.io)
* [SmartTensors.com](https://SmartTensors.com)
* [monty.gitlab.io](http://monty.gitlab.io)
* [montyv.github.io](https://montyv.github.io)
