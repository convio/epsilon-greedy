require'csv'

module EpsilonGreedy
  class Metrics
    attr_accessor :values

    def initialize(yaml_file)
      @yaml_file = yaml_file
      load
    end


    def save
      output = []
      @values.each do |h,k|
        reward = sprintf("%.4f", @values[h][:wins].to_f/@values[h][:tries].to_f).to_f
        @values[h][:reward] = reward
        output << (reward * 100).to_i
      end
      File.open( @yaml_file, 'w' ) do |out|
         YAML.dump( @values, out )
      end
      puts output.inspect
      csv ||= File.dirname(__FILE__) + '/../output.csv'
      CSV.open(csv, 'a') {|f| f << output}
    end

    def load
      @values = File.open(@yaml_file) {|line| YAML::load line}
    end

  end
end