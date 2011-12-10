require 'spec_helper'
require 'omniauth-healpay'

describe OmniAuth::Strategies::Healpay do
  before :each do
    @request = double('Request')
    @request.stub(:params) { {} }
  end
  
  subject do
    OmniAuth::Strategies::Healpay.new(nil, @options || {}).tap do |strategy|
      strategy.stub(:request) { @request }
    end
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'has correct Healpay site' do
      subject.client.site.should eq('https://gate.healpay.com')
    end

    it 'has correct authorize url' do
      subject.client.options[:authorize_url].should eq('https://gate.healpay.com/oauth/healpay/authorize')
    end

    it 'has correct token url' do
      subject.client.options[:token_url].should eq('https://gate.healpay.com/oauth/healpay/access_token')
    end
  end

  describe '#callback_url' do
    it " callback_url from request" do
      url_base = 'http://auth.request.com'
      @request.stub(:url){ url_base + "/page/path" }
      subject.stub(:script_name) { "" } # to not depend from Rack env
      subject.callback_url.should == url_base + "/auth/healpay/callback"
    end
  end
  
  describe '#uid' do
    before :each do
      subject.stub(:raw_info) { { 'id' => '123' } }
    end
    
    it 'returns the id from raw_info' do
      subject.uid.should eq('123')
    end
  end
  
  describe '#info' do
    before :each do
      @raw_info ||= { 'name' => 'Fred Smith' }
      subject.stub(:raw_info) { @raw_info }
    end
    
    context 'when data is present in raw info' do
      it 'returns the email' do
        @raw_info['email'] = 'fred@smith.com'
        subject.info['email'].should eq('fred@smith.com')
      end

      it 'returns the first name' do
        @raw_info['first_name'] = 'Fred'
        subject.info['first_name'].should eq('Fred')
      end
    
      it 'returns the last name' do
        @raw_info['last_name'] = 'Smith'
        subject.info['last_name'].should eq('Smith')
      end
    end
  end
  
  describe '#raw_info' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      subject.stub(:access_token) { @access_token }
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      @access_token.stub(:token)
      @access_token.stub(:expires?)
      @access_token.stub(:expires_at)
      @access_token.stub(:refresh_token)
      subject.stub(:access_token) { @access_token }
    end
    
    it 'returns a Hash' do
      subject.credentials.should be_a(Hash)
    end
    
    it 'returns the token' do
      @access_token.stub(:token) { '123' }
      subject.credentials['token'].should eq('123')
    end
    
    it 'returns the expiry status' do
      @access_token.stub(:expires?) { true }
      subject.credentials['expires'].should eq(true)
      
      @access_token.stub(:expires?) { false }
      subject.credentials['expires'].should eq(false)
    end
    
    it 'returns the refresh token and expiry time when expiring' do
      ten_mins_from_now = (Time.now + 600).to_i
      @access_token.stub(:expires?) { true }
      @access_token.stub(:refresh_token) { '321' }
      @access_token.stub(:expires_at) { ten_mins_from_now }
      subject.credentials['refresh_token'].should eq('321')
      subject.credentials['expires_at'].should eq(ten_mins_from_now)
    end
    
    it 'does not return the refresh token when it is nil and expiring' do
      @access_token.stub(:expires?) { true }
      @access_token.stub(:refresh_token) { nil }
      subject.credentials['refresh_token'].should be_nil
      subject.credentials.should_not have_key('refresh_token')
    end
    
    it 'does not return the refresh token when not expiring' do
      @access_token.stub(:expires?) { false }
      @access_token.stub(:refresh_token) { 'XXX' }
      subject.credentials['refresh_token'].should be_nil
      subject.credentials.should_not have_key('refresh_token')
    end
  end
  
  describe '#extra' do
    before :each do
      @raw_info = { 'name' => 'Fred Smith' }
      subject.stub(:raw_info) { @raw_info }
    end
    
    it 'returns a Hash' do
      subject.extra.should be_a(Hash)
    end
    
    it 'contains raw info' do
      subject.extra.should eq({ :raw_info => @raw_info })
    end
  end
end
