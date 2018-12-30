class AddReviewerPiconToPullRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :pull_requests, :reviewer_picon, :string
  end
end
