# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/cookbook_info'

describe CookbookInfo do
  describe '.local_version' do
    it 'will return the local version' do
      version = '1.2.16'
      expect(CookbookInfo).to receive(:`).with('cat metadata.rb | grep version').and_return("7:version           \"#{version}\"")

      expect(CookbookInfo.local_version).to eq(version)
    end
  end

  describe '.server_versions' do
    it 'will return server versions' do
      cookbook = 'random-cookbook'
      versions = 'random-cookbook   0.1.65  0.1.64  0.1.63  0.1.62  0.1.60  0.1.59  0.1.57  0.1.56  0.1.55  0.1.54  0.1.53  0.1.52  0.1.51  0.1.50  0.1.49  0.1.48  0.1.47  0.1.46  0.1.45  0.1.44  0.1.43  0.1.42  0.1.41  0.1.40  0.1.38  0.1.37  0.1.36  0.1.35  0.1.34  0.1.33  0.1.32  0.1.31  0.1.30  0.1.29  0.1.28  0.1.27  0.1.26  0.1.24  0.1.23  0.1.22  0.1.21  0.1.20  0.1.19  0.1.18  0.1.17  0.1.16  0.1.15  0.1.14  0.1.13  0.1.12  0.1.11  0.1.10  0.1.9  0.1.8  0.1.7  0.1.6  0.1.5  0.1.4  0.1.3  0.1.2  0.1.1  0.1.0'
      expect(CookbookInfo).to receive(:`).with("knife cookbook show #{cookbook}").and_return(versions)

      expect(CookbookInfo.server_versions(cookbook)).to eq(versions)
    end
  end
end
