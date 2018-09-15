class CreatePullRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :pull_requests do |t|
      t.string :title
      t.string :full_name
      t.bigint :repository_id
      t.integer :number
      t.bigint :user_id
      t.integer :state, default: 0
      t.string :current_reviewer

      t.timestamps
    end

    add_index :pull_requests, %i[repository_id number], unique: true
  end
end
