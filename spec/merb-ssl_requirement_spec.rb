require File.dirname(__FILE__) + '/spec_helper'

class Accounts < Merb::Controller
  include SslRequirement
  
  ssl_required :a, :b
  ssl_allowed :c
  
  def a; end
  def b; end
  def c; end
  def d; end
  
end

describe "merb_ssl_requirement" do
  
  before do
    @controller = Accounts.new( fake_request )
    mock_logger = mock("Logger", :info => "INFO", :flush => nil)
    Merb.stub!(:logger).and_return(mock_logger)
  end
  
  describe "when ssl is required" do
    
    describe "and the request is HTTP" do
      it "should redirect to HTTPS" do
        dispatch_to(Accounts, :a) do |c|
          c.request.env['HTTPS'].should_not == "on"
        end.should redirect_to("https://localhost/")
      end
    end
    
    describe "and the request is HTTPS" do
      it "should not redirect" do
        dispatch_to(Accounts, :b) do |c|
          c.request.env['HTTPS'] = "on"
        end.should_not redirect
      end
    end

  end
  
  describe "when ssl is allowed" do
    
    describe "and the request is HTTP" do
      it "should not redirect" do
        dispatch_to(Accounts, :c) do |c|
          c.request.env['HTTPS'].should_not == "on"
        end.should_not redirect
      end
    end
    
    describe "and the request is HTTPS" do
      it "should not redirect" do
        dispatch_to(Accounts, :c) do |c|
          c.request.env['HTTPS'] = "on"
        end.should_not redirect
      end
    end
  end
  
  describe "when ssl is disallowed" do
    
    describe "and the request is HTTP" do
      it "should not redirect" do
        dispatch_to(Accounts, :d) do |c|
          c.request.env['HTTPS'].should_not == "on"
        end.should_not redirect
      end
    end
    
    describe "and the request is HTTPS" do
      it "should redirect to HTTP" do
        dispatch_to(Accounts, :d) do |c|
          c.request.env['HTTPS'] = "on"
        end.should redirect_to("http://localhost/")
      end
    end
  end
end