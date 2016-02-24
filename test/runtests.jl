import ReusableFunctions

function f(x)
	sleep(0.1)
	return x
end

run(`rm -Rf ReusableFunctions_restart`)

for fp in [ReusableFunctions.maker3function(f, "ReusableFunctions_restart"), ReusableFunctions.maker3function(f)]
	println("Testing with integers:")
	for i = 1:2
		@assert fp(1) == 1
	end

	print("Should be about 1 second:")
	@time for i = 1:10
		@assert fp(i) == i
	end

	print("Should be less than .1 seconds:")
	@time for i = 1:10
		@assert fp(i) == i
	end

	println("Testing with dictionaries:")
	d = Dict(zip([1, 2], [3, 4]))
	for i = 1:2
		@assert fp(d) == d
	end

	print("Should be about 1 second:")
	@time for i = 1:10
		d = Dict(zip([1, 2], [i, i + 1]))
		@assert fp(d) == d
	end

	print("Should be less than .1 seconds:")
	@time for i = 1:10
		d = Dict(zip([1, 2], [i, i + 1]))
		@assert fp(d) == d
	end

	println("Testing with Float64 arrays:")
	v = zeros(10)
	for i = 1:2
		@assert fp(v) == v
	end

	print("Should be about 1 second:")
	@time for i = 1:10
		v = i * ones(10)
		@assert fp(v) == v
	end

	print("Should be less than .1 seconds:")
	@time for i = 1:10
		v = i * ones(10)
		@assert fp(v) == v
	end
end

run(`rm -Rf ReusableFunctions_restart`)

function g(x)
	sleep(0.1)
	return Dict("asdf"=>x["a"] - x["b"], "hjkl"=>x["a"] * x["b"])
end

r3g = ReusableFunctions.maker3function(g, "ReusableFunctions_restart", ["a", "b"], ["asdf", "hjkl"])
println("testing with Dict->Dict efficient storage")
d = Dict("a"=>1, "b"=>3)
r = Dict("asdf"=>-2, "hjkl"=>3)
for i = 1:2
	@assert r3g(d) == r
end

print("Should be about 1 second:")
@time for i = 1:10
	d = Dict(zip(["a", "b"], [i, i + 2]))
	r = Dict("asdf"=>-2, "hjkl"=>i * (i + 2))
	@assert r3g(d) == r
end

print("Should be less than .1 seconds:")
@time for i = 1:10
	d = Dict(zip(["a", "b"], [i, i + 2]))
	r = Dict("asdf"=>-2, "hjkl"=>i * (i + 2))
	@assert r3g(d) == r
end

run(`rm -Rf ReusableFunctions_restart`)
