class Repository < ApplicationRecord
  scope :search_by_full_name, (lambda do |term|
    where arel_table[:full_name].matches "%#{term}%"
  end)

  alias_attribute :text, :full_name
end
