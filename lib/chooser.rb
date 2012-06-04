module EpsilonGreedy
  class Chooser
    attr_reader :metrics

    def initialize(yaml_file=nil)
      @metrics = Metrics.new(yaml_file)
    end


    def values
      @metrics.values
    end


    def choose
      choice = pick(@metrics.values)
      increment_tries(choice)
      puts "*** PICKED '#{choice}' from #{@metrics.values.inspect}"
      choice
    end


    def increment_tries(name)
      @metrics.values[name][:tries] += 1
      @metrics.save
    end


    def increment_wins(name)
      @metrics.values[name][:wins] += 1
      @metrics.save
    end


    def pick(values)
      if rand(10) + 1 == 2 #10% of the time
        puts '*** SELECT A RANDOM LEVER (10%)'
        selection = [pick_random_lever(values)]
      else
        puts '*** SELECT THE GREATEST REWARD'
        selection = pick_lever_with_greatest_reward(values)
      end
      if selection.size > 1 #multiple matches for greatest reward
        selection[rand(selection.size)]
      else
        selection.first
      end
    end


    def pick_random_lever(values)
      choices = values.keys
      random_choice = values.keys[rand(choices.size)]
    end


    def pick_lever_with_greatest_reward(values)
      max = max_reward(values)
      values.select { |k, v| v[:reward] == max }.keys
    end


    def max_reward(values)
      max = 0
      values.each { |k, v| max = v[:reward] if v[:reward] > max }
      max
    end

  end
end
