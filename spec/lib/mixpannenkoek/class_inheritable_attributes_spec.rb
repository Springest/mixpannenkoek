require 'spec_helper'

describe Mixpannenkoek::ClassInheritableAttribute do
  class TestClass
    extend Mixpannenkoek::ClassInheritableAttribute
    class_inheritable_attribute :test_var
  end

  class TestSubClass < TestClass
  end

  it 'is heritable' do
    TestClass.test_var = 'foo'
    expect(TestSubClass.test_var).to eq 'foo'
  end

  it 'is overwritable' do
    TestClass.test_var = 'foo'
    TestSubClass.test_var = 'bar'
    expect(TestSubClass.test_var).to eq 'bar'
  end

  it 'does not overwrite the superclass variable' do
    TestClass.test_var = 'foo'
    TestSubClass.test_var = 'bar'
    expect(TestClass.test_var).to eq 'foo'
  end
end
