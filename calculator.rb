require 'colorize'

# This class contains all of the logic for calculating expressions 
class Calculator
	# Extract a math expression from the message and return its value
	def calculate(message)
		@values = []
		@operations = []
		self.parse_expression(message)
		return self.evaluate_expression
	end
	
	# Break the message down into a series of values and operations
	def parse_expression(message)
		currentValue = ""
		i = 0
		
		if /.*[Ll]ife.*[Uu]niverse.*[Ee]verything.*/.match(message) ||
			/.*[Mm]eaning.*[Ll]ife.*/.match(message)
			@values.push(42)
			return
		end

		while i < message.length
			c = message[i]
			
			case c
				when /\d/
					if @values.length != @operations.length
						raise "Incorrect number of operations during read"
					end
					currentValue << c
				when "+", "-", "*", "/"
					if currentValue == "" && @values.length == @operations.length
						raise "No values read before operation"
					end
					if currentValue != ""
						@values.push(currentValue.to_f)
						currentValue = ""
					end
					@operations.push(c)
				when "("
					closeParenthesesIndex = message.index(")", i)
					if closeParenthesesIndex == nil
						raise "No closing parentheses"
					end
					innerCalculator = Calculator.new
					innerExpression = message[i + 1, closeParenthesesIndex - i - 1]
					innerValue = innerCalculator.calculate(innerExpression)
					@values.push(innerValue)
					i = closeParenthesesIndex
				when ")"
					raise "Invalid closing parentheses"
				when "."
					if currentValue != "" &&
					  ((i > 0 && message[i - 1][/\d/] != nil) ||
					  (i < message.length - 1 && message[i + 1][/\d/] != nil))
						currentValue << c
					elsif currentValue == "" && i < message.length - 1 && message[i + 1][/\d/] != nil
						currentValue << c
					end
				else
					if currentValue != ""
						@values.push(currentValue.to_f)
						currentValue = ""
					end
			end
			
			i += 1
		end

		if currentValue != ""
			@values.push(currentValue.to_f)
		end
		
		if @operations.length != @values.length - 1
			raise "Incorrect number of operations after read"
		end
	end
	
	# Evaluate all values and operations pulled from the message and return the final value
	def evaluate_expression
		while @operations.length > 0
			i = 0
			multIndex = @operations.index("*")
			divIndex = @operations.index("/")
			
			if multIndex != nil && divIndex != nil
				i = [multIndex, divIndex].min
			else
				if multIndex != nil
					i = multIndex
				end
				if divIndex != nil
					i = divIndex
				end
			end

			@values[i] = self.evaluate_subexpression(@values[i], @values[i + 1], @operations[i])
			@operations.delete_at(i)
			@values.delete_at(i + 1)
		end
		
		return @values[0]
	end
	
	# Evaluate a single operation involving two values
	def evaluate_subexpression(firstValue, secondValue, operation)
		case operation
			when "+"
				return firstValue + secondValue
			when "-"
				return firstValue - secondValue
			when "*"
				return firstValue * secondValue
			when "/"
				return firstValue / secondValue
		end
		
		raise "Invalid operation"
	end
end

# Calculator unit tests
class CalculatorTests
	def execute_tests
		@passes = 0
		@total = 0
		puts "Executing tests...".yellow
		
		test("What is 6 + 7?", 13)
		test("Calculate 3 + 6 - 2", 7)
		test("Do 3 + (6 - 2)", 7)
		test("What's 3 + 2 * 4?", 11)
		test("5+3*(8-4)+2", 19)
		test("(4 - 3) / (3 * 3)", 1.to_f/9.to_f)
		test("5.2 + 3.7", 8.9)
		test(".87 + 3.", 3.87)
		test(".12345678 + .23456789", 0.35802467)
		test("237 - (6 + 12 * 10)", 111)
		test("(3 -   2) + 5", 6)
		test("(3a + 2b)", 5)
		test("2 + 4 +", "Incorrect number of operations after read")
		test("-2 + 3", "No values read before operation")
		test("5 4 3 2 1", "Incorrect number of operations during read")
		test("Calc 5 * (2 + 3))", "Invalid closing parentheses")
		test("Life, the universe, everything!", 42)
		
		if (@passes == @total)
			puts "All tests passed".green
		elsif
			puts "#{@passes} / #{@total} tests passed".red
		end
	end
	
	def test(message, expectedResult)
		# Arrange
		c = Calculator.new
		result = nil
		
		# Act
		begin
			result = c.calculate(message)
		rescue StandardError => error
			result = error.to_s
		end
		
		# Assert
		print "#{message} => #{result} ... "
		if result == expectedResult
			@passes += 1
			puts "PASS".green
		else
			puts "FAIL, expected #{expectedResult}".red
		end
		@total += 1
	end
end

if __FILE__ == $0
	ct = CalculatorTests.new
	ct.execute_tests
end