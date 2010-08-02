class WN
  module TransactionalRunner
    def self.included(base)

      base.prepend_before(:each) do
        repository(:default) do
          transaction = DataMapper::Transaction.new(repository)
          transaction.begin
          repository.adapter.push_transaction(transaction)
        end
      end

      base.append_after(:each) do
        repository(:default) do
          if repository.adapter.current_transaction
            repository.adapter.current_transaction.rollback
            repository.adapter.pop_transaction
          end
        end
      end

    end
  end
end
