require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleXurrency" do
  before(:all) do
    SimpleXurrency.disable_cache
  end
  
  describe "in its basic behavior" do
    it "enhances instances of Numeric with currency methods" do
      expect { 30.eur && 30.usd && 30.gbp }.to_not raise_error
    end

    it "handles zero values (by returning them straight away)" do
      0.usd.to_eur.should == 0.0
    end

  end

  context "using Xurrency API for right-now exchange" do
    it "returns a converted amount from one currency to another" do
      amount = 2
      rate = 1.5422
      
      mock_xurrency_api('eur', 'usd', amount, rate, Time.now.utc)
      amount.eur.to_usd.should == amount*rate

      amount = 2
      rate = 3.4874
      
      mock_xurrency_api('gbp', 'chf', amount, rate, Time.now.utc)
      amount.gbp.to_chf.should == amount*rate
      
      rate = 0.6322

      (0..100).each do |x|
        mock_xurrency_api('usd', 'gbp', x, rate, Time.now.utc)
        x.usd.to_gbp.to_s.should == (x*rate).to_s
      end
    end

    it "raises any error returned by the api call" do
      mock_xurrency_api('usd', 'xxx', 1, 1.5, Time.now.utc, :fail_with => "Currencies are not valid")
      mock_xurrency_api('usd', 'eur', 1_000_000_000, 1.5, Time.now.utc)
      mock_xurrency_api('usd', 'usd', 1, 1.5, Time.now.utc, :fail_with => "Currency codes are the same")

      expect {1.usd.to_xxx}.to raise_error("Currencies are not valid")
      expect {1_000_000_000.usd.to_eur}.to_not raise_error
      expect {1.usd.to_usd}.to raise_error("Currency codes are the same")
    end

    it "handles a negative value returning a negative as well" do
      mock_xurrency_api('usd', 'eur', 1, 1.5, Time.now.utc)

      -1.usd.to_eur.should == -1.5
    end

    it "handles big amounts" do
      mock_xurrency_api('usd', 'eur', 1, 1.5, Time.now.utc)

      1_000_000_000.usd.to_eur.should == 1_500_000_000
    end
    
    it "returns the updated date" do
      mock_xurrency_api('usd', 'eur', 1, 1.5, '2010-10-04 00:00:00')

      1.usd.to_eur_updated_at.should == '2010-10-04 00:00:00'
    end
  end
end