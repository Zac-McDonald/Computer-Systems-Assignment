def calc_colour (r, g, b)
	r = (r / 256 * 32).floor
	g = (g / 256 * 64).floor
	b = (b / 256 * 32).floor

	hex = (r << 11) | (g << 5) | b

	puts "16-bit Colour = (#{r}, #{g}, #{b}) = ($#{hex.to_s(16)})"
end

finished = false
begin
	puts "\nEnter a 24-bit colour in the form \"r g b\":"
	input = gets.chomp

	if (input != "")
		numbers = input.split(' ').map { |i| i.to_f }

		if (numbers.length == 3)
			calc_colour(numbers[0], numbers[1], numbers[2])
		else
			puts "Invalid colour, please enter the rgb values, space seperated."
		end
	else
		finished = true
	end
end until finished