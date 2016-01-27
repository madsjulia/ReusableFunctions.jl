import R3Function

function f(x)
	sleep(1)
	return x
end

run(`rm -Rf restart`)

for fp in [R3Function.maker3function(f, "restart"), R3Function.maker3function(f)]
	println("Testing with ints:")
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

	println("testing with Dict's")
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
