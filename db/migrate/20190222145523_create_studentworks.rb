class CreateStudentworks < ActiveRecord::Migration[5.2]
  def change
    create_table :studentworks do |t|
      t.string :work
      t.references :user, foreign_key: true, null: false
      t.references :assignment, foreign_key: true, null: false

      t.timestamps
    end
  end
end
