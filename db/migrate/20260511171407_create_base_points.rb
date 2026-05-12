class CreateBasePoints < ActiveRecord::Migration[7.1]
  def change
    create_table :base_points do |t|
      t.string :base_number
      t.string :name
      t.string :base_type

      t.timestamps
    end
  end
end
