dir = File.join(File.dirname(__FILE__), '.')
$LOAD_PATH.unshift File.expand_path("#{dir}/../lib")

require 'rspec'
alias :context :describe
require 'epsilon-greedy'