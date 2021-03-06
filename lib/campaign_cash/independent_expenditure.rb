module CampaignCash
  class IndependentExpenditure < Base
    
    attr_reader :committee, :district, :state, :committee_name, :purpose, :candidate, :candidate_name, :support_or_oppose, :date, :amount, :office, :amendment, :date_received, :payee, :fec_uri, :transaction_id, :unique_id
    
    def initialize(params={})
      params.each_pair do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end
    
    def self.create(params={})
      self.new :committee => parse_committee(params['fec_committee']),
               :committee_name => params['fec_committee_name'],
               :candidate => parse_candidate(params['fec_candidate']),
               :office => params['office'],
               :state => params['state'] ? params['state'].strip : nil,
               :district => params['district'],
               :date => date_parser(params['date']),
               :support_or_oppose => params['support_or_oppose'],
               :payee => params['payee'],
               :purpose => params['purpose'],
               :amount => params['amount'],
               :fec_uri => params['fec_uri'],
               :date_received => date_parser(params['date_received']),
               :amendment => params['amendment'],
               :transaction_id => params['transaction_id'],
               :candidate_name => params['candidate_name'],
               :filing_id      => params['filing_id'],
               :amended_from   => params['amended_from'], # <= original filing ID will be nil if amendment is false
               # unique_id is a SHA1 of filing_id and transaction_id
               # If the expenditure is amended, the unique_id will be amended_from + transaction_id
               # so it can be used as an overrideable unique key
               :unique_id => params['unique_id']
    end
    
    def self.latest(offset=nil)
      reply = Base.invoke("#{Base::CURRENT_CYCLE}/independent_expenditures",{:offset => offset})
      results = reply['results']
      results.map{|c| IndependentExpenditure.create(c)}
    end
    
    def self.date(date,offset=nil)
      d = Date.strptime(date, '%m/%d/%Y')
      cycle = cycle_from_date(d)
      reply = Base.invoke("#{cycle}/independent_expenditures/#{d.year}/#{d.month}/#{d.day}", {:offset => offset})
      results = reply['results']
      results.map{|c| IndependentExpenditure.create(c)}      
    end
    
    def self.committee(id, cycle, offset=nil)
      independent_expenditures = []
      reply = Base.invoke("#{cycle}/committees/#{id}/independent_expenditures",{:offset => offset})
      results = reply['results']
      comm = reply['fec_committee']
      results.each do |result|
        result['fec_committee'] = comm
        independent_expenditures << IndependentExpenditure.create(result)
      end
      independent_expenditures
    end
    
    def self.candidate(id, cycle, offset=nil)
      independent_expenditures = []
      reply = Base.invoke("#{cycle}/candidates/#{id}/independent_expenditures",{:offset => offset})
      results = reply['results']
      cand = reply['fec_candidate']
      results.each do |result|
        result['fec_candidate'] = cand
        independent_expenditures << IndependentExpenditure.create(result)
      end
      independent_expenditures
    end
    
    def self.president(cycle=CURRENT_CYCLE,offset=nil)
      reply = Base.invoke("#{cycle}/president/independent_expenditures",{:offset => offset})
      results = reply['results']
      results.map{|c| IndependentExpenditure.create(c)}
    end
    
  end
end