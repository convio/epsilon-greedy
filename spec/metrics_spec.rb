$: << File.dirname(__FILE__)
require 'spec_helper'


context "reading and writing" do
  before :each do
    File.unlink 'metrics.store' if File.exists? 'metrics.store'
    data = {
      :flow_1 => {:wins => 1, :tries => 1},
      :flow_2 => {:wins => 1, :tries => 1}
    }
    @yaml = YAML::Store.new 'metrics.store'
    @yaml.transaction do
      data.each {|h,k| @yaml[h] = k}
    end
  end

  specify "load values" do
    e = EpsilonGreedy::Metrics.new(File.expand_path('metrics.store'))
    e.values.should == {:flow_1=>{:wins=>1, :tries=>1}, :flow_2=>{:wins=>1, :tries=>1}}
  end

  specify "update values" do
    e = EpsilonGreedy::Metrics.new(File.expand_path('metrics.store'))
    e.values[:flow_1][:wins].should == 1
    e.values[:flow_1][:tries].should == 1
    e.values[:flow_1][:wins] = 1
    e.values[:flow_1][:tries] = 2
    e.save
    e.values[:flow_1][:wins].should == 1
    e.values[:flow_1][:tries].should == 2
  end

end

