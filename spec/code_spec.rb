require_relative 'helper'

describe Code do
  let(:player) { mock(Player) }
  let(:screen) { MockScreen.new }
  let(:scene) { Scene.new(screen) }

  context "on movement" do
    it 'should ask for ship to turn' do
      converts = {
        :upper => Player::UPPER,
        :upper_right => Player::UPPER_RIGHT,
        :right => Player::RIGHT,
        :lower_right => Player::LOWER_RIGHT,
        :lower => Player::LOWER,
        :lower_left => Player::LOWER_LEFT,
        :left => Player::LEFT,
        :upper_left => Player::UPPER_LEFT
      }

      converts.each_pair do |key, value|
        player.should_receive(:turn_to).with(value)
        run do
          turn_to key
        end
      end
    end

    it 'should raise an error if given with invalid argument' do
      expect {
        run { turn_to :sky }
      }.to raise_error(ArgumentError)
    end

    it 'should move a player to a given direction' do
      player.should_receive(:goto).with(10, 20)
      run {
        goto 10, 20
      }
    end
  end

  context "on positioning" do
    it 'should show where are the ships' do
      run {
        me.x.should == 20
        me.y.should == 300
        enemy.x.should == 780
        enemy.y.should == 300
      }
    end

    it 'should show position of mine and other ship' do
      run {
        me.direction.should == :upper
        enemy.direction.should == :upper
      }
    end

    it 'should show energy for both ships' do
      run {
        me.energy.should == 100
        enemy.energy.should == 100
      }
    end
  end

  context "on security" do
    it 'should not register a new player' do
      new_player = mock Player
      expect {
        run do
          self.class.register_to new_player
        end
      }.to raise_error(NoMethodError)
    end

    it 'should not have any instance variable to change' do
      code = this_code {}
      code.instance_variables.should be_empty
      code.class.instance_variables.should be_empty
      eigen = class << code.class; self; end
      eigen.instance_variables.should be_empty
    end

    it 'should be able to run the block if "block" is redefined' do
      run { block = nil }
    end

    it 'should not be able to traversal between objects' do
      expect {
        run { ObjectSpace.each_object { |x| x } }
      }.to raise_error
    end

    it 'should not be able to access "player" or "scene"' do
      expect {
        run { player }
      }.to raise_error(NameError)

      expect {
        run { scene }
      }.to raise_error(NameError)
    end
  end

  def run(&block)
    this_code(&block).run
  end

  def this_code &block
    code = Class.new(Code) do
      each_frame &block
    end
    player.stub!(:x).and_return(20)
    player.stub!(:y).and_return(300)
    player.stub!(:current_animation).and_return(0)
    scene.instance_variable_set :@p1, player
    scene.register_to code, :p1
    scene.instance_variable_get :@code1
  end
end
