require 'active_record'

module ActiveRecord::FindDuplicates
  extend ActiveSupport::Concern

  module ClassMethods
    # Examples:
    #   User.find_duplicates(on: :email).group_by(&:email)
    #   User.where('email is not null').find_duplicates(on: :email)
    def find_duplicates(on:, min: 2)
      attr_name = on
      values = group(attr_name).having(
        # If I could figure out how to do "count(*)".gteq(min) with Arel, then it would work with sqlite
        arel_table[Arel.star].count.gteq(min)
      ).count.keys

      where(attr_name => values)
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::FindDuplicates
end
