require 'spec_helper'

describe "UsersController" do

  let(:original_controller) { HomeController.new }
  let(:revised_controller) { MembersController.new }
  let(:group) { Group.new(id: 11) }
  let(:member) { Member.new(id: 1, group_id: 11) }

  before do
    original_controller.request = ActionController::TestRequest.new
    revised_controller.request = ActionController::TestRequest.new
    group.stub(:persisted?) { true }
    member.stub(:persisted?) { true }
  end

  it "generates a URL for a new member" do
    arg = Member.new
    expect(revised_controller.url_for(arg)).to eq(original_controller.url_for(arg))
  end

  it "generates a URL for a member" do
    arg = member
    expect(revised_controller.url_for(arg.dup)).to eq(original_controller.url_for(arg.dup))
  end

  it "generates a URL for a nested member" do
    arg = [group, member]
    expect(revised_controller.url_for(arg.dup)).to eq(original_controller.url_for(arg.dup))
  end

  it "generates a URL for a member with a specified RESTful action" do
    arg = [:edit, member]
    expect(revised_controller.url_for(arg.dup)).to eq(original_controller.url_for(arg.dup))
  end

  it "generates a URL for a new nested member with a specified RESTful action" do
    arg = [:create, group, Member.new]
    expect(revised_controller.url_for(arg.dup)).to eq(original_controller.url_for(arg.dup))
  end

  it "generates a URL for a nested member with a specified RESTful action" do
    arg = [:edit, group, member]
    expect(revised_controller.url_for(arg.dup)).to eq(original_controller.url_for(arg.dup))
  end

end