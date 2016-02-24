import ReusableFunctions

function f(x)
	sleep(1)
	return x
end

run(`rm -Rf restart`)

for fp in [ReusableFunctions.maker3function(f, "restart"), ReusableFunctions.maker3function(f)]
	println("Testing with Ints:")
	println("Should be about 1 second:")
	@time for i = 1:100
		@assert fp(1) == 1
	end

	println("Should be about 9 seconds:")
	@time for i = 1:10
		@assert fp(i) == i
	end

	println("Should be less than a second:")
	@time for i = 1:10
		@assert fp(i) == i
	end
	println()

	println("testing with Dicts")
	println("Should be about 1 second:")
	d = Dict(zip([1, 2], [3, 4]))
	@time for i = 1:100
		@assert fp(d) == d
	end

	println("Should be about 9 seconds:")
	@time for i = 1:10
		d = Dict(zip([1, 2], [i, i + 1]))
		@assert fp(d) == d
	end

	println("Should be less than a second:")
	@time for i = 1:10
		d = Dict(zip([1, 2], [i, i + 1]))
		@assert fp(d) == d
	end
	println()

	println("testing with Float64 arrays")
	println("Should be about 1 second:")
	v = zeros(10)
	@time for i = 1:100
		@assert fp(v) == v
	end

	println("Should be about 9 seconds:")
	@time for i = 1:10
		v = i * ones(10)
		@assert fp(v) == v
	end

	println("Should be less than a second:")
	@time for i = 1:10
		v = i * ones(10)
		@assert fp(v) == v
	end
	println()
end

run(`rm -Rf restart`)

function g(x)
	sleep(1)
	return Dict("asdf"=>x["a"] - x["b"], "hjkl"=>x["a"] * x["b"])
end

r3g = ReusableFunctions.maker3function(g, "restart", ["a", "b"], ["asdf", "hjkl"])
println("testing with Dicts")
println("Should be about 1 second:")
d = Dict("a"=>1, "b"=>3)
r = Dict("asdf"=>-2, "hjkl"=>3)
@time for i = 1:100
	@assert r3g(d) == r
end

println("Should be about 9 seconds:")
@time for i = 1:10
	d = Dict(zip(["a", "b"], [i, i + 2]))
	r = Dict("asdf"=>-2, "hjkl"=>i * (i + 2))
	@assert r3g(d) == r
end

println("Should be less than a second:")
@time for i = 1:10
	d = Dict(zip(["a", "b"], [i, i + 2]))
	r = Dict("asdf"=>-2, "hjkl"=>i * (i + 2))
	@assert r3g(d) == r
end
