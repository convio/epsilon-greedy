module EpsilonGreedy
  class Metrics
    attr_accessor :values

    def initialize(yaml_file=nil)
      yaml_file ||= File.dirname(__FILE__) + '/../metrics.store'
      @yaml_file = yaml_file
      load
    end


    def save
      yaml = YAML::Store.new @yaml_file
      yaml.transaction do
        output = []
        @values.each do |h,k|
          reward = sprintf("%.4f", yaml[h][:wins].to_f/yaml[h][:tries].to_f).to_f
          yaml[h] = k
          yaml[h][:reward] = reward
          output << (reward * 100).to_i
        end

        puts output.inspect
        csv ||= File.dirname(__FILE__) + '/../output.csv'
        require'csv'
        CSV.open(csv, 'a') {|f| f << output}
      end

    end

    def load
      @values = File.open(@yaml_file) {|line| YAML::load line}
    end

  end
end