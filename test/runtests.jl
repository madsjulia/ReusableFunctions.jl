import ReusableFunctions

function freuse(x)
	sleep(0.1)
	return x
end

run(`rm -Rf ReusableFunctions_restart`)

for fp in [ReusableFunctions.maker3function(freuse, "ReusableFunctions_restart"), ReusableFunctions.maker3function(freuse)]
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
	reuse_d = Dict(zip([1, 2], [3, 4]))
	for i = 1:2
		@assert fp(reuse_d) == reuse_d
	end

	print("Should be about 1 second:")
	@time for i = 1:10
		reuse_d = Dict(zip([1, 2], [i, i + 1]))
		@assert fp(reuse_d) == reuse_d
	end

	print("Should be less than .1 seconds:")
	@time for i = 1:10
		reuse_d = Dict(zip([1, 2], [i, i + 1]))
		@assert fp(reuse_d) == reuse_d
	end

	println("Testing with Float64 arrays:")
	reuse_v = zeros(10)
	for i = 1:2
		@assert fp(reuse_v) == reuse_v
	end

	print("Should be about 1 second:")
	@time for i = 1:10
		reuse_v = i * ones(10)
		@assert fp(reuse_v) == reuse_v
	end

	print("Should be less than .1 seconds:")
	@time for i = 1:10
		reuse_v = i * ones(10)
		@assert fp(reuse_v) == reuse_v
	end
end

run(`rm -Rf ReusableFunctions_restart`)

function greuse(x)
	sleep(0.1)
	return Dict("asdf"=>x["a"] - x["b"], "hjkl"=>x["a"] * x["b"])
end

r3g = ReusableFunctions.maker3function(greuse, "ReusableFunctions_restart", ["a", "b"], ["asdf", "hjkl"])
println("testing with Dict->Dict efficient storage")
reuse_d = Dict("a"=>1, "b"=>3)
reuse_r = Dict("asdf"=>-2, "hjkl"=>3)
for i = 1:2
	@assert r3g(reuse_d) == reuse_r
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
