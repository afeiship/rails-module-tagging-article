# rails-module-tagging-article
> Rails module for tag and article.

## step by step:
+ Create an article model.
```bash
rails g model article name published_on:date content:text
```
+ Create sample data in seeds.rb:
```rb
batman = Article.create! name: "Batman", content: <<-ARTICLE
Batman is a fictional character created by the artist Bob Kane and writer Bill Finger. A comic book superhero, Batman first appeared in Detective Comics #27 (May 1939), and since then has appeared primarily in publications by DC Comics. Originally referred to as "The Bat-Man" and still referred to at times as "The Batman", he is additionally known as "The Caped Crusader", "The Dark Knight", and the "World's Greatest Detective," among other titles. (from Wikipedia)
ARTICLE

superman = Article.create! name: "Superman", content: <<-ARTICLE
Superman is a fictional comic book superhero appearing in publications by DC Comics, widely considered to be an American cultural icon. Created by American writer Jerry Siegel and Canadian-born American artist Joe Shuster in 1932 while both were living in Cleveland, Ohio, and sold to Detective Comics, Inc. (later DC Comics) in 1938, the character first appeared in Action Comics #1 (June 1938) and subsequently appeared in various radio serials, television programs, films, newspaper strips, and video games. (from Wikipedia)
ARTICLE

krypton = Article.create! name: "Krypton", content: <<-ARTICLE
Krypton is a fictional planet in the DC Comics universe, and the native world of the super-heroes Superman and, in some tellings, Supergirl and Krypto the Superdog. Krypton has been portrayed consistently as having been destroyed just after Superman's flight from the planet, with exact details of its destruction varying by time period, writers and franchise. Kryptonians were the dominant people of Krypton. (from Wikipedia)
ARTICLE

lex_luthor = Article.create! name: "Lex Luthor", content: <<-ARTICLE
Lex Luthor is a fictional character, a supervillain who appears in comic books published by DC Comics. He is the archenemy of Superman, and is also a major adversary of Batman and other superheroes in the DC Universe. Created by Jerry Siegel and Joe Shuster, he first appeared in Action Comics #23 (April 1940). Luthor is described as "a power-mad, evil scientist" of high intelligence and incredible technological prowess. (from Wikipedia)
ARTICLE

robin = Article.create! name: "Robin", content: <<-ARTICLE
Robin is the name of several fictional characters appearing in comic books published by DC Comics, originally created by Bob Kane, Bill Finger and Jerry Robinson, as a junior counterpart to DC Comics superhero Batman. The team of Batman and Robin is commonly referred to as the Dynamic Duo or the Caped Crusaders. (from Wikipedia)
ARTICLE
```

+ Create the tag model with name attribute.
```bash
rails g model tag name
```
+ Create the tagging model.
```bash
rails g model tagging tag:belongs_to article:belongs_to
```

+ Migrate the database.
```bash
rails db:migrate
```

+ Setup the associations in the models. In tag model:
```rb
class Tag < ApplicationRecord
  has_many :taggings
  has_many :articles, through: :taggings
end
```

```rb
class Article < ApplicationRecord
  has_many :taggings
  has_many :tags, through: :taggings

  def self.tagged_with(name)
    Tag.find_by!(name: name).articles
  end

  def self.tag_counts
    Tag.select('tags.*, count(taggings.tag_id) as count').joins(:taggings).group('taggings.tag_id')
  end

  # tag_list setter/getter
  def tag_list
    tags.map(&:name).join(', ')
  end

  def tag_list=(names)
    self.tags = names.split(',').map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end
end
```

+ Create the articles controller with index, new, show and edit actions.
```bash
rails g controller articles index new show edit
```

+ The articles controller is straightforward.
```rb
class ArticlesController < ApplicationController
  def index
    @articles = if params[:tag]
      Article.tagged_with(params[:tag])
    else
      Article.all
    end
  end

  def new
    @article = Article.new
  end

  def show
    @article = Article.find(params[:id])
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article, notice: 'Created article.'
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(article_params)
      redirect_to @article, notice: 'Updated article.'
    else
      render :edit
    end
  end

  private

  def article_params
    params.require(:article).permit(:name, :published_on, :content)
  end
end
```


+ article/index.html.erb
```erb
<h1>Articles</h1>

<div id="tag_cloud">
  <% tag_cloud Article.tag_counts, %w[s m l] do |tag, css_class| %>
    <%= link_to tag.name, tag_path(tag.name), class: css_class %>
  <% end %>
</div>

<div id="articles">
  <% @articles.each do |article| %>
    <h2><%= link_to article.name, article %></h2>
    <%= simple_format article.content %>
    <p>
      Tags: <%= raw article.tags.map(&:name).map { |t| link_to t, tag_path(t) }.join(', ') %>
    </p>
    <p><%= link_to "Edit Article", edit_article_path(article) %></p>
  <% end %>
</div>

<p><%= link_to "New Article", new_article_path %></p>
```

+ article/new.html.erb
```erb

```


+ article.scss
```scss
#tag_cloud {
  width: 400px;
  line-height: 1.6em;
  .s { font-size: 0.8em; }
  .m { font-size: 1.2em; }
  .l { font-size: 1.8em; }
}
```


+ application_helper.rb
```rb
module ApplicationHelper
  def tag_cloud(tags, classes)
    max = tags.sort_by(&:count).last
    tags.each do |tag|
      index = tag.count.to_f / max.count * (classes.size - 1)
      yield(tag, classes[index.round])
    end
  end
end
```

+ rails db:seed
+ routes.rb
```rb
  resources :articles
  root 'articles#index'
  get 'tags/:tag', to: 'articles#index', as: :tag, :constraints  => { :tag => /[^\/]+/ }
```