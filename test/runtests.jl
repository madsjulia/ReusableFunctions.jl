import ReusableFunctions

function f(x)
	sleep(0.01)
	return x
end

run(`rm -Rf ReusableFunctions_restart`)

for fp in [ReusableFunctions.maker3function(f, "ReusableFunctions_restart"), ReusableFunctions.maker3function(f)]
	println("Testing with integers:")
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

	println("Testing with dictionaries")
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

	println("Testing with Float64 arrays")
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

run(`rm -Rf ReusableFunctions_restart`)
