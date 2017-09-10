class AddGenreToTask < ActiveRecord::Migration[5.1]
  def change
      add_column :tasks, :genre_id, :integer, default: 0
  end
end
