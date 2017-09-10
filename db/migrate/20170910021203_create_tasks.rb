class CreateTasks < ActiveRecord::Migration[5.1]
    def change
        create_table :tasks do |t|
            t.string :name
            t.integer :cost
            t.timestamp :deadline
            t.integer :user_id

            t.timestamps
        end
    end
end
