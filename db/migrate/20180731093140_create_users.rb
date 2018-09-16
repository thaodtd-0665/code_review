class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :login
      t.string :avatar
      t.string :email
      t.integer :role, default: 0
      t.bigint :chatwork
      t.bigint :room_id

      t.timestamps
    end

    add_index :users, :chatwork, unique: true
    add_index :users, :room_id
  end
end
