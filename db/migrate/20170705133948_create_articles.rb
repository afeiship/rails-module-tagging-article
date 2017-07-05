class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :name
      t.date :published_on
      t.text :content

      t.timestamps
    end
  end
end
