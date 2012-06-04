$: << File.dirname(__FILE__)
require 'spec_helper'

context "Variants" do
  before :each do
    # rewrite the test file
    File.unlink 'metrics.store' if File.exists? 'metrics.store'
    @data = {
      :flow_1 => {:wins => 1, :tries => 1, :reward => 1},
      :flow_2 => {:wins => 2, :tries => 3, :reward => 0.33},
      :flow_3 => {:wins => 1, :tries => 4, :reward => 0.25}
    }
    yaml = YAML::Store.new 'metrics.store'
    yaml.transaction do
      @data.each {|h,k| yaml[h] = k}
    end
    @chooser = EpsilonGreedy::Chooser.new('metrics.store')
  end

  specify "choose" do
    value = @chooser.choose
    value.should_not be_nil
    @data.keys.should include(value)
  end

  specify "pick_random_lever" do
    random_values = []
    100.times do
      random_values << @chooser.pick_random_lever(@data)
    end
    random_values.uniq.sort.should == [:flow_1, :flow_2, :flow_3]
  end

  specify "pick_lever_with_greatest_reward" do
    data = {
          :flow_1 => {:wins => 1, :tries => 1, :reward => 1},
          :flow_2 => {:wins => 2, :tries => 3, :reward => 0.33},
          :flow_3 => {:wins => 1, :tries => 4, :reward => 0.25}
    }
    @chooser.pick_lever_with_greatest_reward(data).should == [:flow_1]
  end

  specify "multiple matches on pick_lever_with_greatest_reward" do
    data = {
          :flow_1 => {:wins => 1, :tries => 1, :reward => 1},
          :flow_2 => {:wins => 2, :tries => 3, :reward => 0.33},
          :flow_3 => {:wins => 1, :tries => 4, :reward => 1}
    }
    @chooser.pick_lever_with_greatest_reward(data).should == [:flow_1, :flow_3]
  end

  specify "pick" do
    random_values = []
    100.times do
      random_values << @chooser.choose
    end
    random_values.uniq.sort.should == [:flow_1, :flow_2, :flow_3]
  end

  specify "increment tries" do
    @chooser.values[:flow_1].should == {:wins => 1, :tries => 1, :reward => 1}
    @chooser.increment_tries(:flow_1)
    @chooser.increment_tries(:flow_1)
    @chooser.values[:flow_1].should == {:wins => 1, :tries => 3, :reward => 0.3333}
    @chooser.metrics.load
    @chooser.values[:flow_1].should == {:wins => 1, :tries => 3, :reward => 0.3333}
  end

  specify "increment wins" do
    @chooser.values[:flow_1].should == {:wins => 1, :tries => 1, :reward => 1}
    @chooser.increment_tries(:flow_1)
    @chooser.increment_tries(:flow_1)
    @chooser.increment_wins(:flow_1)
    @chooser.values[:flow_1].should == {:wins => 2, :tries => 3, :reward => 0.6667}
    @chooser.metrics.load
    @chooser.values[:flow_1].should == {:wins => 2, :tries => 3, :reward => 0.6667}
  end

end

